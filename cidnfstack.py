#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2015 ci-dnf-stack Authors. See the AUTHORS file
# found in the top-level directory of this distribution and
# at https://github.com/rpm-software-management/ci-dnf-stack/.
#
# Licensed under the GNU General Public License; either version 2,
# or (at your option) any later version. See the LICENSE file found
# in the top-level directory of this distribution and at
# https://github.com/rpm-software-management/ci-dnf-stack. No part
# of ci-dnf-stack, including this file, may be copied, modified,
# propagated, or distributed except according to the terms contained
# in the LICENSE file.

"""This module represents the software part of the project.

When the module is run as a script, the command line interface to the
program is started. The interface usage is::

    usage: prog [-h] {setup,build} ...

    Test the DNF stack.

    positional arguments:
      {setup,build}  the action to be performed

    optional arguments:
      -h, --help     show this help message and exit

    If an error occurs the exit status is non-zero.

The usage of the "setup" command is::

    usage: prog setup [-h] [--add-repository URL]
                      CHROOT [CHROOT ...] PROJECT

    Create a new Copr project.

    positional arguments:
      CHROOT                the chroots to be used in the project
                            ("22" adds "fedora-22-i386,
                            fedora-22-x86_64", "23" adds
                            "fedora-23-i386, fedora-23-x86_64",
                            "rawhide" adds "fedora-rawhide-i386,
                            fedora-rawhide-x86_64")
      PROJECT               the name of the project

    optional arguments:
      -h, --help            show this help message and exit
      --add-repository URL  the URL of an additional repository
                            that is required

The usage of the "build" command is::

    usage: prog build [-h] PROJECT {tito,librepo,libcomps} ...

    Build RPMs of a project from the checkout in the current working
    directory in Copr.

    positional arguments:
      PROJECT               the name of the Copr project
      {tito,librepo,libcomps}
                            the type of the project

    optional arguments:
      -h, --help            show this help message and exit

The usage for "tito" projects is::

    usage: prog build PROJECT tito [-h]

    Build a tito-enabled project.

    optional arguments:
      -h, --help  show this help message and exit

    The "tito" executable must be available.

The usage for "librepo" projects is::

    usage: prog build PROJECT librepo [-h] [--release RELEASE] SPEC

    Build a librepo project fork.

    positional arguments:
      SPEC               the ID of the Fedora Git
                         revision of the spec file

    optional arguments:
      -h, --help         show this help message and exit
      --release RELEASE  a custom release number of the resulting RPMs

    The "cp", "dirname", "echo", "git", "mv", "rpmbuild", "rm", "sed",
    "sh" and "xz" executables must be available.

The usage for "libcomps" projects is::

    usage: prog build PROJECT libcomps [-h] [--release RELEASE]

    Build a libcomps project fork.

    optional arguments:
      -h, --help         show this help message and exit
      --release RELEASE  a custom release number of the resulting RPMs

    The "python" and "rpmbuild" executables must be available.

The usage for "rpm" projects is::

    usage: prog build PROJECT rpm [-h] [--release RELEASE]

    Build a rpm project fork.

    optional arguments:
      -h, --help         show this help message and exit
      --release RELEASE  a custom release number of the resulting RPMs

    The "python", "tar" and "rpmbuild" executables must be available.


:var NAME: the name of the project
:type NAME: unicode
:var LOGGER: the logger used by this project
:type LOGGER: logging.Logger

"""


from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import argparse
import contextlib
import errno
import fileinput
import glob
import itertools
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib

import pygit2
import rpm

from ci_dnf_stack import utils


NAME = 'ci-dnf-stack'

LOGGER = logging.getLogger(NAME)

FEDREV = 'master'

def decode_path(path):
    """Decode a filesystem path string.

    :param path: the filesystem path
    :type path: str
    :return: the decoded path
    :rtype: unicode

    """
    return path.decode(sys.getfilesystemencoding() or sys.getdefaultencoding())


def _remkdir(name, notexists_ok=False):
    """Re-create a directory.

    :param name: a name of the directory
    :type name: unicode
    :param notexists_ok: create the directory if the path does not exist
       instead of raising an error
    :type notexists_ok: bool
    :raises exceptions.OSError: if the directory cannot be re-created

    """
    try:
        shutil.rmtree(name)
    except OSError as err:
        if not notexists_ok or err.errno != errno.ENOENT:
            raise
    os.mkdir(name)


