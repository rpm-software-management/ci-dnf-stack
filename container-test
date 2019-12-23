#!/usr/bin/env python

from __future__ import print_function

import argparse
import os
import re
import subprocess
import sys

PROGPATH = os.path.abspath(os.path.dirname(sys.argv[0]))

# add behave tests root to python path so the `consts` module can be imported
sys.path.append(os.path.join(PROGPATH, 'dnf-behave-tests'))
import consts
DESTRUCTIVE_TAGS = set(consts.DESTRUCTIVE_TAGS)
BUILD_TYPES = ['jjb', 'local', 'side-tag', 'distro']


def command_line_parser():
    '''
    Initialize and return command line arguments parser.
    '''
    # general options
    parser = argparse.ArgumentParser(
        description="Functional tests for DNF",
        epilog="To get help on specific command use \"%(prog)s <command> --help\"")
    parser.add_argument(
        "-s", "--suite", default="features",
        help="Test suite to run (directory with *.feature files)")
    parser.add_argument(
        "-c", "--container", metavar="IMAGE",
        default='dnf-bot/dnf-testing:latest',
        help="Specified Image ID or name if do not want to run the last built image")
    parser.add_argument(
        "-d", "--devel", action="store_true", default=False,
        help="Share local feature/ with docker")
    parser.add_argument(
        "--docker", action="store_true", default=False,
        help="Force using docker instead of default podman")
    parser.add_argument(
        "-v", "--verbose", action="store_true", default=False,
        help="Increase verbosity")

    subparsers = parser.add_subparsers(
        dest="command", required=True, help="List of available commands:")

    # build command
    build_parser = subparsers.add_parser(
        'build', help="Build a container with functional tests")
    build_parser.add_argument(
        "-f", "--file", metavar="FILE", dest="docker_file",
        default="Dockerfile", help="Path to Dockerfile to use")
    build_parser.add_argument(
        "--usecache", action="store_true", default=False,
        help="Use cache when building the image")
    build_parser.add_argument(
        "build_type", metavar="<type>", nargs="?",
        help="Possible build types are {}. The default is 'local'".format(
            ', '.join(BUILD_TYPES)))

    # run command
    run_parser = subparsers.add_parser(
        'run',
        help="Run the tests, the set of tests can be optionally specified.")
    run_parser.add_argument(
        "-r", "--reserve", action="store_true", default=False,
        help="Keep bash shell session open after every single test executed")
    run_parser.add_argument(
        "-R", "--reserveonfail", action="store_true", default=False,
        help="Keep bash shell session open upon test failure")
    run_parser.add_argument(
        "-t", "--tags", action="append", metavar="TAG", default=[],
        help="Pass specific tag to the behave command when running tests")
    run_parser.add_argument(
        "--noxfail", action="store_true", default=False,
        help="Skip tests marked as @xfail (same as --tags ~@xfail)")
    run_parser.add_argument(
        "--command", metavar="COMMAND", dest="dnf_command",
        help="DNF command to be used in tests")
    run_parser.add_argument(
        "--junit-directory", default=None,
        help="Directory to save junit reports to")
    run_parser.add_argument(
        "--enable-network", action="store_true", default=False,
        help="Enable networking inside the container")
    run_parser.add_argument(
        "featurefiles", metavar="<feature>", nargs="*",
        help="List of feature files to run")

    # list command
    list_parser = subparsers.add_parser(
        'list', help="List available functional tests")

    # shell command
    shell_parser = subparsers.add_parser(
        'shell', help="Run a bash shell session within the container")

    return parser


def error(msg):
    print('Error: ' + msg, file=sys.stderr)
    sys.exit(1)


def execute(command):
    '''
    Execute the `command` in a new process, wait for process to finish and
    return (exit code, [captured sdout lines], [captured stderr lines])
    '''
    #print('Running: ', ' '.join(command), file=sys.stderr)
    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out_encoding = sys.stdout.encoding or 'utf-8'
    stdout, stderr = process.communicate()
    return process.returncode,\
           stdout.decode(out_encoding).split('\n'),\
           stderr.decode(out_encoding).split('\n')


