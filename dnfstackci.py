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

    usage: prog [-h] [--fedora VERSION] ARCHITECTURE DESTINATION

    Build RPMs of a tito-enabled project from the checkout in
    the current working directory. The RPMs will be stored in
    a subdirectory "packages" of the destination directory.

    positional arguments:
      ARCHITECTURE      the value of the Mock's
                        "config_opts['target_arch']" option
      DESTINATION       the name of a destination directory
                        (the directory will be overwritten)

    optional arguments:
      -h, --help        show this help message and exit
      --fedora VERSION  the target Fedora release version

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


def _build_rpms(arch, destdn, last_tag=True, fedora='rawhide'):
    """Build RPMs of a tito-enabled project in the current work. dir.

    The "tito" and "mock" executables must be available. The destination
    directory will be overwritten.

    :param arch: the value of the Mock's "config_opts['target_arch']"
       option
    :type arch: unicode
    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param last_tag: build from the latest tag instead of the current HEAD
    :type last_tag: bool
    :param fedora: the target Fedora release version
    :type fedora: unicode
    :raises exceptions.OSError: if the destination directory cannot be
       created or overwritten or if some of the executables cannot be
       executed
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building RPMs from %s...', os.getcwdu())
    _remkdir(destdn, notexists_ok=True)
    with _MockConfig(arch, fedora) as mockcfg:
        # FIXME: https://github.com/dgoodwin/tito/issues/171
        command = [
            'tito', 'build', '--rpm',
            '--output={}'.format(destdn),
            '--builder=mock',
            '--arg=mock={}'.format(mockcfg.cfgfn)]
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


def _start_commandline():
    """Start the command line interface to the program.

    The root logger is configured to write DEBUG+ messages into the
    destination directory if not configured otherwise. A handler that
    writes INFO+ messages to :data:`sys.stderr` is added to
    :const:`.LOGGER`.

    The interface usage is::

        usage: prog [-h] [--fedora VERSION] ARCHITECTURE DESTINATION

        Build RPMs of a tito-enabled project from the checkout in
        the current working directory. The RPMs will be stored in
        a subdirectory "packages" of the destination directory.

        positional arguments:
          ARCHITECTURE      the value of the Mock's
                            "config_opts['target_arch']" option
          DESTINATION       the name of a destination directory
                            (the directory will be overwritten)

        optional arguments:
          -h, --help        show this help message and exit
          --fedora VERSION  the target Fedora release version

        The "tito" and "mock" executables must be available. If an error
        occurs the exit status is non-zero.

    :raises exceptions.SystemExit: with a non-zero exit status if an
       error occurs

    """
    pkgsreldn = 'packages'
    argparser = argparse.ArgumentParser(
        description='Build RPMs of a tito-enabled project from the checkout in'
                    ' the current working directory. The RPMs will be stored '
                    'in a subdirectory "{}" of the destination directory.'
                    ''.format(pkgsreldn),
        epilog='The "tito" and "mock" executables must be available. If an '
               'error occurs the exit status is non-zero.')
    argparser.add_argument(
        '--fedora', default='rawhide', type=unicode, metavar='VERSION',
        help='the target Fedora release version')
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
    try:
        _build_rpms(
            options.arch, os.path.join(options.destdn, pkgsreldn),
            last_tag=False, fedora=options.fedora)
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
    :ivar fedora: the target Fedora release version
    :type fedora: unicode
    :ivar arch: the value set as "config_opts['target_arch']"
    :type arch: unicode
    :ivar cfgfn: a name of the file where the configuration is stored
    :type cfgfn: unicode | None

    """

    def __init__(self, arch, fedora='rawhide'):
        """Initialize the configuration.

        :param arch: a value set as "config_opts['target_arch']"
        :type arch: unicode
        :param fedora: a target Fedora release version
        :type fedora: unicode

        """
        self.basedir = None
        self.root = '{}-{}-{}'.format(NAME, fedora, arch)
        self.fedora = fedora
        self.arch = arch
        self.cfgfn = None

    def __enter__(self):
        """Enter the runtime context related to this object.

        The configuration is written into a file.

        :returns: self
        :rtype: ._MockConfig

        """
        self.basedir = decode_path(tempfile.mkdtemp())
        fedora_repo = '{}{}'.format(
            '' if self.fedora == 'rawhide' else 'fedora-', self.fedora)
        template = pkg_resources.resource_string(
            __name__, b'resources/mock.cfg')
        config = template.decode('utf-8').format(
            basedir=self.basedir, root=self.root, arch=self.arch,
            fedora_repo=fedora_repo, releasever=self.fedora,
            updates={'rawhide': '0'}.get(self.fedora, '1'))
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
