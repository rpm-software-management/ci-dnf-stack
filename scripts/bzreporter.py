#!/usr/bin/python3

import argparse
import logging
from multiprocessing import Pool
import os
from pprint import pprint
import re
import subprocess
import sys
import tempfile

import bugzilla
from lxml import etree


PROGPATH = os.path.abspath(os.path.dirname(sys.argv[0]))

DEFAULT_BUGZILLA_URL = 'bugzilla.redhat.com'
# DEFAULT_BUGZILLA_URL = 'partner-bugzilla.redhat.com'
DEVEL_VERIFY_TAG = 'devel_verify_passed'
VERIFIED_DEVEL_MARK = 'proposing:verified:devel'
RE_BZID = re.compile(r'@bz(\d+)')
RE_FILENAME = re.compile(r'@feature_file_name:(\S+)')


logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)

def get_parser():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-d', '--debug', action='store_true',
        help='Debug mode')

    parser.add_argument(
        '--dry-run', action='store_true',
        help='Do not write any changes to bugzilla')
    parser.add_argument(
        '--comment', action='store_true',
        help='Add comment with test result details to the bug')

    parser.add_argument(
        '--bugzilla-url', default=DEFAULT_BUGZILLA_URL,
        help='URL of the bugzilla instance')
    parser.add_argument(
        '--release', required=True,
        help='Internal target release (8.2.0,...)')

    parser.add_argument(
        '--old-image', required=True,
        help='Container image with unfixed version of the dnf stack')
    parser.add_argument(
        '--new-image', required=True,
        help='Container image with fixed version of the dnf stack')

    return parser


def find_bugzillas(txt):
    # XXX false positives in comments, scenario names...
    return [int(bzid) for bzid in RE_BZID.findall(txt, re.MULTILINE)]


def process_file(junit_file_name):
    results = dict()
    logging.debug('Parsing file "%s"...', junit_file_name)
    with open(junit_file_name, 'r') as junit_file:
        tree = etree.parse(junit_file)
        for testcase_elem in tree.findall('//testcase'):
            testcase = dict(testcase_elem.attrib)
            testcase['system-out'] = testcase_elem.find('system-out').text
            if testcase['status'] == 'failed':
                failure = testcase_elem.find('failure')
                if failure is None:
                    failure = testcase_elem.find('error')
                testcase['failure'] = dict(failure.attrib)
                testcase['failure']['details'] = failure.text
            featurefile = RE_FILENAME.search(testcase['system-out'], re.MULTILINE)
            if featurefile:
                featurefile = featurefile[1]
            testcase['featurefile'] = featurefile
            for bzid in find_bugzillas(testcase['system-out']):
                results.setdefault(bzid, []).append(testcase)
    return results


def parse_results(junit_dir):
    results = dict()
    for dirpath, dirnames, filenames in os.walk(junit_dir):
        for filename in filenames:
            if filename.endswith('.xml'):
                for bzid, cases in process_file(os.path.join(dirpath, filename)).items():
                    results.setdefault(bzid, []).extend(cases)
    return results


def execute(command):
    '''
    Execute the `command` in a new process, wait for process to finish and
    return (exit code, [captured sdout lines], [captured stderr lines])
    '''
    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out_encoding = sys.stdout.encoding or 'utf-8'
    stdout, stderr = process.communicate()
    return (process.returncode,
            stdout.decode(out_encoding).split('\n'),
            stderr.decode(out_encoding).split('\n'))


def run_dnf_testing(container_image, command):
    script_path = os.path.join(os.path.dirname(PROGPATH), 'container-test')
    command = [script_path, '-c', container_image] + command
    return execute(command)


def run_tests(bugs, container_image, output_dir):
    '''
    Run dnf-testing.sh in given image with tests result written to given directory
    '''
    # run tests for devel verified bugs
    logging.info('Running dnf test suite for bugs %s in container "%s"...',
                 ', '.join([str(b.id) for b in bugs]), container_image)
    tags = []
    for bug in bugs:
        tags.append('@bz{}'.format(bug.id))
    command = ['run', '--noxfail', '--junit-directory', output_dir, '-t', ','.join(tags)]
    run_dnf_testing(container_image, command)