class BehaveRunner(object):

    def __init__(self):
        self.command_line_parser = command_line_parser()
        self.command_line_args = self.command_line_parser.parse_args()
        self._docker_bin = None
        self._build_type = None
        self._volumes = None

    def __call__(self):
        command = getattr(self, 'command_%s' % self.command_line_args.command, None)
        if not command:
            error("Command '{}' is not implemented.".format(
                self.command_line_args.command))
        #print(self.command_line_args)
        command()

    @property
    def param_reserve(self):
        if self.command_line_args.reserve:
            return ['-r']
        elif self.command_line_args.reserveonfail:
            return ['-R']
        else:
            return []

    @property
    def param_tty(self):
        retval = []
        if self.param_reserve:
            retval.append('-it')
        return retval

    @property
    def param_cache(self):
        retval = []
        if not self.command_line_args.usecache:
            retval.append('--no-cache')
        return retval

    @property
    def param_dnfcommand(self):
        retval = []
        if self.command_line_args.dnf_command:
            retval.extend(['--command', self.command_line_args.dnf_command])
        return retval

    @property
    def docker_bin(self):
        '''
        Autodetection whether podman (default) or docker is gonna be used
        '''
        if self._docker_bin is None:
            docker_available = not execute(["bash", "-c", "command -v docker"])[0]
            podman_available = not execute(["bash", "-c", "command -v podman"])[0]
            if self.command_line_args.docker:
                if not docker_available:
                    error("Docker is not installed.")
                self._docker_bin = ['sudo', 'docker']
            else:
                if podman_available:
                    self._docker_bin = ['podman']
                elif docker_available:
                    self._docker_bin = ['sudo', 'docker']
                else:
                    error("Neither podman nor docker is installed.")
        return self._docker_bin

    @property
    def volumes(self):
        if self._volumes is None:
            self._volumes = []
            if self.command_line_args.devel:
                self._volumes.extend(['--volume', '{}:{}:Z'.format(
                    os.path.join(PROGPATH, 'dnf-behave-tests',
                                 self.command_line_args.suite),
                    os.path.join('/opt/behave', self.command_line_args.suite))])
            if hasattr(self.command_line_args, 'junit_directory') \
                and self.command_line_args.junit_directory:
                self._volumes.extend(['--volume', '{}:/junit:Z'.format(
                    self.command_line_args.junit_directory)])
        return self._volumes

    @property
    def build_type(self):
        if not self._build_type:
            self._build_type = 'local'
            if self.command_line_args.build_type:
                build_type = self.command_line_args.build_type
                if build_type in BUILD_TYPES:
                    self._build_type = build_type
                else:
                    error('Unknown build type: "{}"'.format(build_type))
        return self._build_type

    @property
    def tags(self):
        tags = self.command_line_args.tags
        if self.command_line_args.noxfail:
            tags.append('~xfail')
        return tags

    def parse_behave_dry_run(self, output):
        '''
        Parsing of the `behave --dry-run` output.
        Returns list of (feature, [scenarios]) tuples where feature is
        tuple (feature file name, set(feature tags)) and scenario is
        tuple (scenario name, set( scenario tags))
        '''
        re_feature = re.compile(r'^ *Feature:.*# +(?P<file>.*):.*$')
        re_scenario = re.compile(r'^ *Scenario(?: Outline)?: +(?P<name>.*)# +(?P<file>.*):.*$')
        re_tag = re.compile(r'^ *(?P<tags>@.*)')
        tests = []
        feature = None
        scenarios = []
        tags = set()
        for line in output:
            # tags
            match = re_tag.match(line)
            if match:
                tags.update([t.strip()
                             for t in match.group('tags').split('@')
                             if t])
                continue

            # Feature
            match = re_feature.match(line)
            if match:
                if feature:
                    tests.append((feature, scenarios))
                feature = (match.group('file'), tags)
                scenarios = []
                tags = set()
                continue

            # Scenario
            match = re_scenario.match(line)
            if match:
                scenarios.append((match.group('name').strip(), tags))
                tags = set()
                continue

        if feature:
            tests.append((feature, scenarios))

        return tests

    def prepend_featuresdir(self, feature):
        if not feature.startswith('{}/'.format(self.command_line_args.suite)):
            return os.path.join(self.command_line_args.suite, feature)
        else:
            return feature

    def dry_run(self):
        command = self.docker_bin + ['run', '--rm']
        command += self.volumes
        command += [self.command_line_args.container, 'behave', '--dry-run']
        if hasattr(self.command_line_args, 'featurefiles') and self.command_line_args.featurefiles:
            command += [self.prepend_featuresdir(a) for a in self.command_line_args.featurefiles]
        else:
            command += [self.command_line_args.suite]
        returncode, stdout, stderr = execute(command)
        if returncode > 0:
            msg = 'Command "{}" failed with {}'.format(' '.join(command), returncode)
            stdout = [l for l in stdout if l]
            stderr = [l for l in stderr if l]
            if stdout:
                msg += '\n'.join(['', 'stdout:'] + stdout).rstrip()
            if stderr:
                msg += '\n'.join(['', 'stderr:'] + stderr).rstrip()
            error(msg)
        return self.parse_behave_dry_run(stdout)


    def command_list(self):
        '''
        List all features available in the container.
        '''
        for (feature, scenarios) in self.dry_run():
            print(feature[0])

    def command_shell(self):
        '''
        Run shell inside the container.
        '''
        command = self.docker_bin + ['run', '-it', '--rm']
        command += self.volumes
        command += [self.command_line_args.container, 'bash']
        subprocess.call(command)

    def command_run(self):
        '''
        Run specified tests in the container.
        '''
        def process_feature(feature, scenarios):
            '''
            feature: tuple (feature file name, set(feature tags))
            scenarios: list of tuples [(scenario name, set(scenario tags))]
            yields behave options for running the feature
            '''
            feature_name, feature_tags = feature
            nondestructive_tests = False
            i = 1
            for scenario_name, scenario_tags in scenarios:
                if feature_tags.union(scenario_tags).intersection(DESTRUCTIVE_TAGS):
                    # destructive tests are run one scenario per container
                    yield ['-n', '^{} *$'.format(re.escape(scenario_name)),
                           '-j', '{}_{}'.format(feature_name, i),
                           self.prepend_featuresdir(feature_name)]
                    i += 1
                else:
                    nondestructive_tests = True
            if nondestructive_tests:
                # run all remaining non-destructive scenarios at once
                options = [self.prepend_featuresdir(feature_name),
                           '-j', '{}_0'.format(feature_name)]
                for tag in DESTRUCTIVE_TAGS:
                    options.extend(['--tags', '~{}'.format(tag)])
                yield options

        command = self.docker_bin + ['run', '--rm']
        command += self.param_tty
        command += self.volumes
        if not self.command_line_args.enable_network:
            command += ['--net', 'none']
        command += [self.command_line_args.container, './launch-test']
        command += self.param_reserve
        for tag in self.tags:
            command += ['--tags', tag]
        command += self.param_dnfcommand
        failed = set()
        for feature, scenarios in self.dry_run():
            for test_options in process_feature(feature, scenarios):
                if self.command_line_args.verbose:
                    print("Running command:", ' '.join(command + test_options), '\n')
                returncode = subprocess.call(command + test_options)
                if returncode > 0:
                    failed.add(feature[0])
        if failed:
            error('\n'.join(['Failed test(s):'] + sorted(failed)))

    def command_build(self):
        '''
        Build container for testing
        '''
        command = self.docker_bin + ['build', '--force-rm']
        command += self.param_cache
        command += ['--build-arg', 'TYPE={}'.format(self.build_type)]
        command += ['-t', self.command_line_args.container]
        command += ['-f', self.command_line_args.docker_file, PROGPATH]
        returncode = subprocess.call(command)
        if returncode > 0:
            error('Failed to build the container.')


if __name__ == '__main__':
    BehaveRunner()()
