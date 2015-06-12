#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2015 dnf-stack-ci Authors. See the AUTHORS file
# found in the top-level directory of this distribution and
# at https://github.com/rholy/dnf-stack-ci/.
#
# Licensed under the GNU General Public License; either version 2,
# or (at your option) any later version. See the LICENSE file found
# in the top-level directory of this distribution and at
# https://github.com/rholy/dnf-stack-ci/. No part of dnf-stack-ci,
# including this file, may be copied, modified, propagated, or
# distributed except according to the terms contained in the LICENSE
# file.

"""This module represents the software part of the project.

When the module is run as a script, the command line interface to the
program is started. The interface usage is::

    usage: prog [-h] [--add-non-rawhide VERSION] [--add-rawhide]
                [--define MACRO EXPR]
                ARCHITECTURE DESTINATION

    Build RPMs of a tito-enabled project from the checkout in
    the current working directory. The RPMs will be stored in a
    subdirectory "packages" of the destination directory. Also
    corresponding metadata will be added so that the subdirectory
    could work as an RPM repository.

    positional arguments:
      ARCHITECTURE          the value of the Mock's
                            "config_opts['target_arch']" option
      DESTINATION           the name of a destination directory
                            (the directory will be overwritten)

    optional arguments:
      -h, --help            show this help message and exit
      --add-non-rawhide VERSION
                            add a Fedora non-Rawhide release repository
                            to the Mock's "config_opts['yum.conf']"
                            option
      --add-rawhide         add the Fedora Rawhide repository to the
                            Mock's "config_opts['yum.conf']" option
      --define MACRO EXPR   define an RPM MACRO with the value EXPR

    The "tito" and "mock" executables must be available. If an error
    occurs the exit status is non-zero.

:var NAME: the name of the project
:type NAME: unicode
:var LOGGER: the logger used by this project
:type LOGGER: logging.Logger

"""


from __future__ import absolute_import
from __future__ import unicode_literals

import argparse
import errno
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile

import createrepo_c
import pkg_resources


NAME = 'dnf-stack-ci'

LOGGER = logging.getLogger(NAME)


def _indent(text):
    """Indent all the lines of a text.

    :param text: the text to be indented
    :type text: unicode
    :returns: the indented text
    :rtype: unicode

    """
    return re.sub(r'^', '    ', text, flags=re.MULTILINE)


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


def _create_rpmrepo(dirname, suffix):  # pylint: disable=too-many-locals
    """Create a repository from a directory of RPMs.

    Some files in a subdirectory "repodata" may be overwritten.

    :param dirname: a name of the directory
    :type dirname: unicode
    :param suffix: a suffix of all the RPM files
    :type suffix: unicode
    :raises exceptions.OSError: if the directory cannot be read or
       modified
    :raises exceptions.ValueError: if an RPM cannot be read or if the
       subdirectory cannot be modified
    :raises exceptions.IOError: if the subdirectory cannot be modified

    """
    # FIXME: https://github.com/Tojaj/createrepo_c/issues/25
    # FIXME: https://github.com/Tojaj/createrepo_c/issues/19
    name2type = {
        'primary': createrepo_c.XMLFILE_PRIMARY,
        'filelists': createrepo_c.XMLFILE_FILELISTS,
        'other': createrepo_c.XMLFILE_OTHER}
    repodatadn = os.path.join(dirname, 'repodata')
    filesuffix = createrepo_c.compression_suffix(createrepo_c.GZ_COMPRESSION)
    try:
        os.mkdir(repodatadn)
    except OSError as err:
        if err.errno != errno.EEXIST:
            raise
    packages = []
    for pkgbn in [nam for nam in os.listdir(dirname) if nam.endswith(suffix)]:
        pkgfn = os.path.join(dirname, pkgbn)
        try:
            package = createrepo_c.package_from_rpm(pkgfn, location_href=pkgbn)
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/17
        except Exception:
            raise ValueError('RPM not accessible')
        packages.append(package)
    repomd = createrepo_c.Repomd()
    for typename, typeconst in name2type.items():
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/22
        filename = os.path.join(
            repodatadn, '{}.xml{}'.format(typename, filesuffix))
        try:
            # FIXME: https://github.com/Tojaj/createrepo_c/issues/27
            file_ = createrepo_c.XmlFile(
                filename, typeconst, createrepo_c.GZ_COMPRESSION, None)
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/26
        except Exception:
            raise ValueError('path not accessible')
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/20
        file_.set_num_of_pkgs(len(packages))
        for package in packages:
            file_.add_pkg(package)
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/21
        file_.close()
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/28
        record = createrepo_c.RepomdRecord(typename, filename)
        # FIXME: https://github.com/Tojaj/createrepo_c/issues/18
        # noinspection PyArgumentList
        record.fill(createrepo_c.SHA256)
        repomd.set_record(record)
    with open(os.path.join(repodatadn, 'repomd.xml'), 'w') as file_:
        file_.write(repomd.xml_dump())