def pool_run_tests(args):
    return run_tests(*args)


def image_info(container_image):
    output = dict()
    returncode, stdout, stderr = run_dnf_testing(
        container_image, ['execute', 'cat', '/etc/redhat-release'])
    distro = stdout[0]
    output['distro'] = distro

    returncode, stdout, stderr = run_dnf_testing(
        container_image, ['execute', 'rpm', '-q',
                          'libsolv', 'libdnf', 'librepo', 'libcomps',
                          'dnf', 'dnf-plugins-core'])
    versions = ', '.join([line for line in stdout if line])
    output['versions'] = versions

    returncode, stdout, stderr = run_dnf_testing(
        container_image, ['execute', 'grep', 'REDHAT_BUGZILLA_PRODUCT=', '/etc/os-release'])
    product = stdout[0]
    product = product.split('=')[-1].strip('"')
    output['product'] = product
    return output


class BzReporter():

    def __init__(self, bugzilla_url, product, release, dry_run=False):
        self.bugzilla_url = bugzilla_url
        self.product = product
        self.release = release
        self.components = [
            'yum', 'yum-utils', 'rpm', 'redhat-rpm-config', 'createrepo', 'deltarpm',
            'yum-metadata-parser', 'yum-presto', 'yum-updatesd', 'rpmdb-redhat',
            'rpmdevtools', 'rpmlint', 'createrepo_c', 'dnf', 'libdnf',
            'dnf-plugins-core', 'libmodulemd', 'librhsm', 'libcomps', 'nextgen-yum4',
            'drpm', 'librepo', 'libsolv', 'microdnf', 'python-urlgrabber']
        self.dry_run = dry_run

        self.bzapi = bugzilla.RHBugzilla(self.bugzilla_url)
        if not self.bzapi.logged_in:
            logging.error('The application requires bugzilla credentials.')
            sys.exit(1)

    def verified_devel_bugs(self):
        '''
        Collect bugs from the bugzilla which are supposed to be verified by devels
        '''
        query = self.bzapi.build_query(
            product=self.product,
            status='ON_QA',
            include_fields=["id", "status", "summary", "assigned_to", "devel_whiteboard"]
        )
        # internal target release
        query['cf_internal_target_release'] = self.release
        # both QE and Dev propose verified by devel
        query['f1'] = 'cf_devel_whiteboard'
        query['o1'] = 'substring'
        query['v1'] = VERIFIED_DEVEL_MARK
        query['f2'] = 'cf_qa_whiteboard'
        query['o2'] = 'substring'
        query['v2'] = VERIFIED_DEVEL_MARK
        # one of the given components
        query['f3'] = 'component'
        query['o3'] = 'regexp'
        query['v3'] = '^({})$'.format('|'.join(self.components))
        # leave out bugs already marked as passed in devel whiteboard
        query['f4'] = 'cf_devel_whiteboard'
        query['o4'] = 'notsubstring'
        query['v4'] = DEVEL_VERIFY_TAG
        # leave out bugs with Test- in devel whiteboard
        query['f5'] = 'cf_devel_whiteboard'
        query['o5'] = 'notsubstring'
        query['v5'] = 'Test-'
        # leave out bugs with requires_ci_gating- in devel whiteboard
        query['f6'] = 'cf_devel_whiteboard'
        query['o6'] = 'notsubstring'
        query['v6'] = 'requires_ci_gating-'

        return self.bzapi.query(query)

    def result_to_comment(self, result):
        '''
        Convert test result to an array of lines suitable to be added
        as a comment to the bug
        '''
        comment = []
        test_name = '{}/{}'.format(result['classname'], result['name'])
        comment.append('Test: {}'.format(test_name))
        comment.append('=' * 25)
        comment.append('RESULT: {}'.format(result['status'].upper()))
        comment.append('=' * 25)
        comment.extend(result['system-out'].split('\n'))
        if result['status'] == 'failed':
            comment.extend(result['failure']['details'].split('\n'))
        return comment

    def report_verified(self, bug, old_results, new_results):
        '''
        Update the bug with given tests results. Returns True if the bug was
        successfully verified.
        '''
        logging.info('Processing "%s"...', bug)
        if DEVEL_VERIFY_TAG + '+' in bug.devel_whiteboard:
            logging.info('The bug was already verified, skipping.')
            return False
        if bug.id not in old_results['results']:
            logging.info('No tests were found for the bug.')
            return False

        verified = False
        # collect all feature files used in the tests
        feature_files = set()
        comment = []

        # to be marked as verified by devel, at least one of old_results must fail
        # and all new_results must pass
        # prepare comment with test results on old and new systems
        comment.append('Automatic verification of the bug')
        comment.append('Results on {}:'.format(old_results['distro']))
        comment.append('dnf-stack versions: {}'.format(old_results['versions']))
        for result in old_results['results'][bug.id]:
            if result['status'] == 'failed':
                verified = True
            comment.extend(self.result_to_comment(result))
        if not verified:
            msg = ('Verification failed - all tests passed on unfixed "{}" system, '
                   'at least one failure was expected.').format(old_results['distro'])
            logging.info(msg)
            comment.append(msg)

        if verified:
            comment.append('Results on {}:'.format(new_results['distro']))
            comment.append('dnf-stack versions: {}'.format(new_results['versions']))
            for result in new_results['results'][bug.id]:
                if result['status'] == 'failed':
                    verified = False
                comment.extend(self.result_to_comment(result))
                feature_files.add(result['featurefile'] or result['classname'])
        if not verified:
            msg = ('Verification failed - all tests are expected to pass on '
                   'fixed "{}" system.').format(new_results['distro'])
            logging.info(msg)
            comment.append(msg)

        whiteboard_message = []
        if bug.devel_whiteboard:
            whiteboard_message.insert(0, bug.devel_whiteboard)
        if verified:
            whiteboard_message.append(DEVEL_VERIFY_TAG + '+')
            # mark all feature files used in devel whiteboard
            # for ff in sorted(feature_files):
            #    whiteboard_message.append('Test+:{}'.format(ff))
        else:
            whiteboard_message.append(DEVEL_VERIFY_TAG + '-')

        # update the status of the bug
        update_dict = dict()
        if whiteboard_message:
            update_dict['devel_whiteboard'] = '\n'.join(whiteboard_message)
        if comment:
            update_dict['comment'] = '\n'.join(comment)
            update_dict['comment_private'] = True

        if self.dry_run:
            pprint(update_dict)
        else:
            self.bzapi.update_bugs([bug.id], self.bzapi.build_update(**update_dict))
        logging.info('The bug #%s has been updated.', bug.id)
        return True


def main():
    parser = get_parser()
    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    # retrieve distro and dnf versions from images
    old_results = image_info(args.old_image)
    new_results = image_info(args.new_image)

    bzr = BzReporter(
        bugzilla_url=args.bugzilla_url,
        product=new_results['product'],
        release=args.release,
        dry_run=args.dry_run)

    verified_devel_bugs = bzr.verified_devel_bugs()

    if not verified_devel_bugs:
        logging.info("No bugs for devel verification found.")
        sys.exit(0)

    with tempfile.TemporaryDirectory(prefix="bzreporter-") as old_dir,\
         tempfile.TemporaryDirectory(prefix="bzreporter-") as new_dir:
        # run old and new testing in parallel, wait for them
        pool = Pool(processes=2)
        pool.map(pool_run_tests,
                 [(verified_devel_bugs, args.old_image, old_dir),
                  (verified_devel_bugs, args.new_image, new_dir)])
        # parse both result sets
        old_results['results'] = parse_results(old_dir)
        new_results['results'] = parse_results(new_dir)

    # update bug status in bugzilla if there was a test for it
    for bug in verified_devel_bugs:
        bzr.report_verified(bug, old_results, new_results)


if __name__ == '__main__':
    main()
