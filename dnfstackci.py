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

    usage: prog [-h] {setup,build} ...

    Test the DNF stack.

    positional arguments:
      {setup,build}  the action to be performed

    optional arguments:
      -h, --help     show this help message and exit

    If an error occurs the exit status is non-zero.

The usage of the "setup" command is::

    usage: prog setup [-h] CHROOT [CHROOT ...] PROJECT

    Create a new Copr project.

    positional arguments:
      CHROOT      the chroots to be used in the project
                  ("22" adds "fedora-22-i386,
                  fedora-22-ppc64le, fedora-22-x86_64",
                  "23" adds "fedora-23-i386,
                  fedora-23-ppc64le, fedora-23-x86_64",
                  "rawhide" adds "fedora-rawhide-i386,
                  fedora-rawhide-ppc64le, fedora-rawhide-x86_64")
      PROJECT     the name of the project

    optional arguments:
      -h, --help  show this help message and exit

The usage of the "build" command is::

    usage: prog build [-h] [--add-non-rawhide VERSION] [--add-rawhide]
                      [--add-repository URL] [--root ROOT]
                      {tito,librepo,libcomps} ...

    Build RPMs of a project from the checkout in the current working
    directory. The RPMs will be stored in a subdirectory "packages"
    of the destination directory. Also corresponding metadata will
    be added so that the subdirectory could work as an RPM
    repository.

    positional arguments:
      {tito,librepo,libcomps}
                            the type of the project

    optional arguments:
      -h, --help            show this help message and exit
      --add-non-rawhide VERSION
                            add a Fedora non-Rawhide release repository
                            to the Mock's "config_opts['yum.conf']"
                            option
      --add-rawhide         add the Fedora Rawhide repository to the
                            Mock's "config_opts['yum.conf']" option
      --add-repository URL  the URL of a repository to be added to the
                            Mock's "config_opts['yum.conf']" option
      --root ROOT           the value of the Mock's
                            "config_opts['root']" option

    The "mock" executable must be available.

The usage for "tito" projects is::

    usage: prog build tito [-h] [--define MACRO EXPR]
                           ARCHITECTURE DESTINATION

    Build a tito-enabled project.

    positional arguments:
      ARCHITECTURE         the value of the Mock's
                           "config_opts['target_arch']" option
      DESTINATION          the name of a destination directory
                           (the directory will be overwritten)

    optional arguments:
      -h, --help           show this help message and exit
      --define MACRO EXPR  define an RPM MACRO with the value EXPR

    In addition, the "tito" executable must be available.

The usage for "librepo" projects is::

    usage: prog build librepo [-h] [--release RELEASE]
                              ARCHITECTURE DESTINATION SPEC

    Build a librepo project fork.

    positional arguments:
      ARCHITECTURE       the value of the Mock's
                         "config_opts['target_arch']" option
      DESTINATION        the name of a destination directory
                         (the directory will be overwritten)
      SPEC               the ID of the Fedora Git revision of
                         the spec file

    optional arguments:
      -h, --help         show this help message and exit
      --release RELEASE  a custom release number of the resulting RPMs

The usage for "libcomps" projects is::

    usage: prog build libcomps [-h] [--release RELEASE]
                               ARCHITECTURE DESTINATION

    Build a libcomps project fork.

    positional arguments:
      ARCHITECTURE       the value of the Mock's
                         "config_opts['target_arch']" option
      DESTINATION        the name of a destination directory
                         (the directory will be overwritten)

    optional arguments:
      -h, --help         show this help message and exit
      --release RELEASE  a custom release number of the resulting RPMs

    In addition, the "createrepo_c" and "python" executables must be
    available.

:var NAME: the name of the project
:type NAME: unicode
:var LOGGER: the logger used by this project
:type LOGGER: logging.Logger

"""


from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import argparse
import errno
import fileinput
import itertools
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib

import copr
import createrepo_c
import pkg_resources


NAME = 'dnf-stack-ci'

LOGGER = logging.getLogger(NAME)


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


def _create_copr(name, chroots):
    """Create a Copr project.

    :param name: a name of the project
    :type name: unicode
    :param chroots: names of the chroots to be used in the project
    :type chroots: collections.Iterable[unicode]
    :raises exceptions.ValueError: if the project cannot be created

    """
    chroots = list(chroots)
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
    try:
        client = copr.client.CoprClient.create_from_file_config()
        client.create_project(name, chroots=chroots)
    except Exception as err:
        LOGGER.error('Copr failed with: %s', err)
        raise ValueError('Copr failed')


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


def _build_tito(  # pylint: disable=too-many-arguments,too-many-locals
        arch, destdn, last_tag=True, repos=(), macros=(), root=NAME):
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
    :param repos: an URL type (``'baseurl'`` or ``'metalink'``) and the
       URL (direct or metalink) of each repository to be added to the
       Mock's config_opts['yum.conf']
    :type repos: collections.Sequence[tuple[unicode, unicode]]
    :param macros: the name and the value of each RPM macro to be
       defined
    :type macros: collections.Sequence[tuple[unicode, unicode]]
    :param root: the value of the Mock's "config_opts['root']" option
    :type root: unicode
    :raises exceptions.OSError: if the destination directory cannot be
       created or overwritten or if some of the executables cannot be
       executed
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building RPMs from %s...', os.getcwdu())
    basedir = decode_path(tempfile.mkdtemp())
    try:
        _remkdir(destdn, notexists_ok=True)
        with _MockConfig(arch, repos, basedir=basedir, root=root) as mockcfg:
            # FIXME: https://github.com/dgoodwin/tito/issues/171
            cmd = [
                'tito', 'build', '--rpm',
                '--output={}'.format(destdn),
                '--builder=mock',
                '--arg=mock={}'.format(mockcfg.cfgfn)]
            if macros:
                # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1205823
                arg = ' '.join(
                    "--define '{0[0]} {0[1]}'".format(pair) for pair in macros)
                cmd.append('--arg=mock_args={}'.format(arg))
                # FIXME: https://github.com/dgoodwin/tito/issues/149
                cmd.insert(4, '--rpmbuild-options={}'.format(arg))
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
                mdestdn = os.path.join(destdn, 'mock')
                assert not os.path.exists(mdestdn), 'not move *into* the dir'
                # FIXME: https://github.com/dgoodwin/tito/issues/178
                try:
                    shutil.move(mockcfg.resultdn, mdestdn)
                except (OSError, IOError) as err:
                    # Mock could fail, a new mock version could have changed
                    # the path or a new tito version could have changed its
                    # output structure.
                    if isinstance(err.filename, str):
                        fname = decode_path(err.filename)
                    else:
                        fname = err.filename
                    LOGGER.warning("Mock's path %s is not accessible.", fname)
                _log_call(cmd[0], status, output)
    finally:
        shutil.rmtree(basedir)
    try:
        _create_rpmrepo(destdn, '.rpm')
    except (OSError, ValueError, IOError):
        raise ValueError('repository creation failed')


def _build_librepo(  # pylint: disable=too-many-arguments,too-many-locals
        spec, arch, destdn, repos=(), release=None, root=NAME):
    """Build RPMs of a librepo project fork in the current work. dir.

    The "mock" executable must be available. The destination directory
    will be overwritten. Corresponding metadata will be added so that
    the directory could work as an RPM repository.

    :param spec: the ID of the Fedora Git revision of the spec file
    :type spec: unicode
    :param arch: the value of the Mock's "config_opts['target_arch']"
       option
    :type arch: unicode
    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param repos: an URL type (``'baseurl'`` or ``'metalink'``) and the
       URL (direct or metalink) of each repository to be added to the
       Mock's config_opts['yum.conf']
    :type repos: collections.Sequence[tuple[unicode, unicode]]
    :param release: a custom release number of the resulting RPMs
    :type release: str | None
    :param root: the value of the Mock's "config_opts['root']" option
    :type root: unicode
    :raises exceptions.IOError: if the spec file of librepo cannot be
       downloaded
    :raises urllib.ContentTooShortError: if the spec file of librepo
       cannot be downloaded
    :raises exceptions.OSError: if the destination directory cannot be
       created or overwritten or if some of the executables cannot be
       executed
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building RPMs from %s...', os.getcwdu())
    workdn = '/tmp/{}'.format(NAME)
    specurlpat = (
        'http://pkgs.fedoraproject.org/cgit/librepo.git/plain/librepo.spec?'
        'id={}')
    specfn = urllib.urlretrieve(specurlpat.format(spec))[0]
    if release:
        _set_release(specfn, release)
    _remkdir(destdn, notexists_ok=True)
    with _MockConfig(arch, repos, root=root) as mockcfg:
        # FIXME: https://github.com/Tojaj/librepo/pull/61
        try:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--install', '/usr/bin/git', 'check-devel', 'cmake',
                 'expat-devel', 'gcc', 'glib2-devel', 'gpgme-devel',
                 'libattr-devel', 'libcurl-devel', 'openssl-devel',
                 'python2-devel', 'python3-devel', 'pygpgme',
                 'python3-pygpgme', 'python-flask', 'python3-flask',
                 'python-nose', 'python3-nose', 'pyxattr', 'python3-pyxattr',
                 'doxygen', 'python-sphinx', 'python3-sphinx'],
                stderr=subprocess.STDOUT)
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--chroot', '--', 'rm', '--recursive', '--force', workdn],
                stderr=subprocess.STDOUT)
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--copyin', '.', workdn], stderr=subprocess.STDOUT)
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--copyin', decode_path(specfn),
                 '{}/librepo.spec'.format(workdn)], stderr=subprocess.STDOUT)
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--chroot', '--', 'chmod', '--recursive', '+rX', workdn],
                stderr=subprocess.STDOUT)
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--chroot',
                 'ln --symbolic --force /builddir/build "$HOME/rpmbuild"'],
                stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as err:
            _log_call(err.cmd[0], err.returncode, err.output)
            raise ValueError('environment preparation failed')
        status = 0
        try:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            output = subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--chroot', 'cd "{}" && utils/make_rpm.sh .'.format(workdn)],
                stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as err:
            status, output = err.returncode, err.output
            raise ValueError('"utils/make_rpm.sh" in chroot failed')
        finally:
            _log_call('mock', status, output)
        try:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            srpms = subprocess.check_output([
                'mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                '--chroot', 'for NAME in {}/*.src.rpm; do echo "$NAME"; done'
                .format(workdn)])
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            rpms = subprocess.check_output([
                'mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                '--chroot', 'for NAME in /builddir/build/RPMS/*.rpm; '
                'do echo "$NAME"; done'])
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--copyout'] + srpms.decode('utf-8').splitlines() +
                rpms.decode('utf-8').splitlines() + [destdn],
                stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as err:
            _log_call(err.cmd[0], err.returncode, err.output)
            raise ValueError('result saving failed')
    try:
        _create_rpmrepo(destdn, '.rpm')
    except (OSError, ValueError, IOError):
        raise ValueError('repository creation failed')


def _build_libcomps(arch, destdn, repos=(), release=None, root=NAME):
    """Build RPMs of a librepo project fork in the current work. dir.

    The "createrepo_c", "mock" and "python" executables must be
    available. The destination directory will be overwritten.
    Corresponding metadata will be added so that the directory
    could work as an RPM repository.

    :param arch: the value of the Mock's "config_opts['target_arch']"
       option
    :type arch: unicode
    :param destdn: the name of a destination directory
    :type destdn: unicode
    :param repos: an URL type (``'baseurl'`` or ``'metalink'``) and the
       URL (direct or metalink) of each repository to be added to the
       Mock's config_opts['yum.conf']
    :type repos: collections.Sequence[tuple[unicode, unicode]]
    :param release: a custom release number of the resulting RPMs
    :type release: str | None
    :param root: the value of the Mock's "config_opts['root']" option
    :type root: unicode
    :raises exceptions.OSError: if some of the executables cannot be
       executed
    :raises exceptions.ValueError: if the build fails

    """
    LOGGER.info('Building RPMs from %s...', os.getcwdu())
    try:
        # FIXME: https://github.com/midnightercz/libcomps/pull/26
        subprocess.check_output(
            ['python', 'build_prep.py'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as err:
        _log_call(err.cmd[0], err.returncode, err.output)
        raise ValueError('sources preparation failed')
    specfn = 'libcomps.spec'
    if release:
        _set_release(specfn, release)
    with _MockConfig(arch, repos, createrepo=True, root=root) as mockcfg:
        try:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--resultdir={}'.format(destdn), '--buildsrpm', '--spec',
                 specfn, '--sources', '.'], stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as err:
            _log_call(err.cmd[0], err.returncode, err.output)
            raise ValueError('SRPM preparation failed')
        srpm, = (fnm for fnm in os.listdir(destdn) if fnm.endswith('.src.rpm'))
        srpmfn = os.path.join(tempfile.mkdtemp(), 'libcomps.src.rpm')
        shutil.move(os.path.join(destdn, srpm), srpmfn)
        status = 0
        try:
            # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
            output = subprocess.check_output(
                ['mock', '--quiet', '--root={}'.format(mockcfg.cfgfn),
                 '--resultdir={}'.format(destdn), srpmfn],
                stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as err:
            status, output = err.returncode, err.output
            raise ValueError('"mock" failed')
        finally:
            shutil.rmtree(os.path.dirname(srpmfn))
            _log_call('mock', status, output)


def _start_commandline():  # pylint: disable=too-many-statements
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

        usage: prog setup [-h] CHROOT [CHROOT ...] PROJECT

        Create a new Copr project.

        positional arguments:
          CHROOT      the chroots to be used in the project
                      ("22" adds "fedora-22-i386,
                      fedora-22-ppc64le, fedora-22-x86_64",
                      "23" adds "fedora-23-i386,
                      fedora-23-ppc64le, fedora-23-x86_64",
                      "rawhide" adds "fedora-rawhide-i386,
                      fedora-rawhide-ppc64le, fedora-rawhide-x86_64")
          PROJECT     the name of the project

        optional arguments:
          -h, --help  show this help message and exit

    The usage of the "build" command is::

        usage: prog build [-h] [--add-non-rawhide VERSION]
                          [--add-rawhide] [--add-repository URL]
                          [--root ROOT]
                          {tito,librepo,libcomps} ...

        Build RPMs of a project from the checkout in the current working
        directory. The RPMs will be stored in a subdirectory "packages"
        of the destination directory. Also corresponding metadata will
        be added so that the subdirectory could work as an RPM
        repository.

        positional arguments:
          {tito,librepo,libcomps}
                                the type of the project

        optional arguments:
          -h, --help            show this help message and exit
          --add-non-rawhide VERSION
                                add a Fedora non-Rawhide release
                                repository to the Mock's
                                "config_opts['yum.conf']" option
          --add-rawhide         add the Fedora Rawhide repository to the
                                Mock's "config_opts['yum.conf']" option
          --add-repository URL  the URL of a repository to be added to
                                the Mock's "config_opts['yum.conf']"
                                option
          --root ROOT           the value of the Mock's
                                "config_opts['root']" option

        The "mock" executable must be available.

    The usage for "tito" projects is::

        usage: prog build tito [-h] [--define MACRO EXPR]
                               ARCHITECTURE DESTINATION

        Build a tito-enabled project.

        positional arguments:
          ARCHITECTURE         the value of the Mock's
                               "config_opts['target_arch']" option
          DESTINATION          the name of a destination directory
                               (the directory will be overwritten)

        optional arguments:
          -h, --help           show this help message and exit
          --define MACRO EXPR  define an RPM MACRO with the value EXPR

        In addition, the "tito" executable must be available.

    The usage for "librepo" projects is::

        usage: prog build librepo [-h] [--release RELEASE]
                                  ARCHITECTURE DESTINATION SPEC

        Build a librepo project fork.

        positional arguments:
          ARCHITECTURE       the value of the Mock's
                             "config_opts['target_arch']" option
          DESTINATION        the name of a destination directory
                             (the directory will be overwritten)
          SPEC               the ID of the Fedora Git revision of
                             the spec file

        optional arguments:
          -h, --help         show this help message and exit
          --release RELEASE  a custom release number of the
                             resulting RPMs

    The usage for "libcomps" projects is::

        usage: prog build libcomps [-h] [--release RELEASE]
                                   ARCHITECTURE DESTINATION

        Build a libcomps project fork.

        positional arguments:
          ARCHITECTURE       the value of the Mock's
                             "config_opts['target_arch']" option
          DESTINATION        the name of a destination directory
                             (the directory will be overwritten)

        optional arguments:
          -h, --help         show this help message and exit
          --release RELEASE  a custom release number of the
                             resulting RPMs

        In addition, the "createrepo_c" and "python" executables must be
        available.

    :raises exceptions.SystemExit: with a non-zero exit status if an
       error occurs

    """
    chroot2chroots = {
        '22': {'fedora-22-i386', 'fedora-22-ppc64le', 'fedora-22-x86_64'},
        '23': {'fedora-23-i386', 'fedora-23-ppc64le', 'fedora-23-x86_64'},
        'rawhide': {'fedora-rawhide-i386', 'fedora-rawhide-ppc64le',
                    'fedora-rawhide-x86_64'}}
    pkgsreldn = 'packages'
    argparser = argparse.ArgumentParser(
        description='Test the DNF stack.',
        epilog='If an error occurs the exit status is non-zero.')
    cmdparser = argparser.add_subparsers(
        dest='command', help='the action to be performed')
    setupparser = cmdparser.add_parser(
        'setup', description='Create a new Copr project.')
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
                    'working directory. The RPMs will be stored in a '
                    'subdirectory "{}" of the destination directory. Also '
                    'corresponding metadata will be added so that the '
                    'subdirectory could work as an RPM repository.'
                    ''.format(pkgsreldn),
        epilog='The "mock" executable must be available.')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    buildparser.add_argument(
        '--add-non-rawhide', action='append', default=[], type=unicode,
        help="add a Fedora non-Rawhide release repository to the Mock's "
             "\"config_opts['yum.conf']\" option",
        metavar='VERSION')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    buildparser.add_argument(
        '--add-rawhide', action='store_true',
        help="add the Fedora Rawhide repository to the Mock's "
             "\"config_opts['yum.conf']\" option")
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    buildparser.add_argument(
        '--add-repository', action='append', default=[], type=unicode,
        help="the URL of a repository to be added to the Mock's "
             "\"config_opts['yum.conf']\" option",
        metavar='URL')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    buildparser.add_argument(
        '--root', default=NAME, type=unicode,
        help="the value of the Mock's \"config_opts['root']\" option")
    commonparser = argparse.ArgumentParser(add_help=False)
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    commonparser.add_argument(
        'arch', type=unicode, metavar='ARCHITECTURE',
        help="the value of the Mock's \"config_opts['target_arch']\" option")
    commonparser.add_argument(
        'destdn', type=unicode, metavar='DESTINATION',
        help='the name of a destination directory (the directory will be '
             'overwritten)')
    projparser = buildparser.add_subparsers(
        dest='project', help='the type of the project')
    titoparser = projparser.add_parser(
        'tito', description='Build a tito-enabled project.',
        epilog='In addition, the "tito" executable must be available.',
        parents=[commonparser])
    titoparser.add_argument(
        '--define', action='append', nargs=2, default=[], type=unicode,
        help='define an RPM MACRO with the value EXPR',
        metavar=('MACRO', 'EXPR'), dest='macros')
    repoparser = projparser.add_parser(
        'librepo', description='Build a librepo project fork.',
        parents=[commonparser])
    repoparser.add_argument(
        'fedrev', type=unicode, metavar='SPEC',
        help='the ID of the Fedora Git revision of the spec file')
    repoparser.add_argument(
        '--release', help='a custom release number of the resulting RPMs')
    compsparser = projparser.add_parser(
        'libcomps', description='Build a libcomps project fork.',
        epilog='In addition, the "createrepo_c" and "python" executables must '
               'be available.',
        parents=[commonparser])
    compsparser.add_argument(
        '--release', help='a custom release number of the resulting RPMs')
    options = argparser.parse_args()
    if hasattr(options, 'destdn'):
        try:
            _remkdir(options.destdn, notexists_ok=True)
        except OSError:
            sys.exit(
                'The destination directory cannot be created or overwritten.')
        logfn = os.path.join(options.destdn, 'debug.log')
    else:
        logfn = os.path.join(os.getcwdu(), '{}.log'.format(NAME))
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
            _create_copr(options.project, chroots)
        except ValueError:
            sys.exit('Copr have failed to create the project.')
    elif options.command == b'build':
        destdn = os.path.join(options.destdn, pkgsreldn)
        repopat = \
            'https://mirrors.fedoraproject.org/metalink?repo={}&arch=$basearch'
        repos = [
            ('metalink', repopat.format('fedora-{}'.format(version)))
            for version in options.add_non_rawhide]
        repos.extend(
            ('metalink',
             'https://mirrors.fedoraproject.org/metalink?'
             'repo=updates-released-f{}&arch=$basearch'.format(version))
            for version in options.add_non_rawhide)
        if options.add_rawhide:
            repos.append(('metalink', repopat.format('rawhide')))
        repos.extend(itertools.product(['baseurl'], options.add_repository))
        if options.project == b'tito':
            try:
                _build_tito(
                    options.arch, destdn, last_tag=False, repos=repos,
                    macros=options.macros, root=options.root)
            except ValueError:
                sys.exit(
                    'The build have failed. Hopefully the executables have '
                    'created an output in the destination directory.')
            except OSError:
                sys.exit(
                    'The destination directory cannot be overwritten or some '
                    'of the executables cannot be executed.')
        elif options.project == b'librepo':
            try:
                _build_librepo(
                    options.fedrev, options.arch, destdn, repos,
                    options.release, options.root)
            except (IOError, urllib.ContentTooShortError, ValueError):
                sys.exit('The build have failed.')
            except OSError:
                sys.exit(
                    'The destination directory cannot be overwritten or some '
                    'of the executables cannot be executed.')
        elif options.project == b'libcomps':
            try:
                _build_libcomps(
                    options.arch, destdn, repos, options.release, options.root)
            except ValueError:
                sys.exit(
                    'The build have failed. Hopefully the executables have '
                    'created an output in the destination directory.')
            except OSError:
                sys.exit(
                    'Some of the executables cannot be executed.')


class _MockConfig(object):  # pylint: disable=too-few-public-methods

    """Class representing a mock configuration.

    The instances can be used as a context manager. It can be configured
    to run createrepo on the rpms in the resultdir. In such case, the
    "createrepo_c" executable must be available.

    :ivar basedir: the value set as "config_opts['basedir']"
    :type basedir: unicode | None
    :ivar root: the value set as "config_opts['root']"
    :type root: unicode
    :ivar arch: the value set as "config_opts['target_arch']"
    :type arch: unicode
    :param repos: an URL type (``'baseurl'`` or ``'metalink'``) and
       the URL (direct or metalink) of each repository to be added to
       config_opts['yum.conf']
    :type repos: collections.Sequence[tuple[unicode, unicode]]
    :ivar createrepo: run createrepo on the rpms in the resultdir
    :type createrepo: bool
    :ivar cfgfn: a name of the file where the configuration is stored
    :type cfgfn: unicode | None

    """

    def __init__(  # pylint: disable=too-many-arguments
            self, arch, repos=(), createrepo=False, basedir=None, root=NAME):
        """Initialize the configuration.

        :param arch: a value set as "config_opts['target_arch']"
        :type arch: unicode
        :param repos: an URL type (``'baseurl'`` or ``'metalink'``) and
           the URL (direct or metalink) of each repository to be added
           to config_opts['yum.conf']
        :type repos: collections.Sequence[tuple[unicode, unicode]]
        :param createrepo: run createrepo on the rpms in the resultdir
        :type createrepo: bool
        :param basedir: a value set as "config_opts['basedir']"
        :type basedir: unicode | None
        :param root: a value set as "config_opts['root']"
        :type root: unicode

        """
        self.basedir = basedir
        self.root = root
        self.arch = arch
        self.repos = repos
        self.createrepo = createrepo
        self.cfgfn = None

    def __enter__(self):
        """Enter the runtime context related to this object.

        The configuration is written into a file.

        :returns: self
        :rtype: ._MockConfig

        """
        repos = '\n'.join(
            '[user-{}]\n{}={}\n'.format(index, type_, url)
            for index, (type_, url) in enumerate(self.repos))
        opts = ''
        if self.basedir:
            opts = "config_opts['basedir'] = '{}'\n".format(self.basedir)
        if self.createrepo:
            opts += (
                "config_opts['createrepo_on_rpms'] = True\n"
                "config_opts['createrepo_command'] = 'createrepo_c --quiet'")
        template = pkg_resources.resource_string(
            __name__, b'resources/mock.cfg')
        config = template.decode('utf-8').format(
            root=self.root, arch=self.arch, repos=repos, opts=opts)
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
        if not self.basedir:
            raise NotImplementedError('unset basedir not supported')
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
        # Basedir removal could fail otherwise because it may miss privileges.
        # See also: https://bugzilla.redhat.com/show_bug.cgi?id=450726
        # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1221975
        status = subprocess.call([
            'mock', '--quiet', '--root={}'.format(self.cfgfn), '--scrub=all'])
        assert not status, 'mock should be able to remove its files'
        try:
            os.remove(self.cfgfn)
        except OSError:
            assert False, 'temporary files should be removable'
        self.cfgfn = None
        return False


if __name__ == '__main__':
    _start_commandline()