def _build_rpms(  # pylint: disable=too-many-locals
        arch, destdn, last_tag=True, repos=(), macros=()):
    """Build RPMs of a tito-enabled project in the current work. dir.

    The "tito" and "mock" executables must be available. The destination
    directory will be overwritten. Corresponding metadata will be added
    so that the directory could work as an RPM repository.

    :param arch: the value of the Mock's "config_opts['target_arch']"
       option
    :type arch: unicode
    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param last_tag: build from the latest tag instead of the current HEAD
    :type last_tag: bool
    :param repos: the matalink URL of each repository added to the
       Mock's config_opts['yum.conf']
    :type repos: collections.Sequence[unicode]
    :param macros: the name and the value of each RPM macro to be
       defined
    :type macros: collections.Sequence[tuple[unicode, unicode]]
    :raises exceptions.OSError: if the destination directory cannot be
       created or overwritten or if some of the executables cannot be
       executed
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building RPMs from %s...', os.getcwdu())
    _remkdir(destdn, notexists_ok=True)
    with _MockConfig(arch, repos) as mockcfg:
        # FIXME: https://github.com/dgoodwin/tito/issues/171
        command = [
            'tito', 'build', '--rpm',
            '--output={}'.format(destdn),
            '--builder=mock',
            '--arg=mock={}'.format(mockcfg.cfgfn)]
        if macros:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1205823
            arg = ' '.join(
                "--define '{0[0]} {0[1]}'".format(pair) for pair in macros)
            command.append('--arg=mock_args={}'.format(arg))
            # FIXME: https://github.com/dgoodwin/tito/issues/149
            command.insert(4, '--rpmbuild-options={}'.format(arg))
        if not last_tag:
            command.insert(3, '--test')
        # FIXME: https://github.com/dgoodwin/tito/issues/165
        tito = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        streams, status = tito.communicate(), tito.poll()
        stdout, stderr = (
            stream.decode('utf-8', 'replace') for stream in streams)
        assert not any('\ufffd' in stream for stream in [stdout, stderr])
        mdestdn = os.path.join(destdn, 'mock')
        assert not os.path.exists(mdestdn), "let's not move it *into* the dir"
        # FIXME: https://github.com/dgoodwin/tito/issues/178
        try:
            shutil.move(mockcfg.resultdn, mdestdn)
        except (OSError, IOError) as err:
            # Mock could fail, a new mock version could have changed the path
            # or a new tito version could have changed its output structure.
            if isinstance(err.filename, str):
                filename = decode_path(err.filename)
            else:
                filename = err.filename
            LOGGER.warning("Mock's path %s is not accessible.", filename)
    LOGGER.log(
        logging.ERROR if status else logging.DEBUG,
        '"tito" have exited with %s:\n  standard output:\n%s\n  standard '
        'error:\n%s', status, _indent(stdout), _indent(stderr))
    if status:
        raise ValueError('"tito" failed')
    try:
        _create_rpmrepo(destdn, '.rpm')
    except (OSError, ValueError, IOError):
        raise ValueError('repository creation failed')


def _start_commandline():
    """Start the command line interface to the program.

    The root logger is configured to write DEBUG+ messages into the
    destination directory if not configured otherwise. A handler that
    writes INFO+ messages to :data:`sys.stderr` is added to
    :const:`.LOGGER`.

    The interface usage is::

        usage: prog [-h] [--add-non-rawhide VERSION] [--add-rawhide]
                    [--define MACRO EXPR]
                    ARCHITECTURE DESTINATION

        Build RPMs of a tito-enabled project from the checkout in
        the current working directory. The RPMs will be stored in a
        subdirectory "packages" of the destination directory. Also
        corresponding metadata will be added so that the subdirectory
        could work as an RPM repository.

        positional arguments:
          ARCHITECTURE          the value of the Mock's
                                "config_opts['target_arch']" option
          DESTINATION           the name of a destination directory
                                (the directory will be overwritten)

        optional arguments:
          -h, --help            show this help message and exit
          --add-non-rawhide VERSION
                                add a Fedora non-Rawhide release
                                repository to the Mock's
                                "config_opts['yum.conf']" option
          --add-rawhide         add the Fedora Rawhide repository to the
                                Mock's "config_opts['yum.conf']" option
          --define MACRO EXPR   define an RPM MACRO with the value EXPR

        The "tito" and "mock" executables must be available. If an error
        occurs the exit status is non-zero.

    :raises exceptions.SystemExit: with a non-zero exit status if an
       error occurs

    """
    pkgsreldn = 'packages'
    argparser = argparse.ArgumentParser(
        description='Build RPMs of a tito-enabled project from the checkout in'
                    ' the current working directory. The RPMs will be stored '
                    'in a subdirectory "{}" of the destination directory. Also'
                    ' corresponding metadata will be added so that the '
                    'subdirectory could work as an RPM repository.'
                    ''.format(pkgsreldn),
        epilog='The "tito" and "mock" executables must be available. If an '
               'error occurs the exit status is non-zero.')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1230749
    argparser.add_argument(
        '--add-non-rawhide', action='append', default=[], type=unicode,
        help="add a Fedora non-Rawhide release repository to the Mock's "
             "\"config_opts['yum.conf']\" option",
        metavar='VERSION')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1230749
    argparser.add_argument(
        '--add-rawhide', action='store_true',
        help="add the Fedora Rawhide repository to the Mock's "
             "\"config_opts['yum.conf']\" option")
    argparser.add_argument(
        '--define', action='append', nargs=2, default=[], type=unicode,
        help='define an RPM MACRO with the value EXPR',
        metavar=('MACRO', 'EXPR'), dest='macros')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    argparser.add_argument(
        'arch', type=unicode, metavar='ARCHITECTURE',
        help="the value of the Mock's \"config_opts['target_arch']\" option")
    argparser.add_argument(
        'destdn', type=unicode, metavar='DESTINATION',
        help='the name of a destination directory (the directory will be '
             'overwritten)')
    options = argparser.parse_args()
    try:
        _remkdir(options.destdn, notexists_ok=True)
    except OSError:
        sys.exit('The destination directory cannot be created or overwritten.')
    try:
        logging.basicConfig(
            filename=os.path.join(options.destdn, 'debug.log'),
            filemode='wt',
            format='%(asctime)s.%(msecs)03d:%(levelname)s:%(name)s:'
                   '%(message)s',
            datefmt='%Y%m%dT%H%M%S',
            level=logging.DEBUG)
    except IOError:
        sys.exit('The destination directory cannot be created or overwritten.')
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    handler.setFormatter(logging.Formatter('%(levelname)s %(message)s'))
    LOGGER.addHandler(handler)
    pat = 'https://mirrors.fedoraproject.org/metalink?repo={}&arch=$basearch'
    repos = [
        pat.format('fedora-{}'.format(ver)) for ver in options.add_non_rawhide]
    repos.extend(
        'https://mirrors.fedoraproject.org/metalink?repo=updates-released-f{}&'
        'arch=$basearch'.format(ver) for ver in options.add_non_rawhide)
    if options.add_rawhide:
        repos.append(pat.format('rawhide'))
    try:
        _build_rpms(
            options.arch, os.path.join(options.destdn, pkgsreldn),
            last_tag=False, repos=repos, macros=options.macros)
    except ValueError:
        sys.exit(
            'The build have failed. Hopefully the executables have created an '
            'output in the destination directory.')
    except OSError:
        sys.exit(
            'The destination directory cannot be overwritten or some of the '
            'executables cannot be executed.')


class _MockConfig(object):  # pylint: disable=too-few-public-methods

    """Class representing a mock configuration.

    The instances can be used as a context manager.

    :ivar basedir: the value set as "config_opts['basedir']"
    :type basedir: unicode | None
    :ivar root: the value set as "config_opts['root']"
    :type root: unicode
    :ivar arch: the value set as "config_opts['target_arch']"
    :type arch: unicode
    :ivar repos: the matalink URL of each repository added to
       config_opts['yum.conf']
    :type repos: collections.Sequence[unicode]
    :ivar cfgfn: a name of the file where the configuration is stored
    :type cfgfn: unicode | None

    """

    def __init__(self, arch, repos=()):
        """Initialize the configuration.

        :param arch: a value set as "config_opts['target_arch']"
        :type arch: unicode
        :param repos: the matalink URL of each repository added to
            config_opts['yum.conf']
        :type repos: collections.Sequence[unicode]

        """
        self.basedir = None
        self.root = '{}-{}'.format(NAME, arch)
        self.arch = arch
        self.repos = repos
        self.cfgfn = None

    def __enter__(self):
        """Enter the runtime context related to this object.

        The configuration is written into a file.

        :returns: self
        :rtype: ._MockConfig

        """
        self.basedir = decode_path(tempfile.mkdtemp())
        repos = '\n'.join(
            '[user-{}]\nmetalink={}\n'.format(index, url)
            for index, url in enumerate(self.repos))
        template = pkg_resources.resource_string(
            __name__, b'resources/mock.cfg')
        config = template.decode('utf-8').format(
            basedir=self.basedir, root=self.root, arch=self.arch, repos=repos)
        file_ = tempfile.NamedTemporaryFile('wb', suffix='.cfg', delete=False)
        with file_:
            file_.write(config)
        self.cfgfn = decode_path(file_.name)
        return self

    @property
    def resultdn(self):
        """A name of the directory where the results are stored.

        :returns: a name of the directory
        :rtype: str

        """
        return os.path.join(self.basedir, self.root, 'result')

    def __exit__(self, exc_type, exc_value, traceback):
        """Exit the runtime context related to this object.

        The configuration file and the chroot files are removed.

        The "mock" executable must be available.

        :param exc_type: the type of the exception that caused the
           context to be exited
        :type exc_type: type
        :param exc_value: the instance of the exception
        :type exc_value: exceptions.BaseException
        :param traceback: the traceback that encapsulates the call stack
           at the point where the exception originally occurred
        :type traceback: types.TracebackType
        :returns: suppress the exception that caused the context to be
           exited
        :rtype: bool
        :raises exceptions.OSError: if the executable cannot be executed

        """
        # The rmtree below could fail otherwise because it may miss privileges.
        # See also: https://bugzilla.redhat.com/show_bug.cgi?id=450726
        # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
        status = subprocess.call([
            'mock', '--quiet', '--root={}'.format(self.cfgfn), '--scrub=all'])
        assert not status, 'mock should be able to remove its files'
        try:
            shutil.rmtree(self.basedir)
        except OSError:
            assert False, 'temporary directories should be removable'
        try:
            os.remove(self.cfgfn)
        except OSError:
            assert False, 'temporary files should be removable'
        self.cfgfn = None
        return False


if __name__ == '__main__':
    _start_commandline()