def _log_call(executable, status, output, encoding='utf-8'):
    """Log the result of an executable.

    :param executable: a name of the executable
    :type executable: unicode
    :param status: the exit status
    :type status: int
    :param output: the captured output
    :type output: str
    :param encoding: the encoding of the output
    :type encoding: unicode

    """
    LOGGER.log(
        logging.ERROR if status else logging.DEBUG,
        '"%s" have exited with %s:\n  captured output:\n%s',
        executable,
        status,
        re.sub(r'^', '    ', output.decode(encoding, 'replace'), flags=re.M))


def _create_copr(name, chroots, repos=()):
    """Create a Copr project.

    :param name: a name of the project
    :type name: unicode
    :param chroots: names of the chroots to be used in the project
    :type chroots: collections.Iterable[unicode]
    :param repos: the URL of each additional repository that is required
    :type repos: collections.Iterable[unicode]
    :raises exceptions.ValueError: if the project cannot be created

    """
    chroots, repos = list(chroots), list(repos)
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
    import copr
    try:
        client = copr.client.CoprClient.create_from_file_config()
        client.create_project(name, chroots=chroots, repos=repos)
    except Exception:
        LOGGER.debug('Copr have failed to create a project.', exc_info=True)
        raise ValueError('Copr failed')


def rpm_headers(dirname):
    """Iterate over the headers of the RPMs in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: a generator yielding the pairs (file name, RPM header)
    :rtype: generator[tuple[unicode, rpm.hdr]]

    """
    filenames = glob.iglob(os.path.join(dirname, '*.rpm'))
    transaction = rpm.TransactionSet()
    for filename in filenames:
        try:
            with open(filename) as file_:
                header = transaction.hdrFromFdno(file_.fileno())
        except (IOError, rpm.error):
            LOGGER.debug('Failed to read %s', filename, exc_info=True)
            continue
        yield filename, header


def _set_release(filename, release):
    """Set the "Release" tag in a spec file.

    :param filename: a name of the spec file
    :type filename: unicode
    :param release: the new value of the tag
    :type release: str
    :raises exceptions.IOError: if the file is not accessible

    """
    count = 0
    for line in fileinput.input([filename], inplace=1):
        if re.match(br'^\s*Release\s*:\s*.+$', line, re.IGNORECASE):
            print(b'Release: {}'.format(release))
            count += 1
            continue
        print(line, end=b'')
    assert count == 1, 'unexpected spec file'


@contextlib.contextmanager
def _move_srpms(source, destination):
    """Move all the source RPMs from one directory to another one.

    The function should be used as a context manager. On enter, all
    SRPMs in the source directory are removed. On exit, all SRPMs in the
    source directory are moved to the destination directory.

    :param source: a name of the source directory
    :type source: unicode
    :param destination: a name of the destination directory
    :type destination: unicode
    :raises exceptions.OSError: if a SRPM cannot be removed
    :raises exceptions.IOError: if a SRPM cannot be moved

    """
    for filename, header in rpm_headers(source):
        if not header.isSource():
            continue
        os.remove(filename)
    yield
    for filename, header in rpm_headers(source):
        if not header.isSource():
            continue
        shutil.move(filename, destination)


def _build_srpm(spec, sources, destdn, release=None):
    """Build a SRPM from a spec file and source archives.

    The "rpmbuild" executable must be available. The source archives and
    SRPMs in ~/rpmbuild/SRPMS will be removed.

    :param spec: a name of the spec file
    :type spec: unicode
    :param sources: a name of the source archives (with shell-style
       wildcards)
    :param sources: str
    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param release: a custom release number of the resulting SRPM
    :type release: str | None
    :returns: a combination of the standard output and standard error of
       the executable
    :rtype: str
    :raises exceptions.IOError: if the build cannot be prepared
    :raises exceptions.OSError: if the build cannot be prepared or if
       the executable cannot be executed
    :raises subprocess.CalledProcessError: if the executable fails to
       build the SRPM

    """
    if release:
        _set_release(spec, release)
    rpmbuilddn = os.path.expanduser(os.path.join('~', 'rpmbuild'))
    for filename in glob.iglob(sources):
        shutil.move(filename, os.path.join(rpmbuilddn, 'SOURCES'))
    with _move_srpms(os.path.join(rpmbuilddn, 'SRPMS'), destdn):
        output = subprocess.check_output(
            [b'rpmbuild', b'--quiet', b'-bs', b'--clean', b'--rmsource',
             b'--rmspec', spec],
            stderr=subprocess.STDOUT)
    return output


def _build_tito(destdn, last_tag=True):
    """Build a SRPM of a tito-enabled project in the current work. dir.

    The "tito" executable must be available. The destination directory
    will be overwritten.

    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param last_tag: build from the latest tag instead of the current HEAD
    :type last_tag: bool
    :raises exceptions.OSError: if the destination directory cannot be
       created or overwritten or if the executable cannot be executed
    :raises exceptions.ValueError: if the build fails

    """
    # It isn't possible to define custom RPM macros.
    # See https://bugzilla.redhat.com/show_bug.cgi?id=1260098
    LOGGER.info('Building a SRPM from %s...', os.getcwdu())
    _remkdir(destdn, notexists_ok=True)
    # FIXME: https://github.com/dgoodwin/tito/issues/171
    cmd = [
        'tito', 'build', '--srpm', '--output={}'.format(destdn)]
    if not last_tag:
        cmd.insert(3, '--test')
    status = 0
    try:
        # FIXME: https://github.com/dgoodwin/tito/issues/165
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as err:
        status, output = err.returncode, err.output
        raise ValueError('"tito" failed')
    finally:
        _log_call(cmd[0], status, output)


def _build_libcomps(destdn, release=None):
    """Build a SRPM of a librepo project fork in the current work. dir.

    The "python" and "rpmbuild" executables must be available. The
    destination directory will be overwritten.

    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param release: a custom release number of the resulting SRPM
    :type release: str | None
    :raises exceptions.OSError: if some of the executables cannot be
       executed or if the destination directory cannot be created or
       overwritten
    :raises exceptions.IOError: if the build cannot be prepared
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building a SRPM from %s...', os.getcwdu())
    try:
        # FIXME: https://github.com/midnightercz/libcomps/pull/26
        subprocess.check_output(
            ['python', 'build_prep.py'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as err:
        _log_call(err.cmd[0], err.returncode, err.output)
        raise ValueError('sources preparation failed')
    _remkdir(destdn, notexists_ok=True)
    try:
        output = _build_srpm('libcomps.spec', b'*-*.tar.gz', destdn, release)
    except subprocess.CalledProcessError as err:
        _log_call('rpmbuild', err.returncode, err.output)
        raise ValueError('"rpmbuild" failed')
    else:
        _log_call('rpmbuild', 0, output)


def _build_rpm(destdn, release=None):
    """Build a SRPM of a rpm project fork in the current work. dir.

    The "python", "tar" and "rpmbuild" executables must be available. The
    destination directory will be overwritten.

    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param release: a custom release number of the resulting SRPM
    :type release: str | None
    :raises exceptions.OSError: if some of the executables cannot be
       executed or if the destination directory cannot be created or
       overwritten
    :raises exceptions.IOError: if the build cannot be prepared
    :raises exceptions.ValueError: if the build fails

    """
    print(destdn)
    LOGGER.info('Building a SRPM from %s...', os.getcwdu())
    specurlpat = 'https://lkardos.fedorapeople.org/rpm-master.spec'
    specfn = 'rpm-master.spec'
    urllib.urlretrieve(specurlpat, specfn)
    if release:
        _set_release(specfn, release)
    try:
        subprocess.check_output(
            ['tar --transform="s|^|rpm/|" -cvjSf rpm.tar.bz2 *'],
            stderr=subprocess.STDOUT, shell=True)
    except subprocess.CalledProcessError as err:
        _log_call(err.cmd[0], err.returncode, err.output)
        raise ValueError('archive preparation failed')
    _remkdir(destdn, notexists_ok=True)
    try:
        output = _build_srpm(specfn, b'rpm.tar.bz2', destdn, release)
    except subprocess.CalledProcessError as err:
        _log_call('rpmbuild', err.returncode, err.output)
        raise ValueError('"rpmbuild" failed')
    else:
        _log_call('rpmbuild', 0, output)


def _build_in_copr(dirname, project):
    """Build RPMs from SRPMs in Copr.

    :param dirname: a name of the directory with SRPMs
    :type dirname: unicode
    :param project: a name of the Copr project
    :type project: unicode
    :raises exceptions.ValueError: if the build cannot be requested or
       if the build fails

    """
    pkgs = [fname for fname, hdr in rpm_headers(dirname) if hdr.isSource()]
    LOGGER.info('Building RPMs from %s...', ', '.join(pkgs))
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
    import copr
    try:
        client = copr.client.CoprClient.create_from_file_config()
        result = client.create_new_build(project, pkgs=pkgs)
    except OSError:
        LOGGER.debug('Copr have failed to create a project.', exc_info=True)
        raise ValueError('Copr failed')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1258970
    while True:
        for build in result.builds_list:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
            try:
                status = build.handle.get_build_details().status
            except Exception:
                LOGGER.debug(
                    'Copr have failed to get build details.', exc_info=True)
                raise ValueError('Copr failed')
            if status not in {'skipped', 'failed', 'succeeded'}:
                break
        else:
            break
        time.sleep(10)
    success, url2status = True, {}
    for build in result.builds_list:
        # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
        try:
            details = build.handle.get_build_details()
        except Exception:
            LOGGER.debug(
                'Copr have failed to get build details.', exc_info=True)
            raise ValueError('Copr failed')
        if details.status == 'failed':
            success = False
        # See https://bugzilla.redhat.com/show_bug.cgi?id=1259251#c1
        url2status.update({
            url: details.data['chroots'][chroot]
            for chroot, url in details.data['results_by_chroot'].items()})
    LOGGER.info('Results of the build can be found at: %s', ', '.join(
        '{} ({})'.format(url, stt.upper()) for url, stt in url2status.items()))
    if not success:
        raise ValueError('build failed')


def get_dnf_testing_version():
    """ Parse ci-dnf-stack.log logfile for package that was built by Copr.

    """
    f = open("ci-dnf-stack.log")
    version = []
    for line in f:
        m = re.search('"src_pkg": "[^"]*[/]([^"]*)[.][\w]+[.][\w]+[.][\w]+"', line)
        if m:
            version.append(m.group(1))
    version = set(version)
    assert len(version) == 1
    return version.pop()


def run_shell_cmd(cmd, msg):
    LOGGER.info(msg + " was initiated")
    docker_removal = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = docker_removal.communicate()
    rc = docker_removal.returncode
    if stdout:
        _log_call(msg, rc, stdout)
    if rc:
        LOGGER.error(msg + " failed \n")
        sys.exit(msg + " failed")
    else:
        LOGGER.info(msg + " successfully passed \n")


def _start_commandline():  # pylint: disable=R0912,R0915
    """Start the command line interface to the program.

    The root logger is configured to write DEBUG+ messages into the
    destination directory if not configured otherwise. A handler that
    writes INFO+ messages to :data:`sys.stderr` is added to
    :const:`.LOGGER`.

    The interface usage is::

        usage: prog [-h] {setup,build} ...

        Test the DNF stack.

        positional arguments:
          {setup,build}  the action to be performed

        optional arguments:
          -h, --help     show this help message and exit

        If an error occurs the exit status is non-zero.

    The usage of the "setup" command is::

        usage: prog setup [-h] [--add-repository URL]
                          CHROOT [CHROOT ...] PROJECT

        Create a new Copr project.

        positional arguments:
          CHROOT                the chroots to be used in the project
                                ("22" adds "fedora-22-i386,
                                fedora-22-x86_64", "23" adds
                                "fedora-23-i386, fedora-23-x86_64",
                                "rawhide" adds "fedora-rawhide-i386,
                                fedora-rawhide-x86_64")
          PROJECT               the name of the project

        optional arguments:
          -h, --help            show this help message and exit
          --add-repository URL  the URL of an additional repository
                                that is required

    The usage of the "build" command is::

        usage: prog build [-h] PROJECT {tito,librepo,libcomps} ...

        Build RPMs of a project from the checkout in the current working
        directory in Copr.

        positional arguments:
          PROJECT               the name of the Copr project
          {tito,librepo,libcomps}
                                the type of the project

        optional arguments:
          -h, --help            show this help message and exit

    The usage for "tito" projects is::

        usage: prog build PROJECT tito [-h]

        Build a tito-enabled project.

        optional arguments:
          -h, --help  show this help message and exit

        The "tito" executable must be available.

    The usage for "librepo" projects is::

        usage: prog build PROJECT librepo [-h] [--release RELEASE] SPEC

        Build a librepo project fork.

        positional arguments:
          SPEC               the ID of the Fedora Git
                             revision of the spec file

        optional arguments:
          -h, --help         show this help message and exit
          --release RELEASE  a custom release number of the
                             resulting RPMs

        The "cp", "dirname", "echo", "git", "mv", "rpmbuild", "rm",
        "sed", "sh" and "xz" executables must be available.

    The usage for "libcomps" projects is::

        usage: prog build PROJECT libcomps [-h] [--release RELEASE]

        Build a libcomps project fork.

        optional arguments:
          -h, --help         show this help message and exit
          --release RELEASE  a custom release number of the
                             resulting RPMs

        The "python" and "rpmbuild" executables must be available.

    :raises exceptions.SystemExit: with a non-zero exit status if an
       error occurs

    """
    chroot2chroots = {
        '22': {'fedora-22-i386', 'fedora-22-x86_64'},
        '23': {'fedora-23-i386', 'fedora-23-x86_64'},
        'rawhide': {'fedora-rawhide-i386', 'fedora-rawhide-x86_64'}}
    argparser = argparse.ArgumentParser(
        description='Test the DNF stack.',
        epilog='If an error occurs the exit status is non-zero.')
    cmdparser = argparser.add_subparsers(
        dest='command', help='the action to be performed')
    setupparser = cmdparser.add_parser(
        'setup', description='Create a new Copr project.')
    setupparser.add_argument(
        '--add-repository', action='append', default=[], type=unicode,
        help='the URL of an additional repository that is required',
        metavar='URL')
    setupparser.add_argument(
        'chroot', nargs='+', choices=sorted(chroot2chroots), metavar='CHROOT',
        help='the chroots to be used in the project ({})'.format(
            ', '.join('"{}" adds "{}"'.format(key, ', '.join(sorted(value)))
                      for key, value in sorted(chroot2chroots.items()))))
    setupparser.add_argument(
        'project', type=unicode, metavar='PROJECT',
        help='the name of the project')
    buildparser = cmdparser.add_parser(
        'build',
        description='Build RPMs of a project from the checkout in the current '
                    'working directory in Copr.')
    buildparser.add_argument(
        '-c', '--copr', type=unicode, nargs='+', default=['local-build', 'tito'], metavar=('PROJECT', 'BUILDER'),
        help='the name of the Copr project. If option not present default values are used: "local-build" "tito" and '
             'the test runs locally (no copr build). '
             'If BUILDER tito, the "tito" executable must be available. '
             'If BUILDER librepo, the "cp", "dirname", "echo", "git", "mv", "rpmbuild", "rm", "sed", "sh" and "xz" '
             'executables must be available.'
             'If BUILDER libscomps, the "python" and "rpmbuild" executables must be available.')
    buildparser.add_argument(
        '-k', '--keep-image', help='keep Docker image after successful test',
        action="store_true")
    buildparser.add_argument(
        '-l', '--localdir', help='describe path to tested project (/absolute/path/to/project). It can be used only with'
                                 ' local-build',
        action="append")
    buildparser.add_argument(
        '-n', '--no-dnf-docker-test', help='do not start the functional test of project after Copr build',
        action="store_true")
    buildparser.add_argument(
        '--release', help='a custom release number of the resulting RPMs')
    buildparser.add_argument(
        '-t', '--test', nargs='*', metavar=('TEST-NAME'),
        help='select only named test for dnf-docker-test')
    options = argparser.parse_args()
    logfn = os.path.join(os.getcwdu(), '{}.log'.format(NAME))
    work_dir = os.path.dirname(os.path.realpath(__file__))
    try:
        logging.basicConfig(
            filename=logfn,
            filemode='wt',
            format='%(asctime)s.%(msecs)03d:%(levelname)s:%(name)s:'
                   '%(message)s',
            datefmt='%Y%m%dT%H%M%S',
            level=logging.DEBUG)
    except IOError:
        sys.exit('A log file ({}) be created or overwritten.'.format(logfn))
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    handler.setFormatter(logging.Formatter('%(levelname)s %(message)s'))
    LOGGER.addHandler(handler)
    if options.command == b'setup':
        chroots = set(itertools.chain.from_iterable(
            chroot2chroots[chroot] for chroot in options.chroot))
        try:
            _create_copr(options.project, chroots, options.add_repository)
        except ValueError:
            LOGGER.debug(
                'An exception have occurred during setup.', exc_info=True)
            sys.exit('Copr have failed to create the project.')
    elif options.command == b'build':
        destdn = decode_path(tempfile.mkdtemp())
        if options.copr[0] == 'local-build':
            local_rpm_path = os.path.join(work_dir, 'dnf-docker-test/local_rpm')
            if os.path.exists(local_rpm_path):
                shutil.rmtree(local_rpm_path)
        else:
            local_rpm_path = None
        try:
            if options.copr[1] == b'tito':
                try:
                    if options.localdir:
                        if options.copr[0] != 'local-build':
                            LOGGER.error('"Localdir" option has to be used only with "local-build" PROJECT name')
                            sys.exit('Unsupported options combination')
                        else:
                            localdir_couter = 1
                            for localdir in options.localdir:
                                localdir = localdir[:-1] if localdir.endswith('/') else localdir
                                shutil.copytree(localdir, os.path.join(local_rpm_path, 'temp', str(localdir_couter),
                                                                       os.path.split(localdir)[1]))
                                localdir_couter += 1
                    elif options.copr[0] == 'local-build':
                        shutil.copytree(os.getcwdu(), os.path.join(local_rpm_path, 'temp', '1',
                                                                   os.path.split(os.getcwdu())[1]))
                    else:
                        _build_tito(destdn, last_tag=False)
                except ValueError:
                    LOGGER.debug(
                        'An exception have occurred during the tito build.',
                        exc_info=True)
                    sys.exit(
                        'The build have failed. Hopefully the executables '
                        'have created an output in the destination '
                        'directory.')
                except OSError:
                    LOGGER.debug(
                        'An exception have occurred during the tito build.',
                        exc_info=True)
                    sys.exit(
                        'The destination directory cannot be overwritten '
                        'or the executable cannot be executed.')
            elif options.copr[1] == b'librepo':
                srpm = utils.build_srpm('librepo', 'upstream', 'fedora/librepo.spec')
                shutil.move(srpm, destdn)
            elif options.copr[1] == b'libcomps':
                try:
                    _build_libcomps(destdn, options.release)
                except (IOError, ValueError):
                    LOGGER.debug(
                        'An exception have occurred during the libcmps build.',
                        exc_info=True)
                    sys.exit(
                        'The build have failed. Hopefully the executables have'
                        ' created an output in the destination directory.')
                except OSError:
                    LOGGER.debug(
                        'An exception have occurred during the libcmps build.',
                        exc_info=True)
                    sys.exit(
                        'The destination directory cannot be overwritten '
                        'or some of the executables cannot be executed.')
            elif options.copr[1] == b'rpm':
                try:
                    _build_rpm(destdn)
                except (IOError, ValueError):
                    LOGGER.debug(
                        'An exception have occurred during the rpm build.',
                        exc_info=True)
                    sys.exit(
                        'The build have failed. Hopefully the executables have'
                        ' created an output in the destination directory.')
                except OSError:
                    LOGGER.debug(
                        'An exception have occurred during the rpm build.',
                        exc_info=True)
                    sys.exit(
                        'The destination directory cannot be overwritten '
                        'or some of the executables cannot be executed.')
            elif options.copr[1] == b'libsolv':
                srpm = utils.build_srpm('libsolv', 'upstream', 'fedora/libsolv.spec')
                shutil.move(srpm, destdn)
            elif options.copr[1] == b'dnf-plugins-extras':
                srpm = utils.build_srpm('dnf-plugins-extras', 'upstream', 'upstream/dnf-plugins-extras.spec')
                shutil.move(srpm, destdn)
            if options.copr[0] != 'local-build':
                try:
                    _build_in_copr(destdn, options.copr[0])
                except ValueError:
                    LOGGER.debug(
                        'Copr have failed to build the RPMs.', exc_info=True)
                    sys.exit(
                        'The build could not be requested or the build have '
                        'failed. Hopefully Copr provides some details.')

        finally:
            shutil.rmtree(destdn)

    if not options.no_dnf_docker_test:
        LOGGER.info("Dnf-docker-test was initiated")
        LOGGER.info("Docker image builder was initiated")
        if options.copr[0] == 'local-build':
            dnf_version = 'local-build'
        else:
            dnf_version = get_dnf_testing_version()
        docker_input_file = os.path.join(work_dir, 'dnf-docker-test/Dockerfile.in')
        docker_output_file = os.path.join(work_dir, 'dnf-docker-test/Dockerfile')
        docker_image = 'jmracek/' + options.copr[0] + '/' + dnf_version + ':1.0.2'
        docker_image_updated = docker_image + '.1'
        with open(docker_input_file, 'r') as docker_in:
            if options.copr[0] == 'local-build':
                copy_local_file = 'COPY local_rpm/temp /local_rpm/'
                install_tito = 'tito'
            else:
                copy_local_file = ''
                install_tito = ''
            docker_in = docker_in.read().format(install_tito=install_tito, copy_local_file=copy_local_file)
            with open(docker_output_file, 'w') as docker_output:
                docker_output.write(docker_in)
        docker_creator_dir = os.path.join(work_dir, 'dnf-docker-test/')
        cmd = ['docker', 'build', '--no-cache', '-t', docker_image, docker_creator_dir]
        msg = "Dnf-docker-test build of docker image"
        run_shell_cmd(cmd, msg)
        container_id_file = 'ID_container'
        if os.path.isfile(container_id_file):
            os.remove(container_id_file)
        cmd = ['docker', 'run', '-i', '--cidfile=' + container_id_file, docker_image, 'python3',
               '/initial_settings/initial.py', dnf_version, options.copr[0]]
        # Docker 'run' option '-t' is needed only for tito build inside docker by DNF unitests.
        # Docker 'run' option '-t' works correctly in docker-1.9.1-6 in f23, but not in version docker-io-1.8.2-2 in f21
        if options.copr[0] == 'local-build':
            cmd.insert(3, '-t')
        msg = "Dnf-docker-test update of docker image"
        run_shell_cmd(cmd, msg)

        with open(container_id_file, 'r') as cotainer_id:
            cotainer_id = cotainer_id.read()
            cmd = ['docker', 'commit', cotainer_id, docker_image_updated]
            msg = "Dnf-docker-test commits of docker image"
            run_shell_cmd(cmd, msg)

            cmd = ['docker', 'rm', cotainer_id]
            msg = "Dnf-docker-test remove container of docker image"
            run_shell_cmd(cmd, msg)

        os.remove(container_id_file)

        feature_pattern = os.path.join(work_dir, 'dnf-docker-test/features/*feature')
        if options.test:
            tests = options.test
        else:
            tests = [os.path.basename(x.rsplit(".", 1)[0]) for x in glob.glob(feature_pattern)]
        failed_tests = 0
        passed_tests = 0
        for test in sorted(tests):
            for dnf_command_version in ['dnf-2', 'dnf-3']:
                LOGGER.info('Running test: ' + test)
                docker_run = ['docker', 'run', '--rm', '-i', docker_image_updated, "launch-test", test, dnf_command_version]
                LOGGER.info('Starting container: ' + (' '.join(docker_run)))
                docker_run = subprocess.Popen(docker_run, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                stdout, _ = docker_run.communicate()
                rc = docker_run.returncode
                if stdout:
                    _log_call('Dnf-docker-test ' + test + ' using ' + dnf_command_version, rc, stdout)
                if rc:
                    failed_tests += 1
                    LOGGER.error("Dnf-docker-test {} using {} failed \n ".format(test, dnf_command_version))
                else:
                    passed_tests += 1
                    LOGGER.info("Dnf-docker-test {} using {} successfully passed \n ".format(test,  dnf_command_version))
        LOGGER.info("Removal of docker image initiated")
        cmd = ['docker', 'rmi', '-f', docker_image]
        msg = 'Removal of docker image ' + docker_image
        run_shell_cmd(cmd, msg)

        if options.keep_image:
            LOGGER.info("Docker image " + docker_image_updated + " is kept until next succesful build of the same image")
            LOGGER.info("The image can be opened using command: "
                        "sudo docker run -it --entrypoint=/bin/bash " + docker_image_updated + "\n")
        else:
            cmd = ['docker', 'rmi', '-f', docker_image_updated]
            msg = 'Removal of docker image ' + docker_image_updated
            run_shell_cmd(cmd, msg)

        if failed_tests:
            LOGGER.error("{} tests failed and {} tests passed".format(failed_tests, passed_tests))
            sys.exit("{} tests failed and {} tests passed".format(failed_tests, passed_tests))
        else:
            LOGGER.info("Dnf-docker-test successfully passed {} tests".format(passed_tests))

if __name__ == '__main__':
    _start_commandline()
