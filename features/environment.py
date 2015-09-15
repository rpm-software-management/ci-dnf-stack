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

"""This module provides the test fixture common to all the features.

Among other things, the fixture contains a tito-enabled project
directory, a librepo fork directory, a testing repository and an
empty working directory which is created before every scenario.
The only RPM of the tito-enabled project appends the value of an
RPM macro %{snapshot} to its release number if set.

The :class:`behave.runner.Context` instance passed to the environmental
controls and to the step implementations is expected to have following
attributes:

:attr:`!titodn` : :class:`str`
    A name of the directory with the tito-enabled project.
:attr:`!librepodn` : :class:`str`
    A name of the directory with the librepo project fork.
:attr:`!libcompsdn` : :class:`str`
    A name of the directory with the libcomps project fork.
:attr:`!repourl` : :data:`types.UnicodeType`
    The URL of the testing repository.
:attr:`!chr_option` : :class:`list[types.UnicodeType]`
    Names the chroots to be used in a Copr project.
:attr:`!proj_option` : :data:`types.UnicodeType` | :data:`None`
    A name of the Copr project to be created.
:attr:`!repo_option` : :class:`list[types.UnicodeType]`
    The URL of each repository that should be added to the Copr project
    or to the Mock's "config_opts['yum.conf']" option.
:attr:`!rel_option` : :data:`types.UnicodeType` | :data:`None`
    A custom release number of the resulting RPMs passed to
    dnf-stack-ci.
:attr:`!temp_coprs` : :class:`set[types.UnicodeType]`
    Names of the Copr projects to be removed after every scenario.

"""


from __future__ import absolute_import
from __future__ import unicode_literals

import os
import shutil
import subprocess
import tempfile

import copr
import pygit2

import dnfstackci


def before_all(context):
    """Do the preparation that can be done at the very beginning.

    The "tito" executable must be available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.IOError: if the tito-enabled project cannot be
       created
    :raises exceptions.ValueError: if the tito-enabled project cannot be
       created
    :raises exceptions.OSError: if the executable cannot be executed
    :raises subprocess.CalledProcessError: if the tito-enabled project
       cannot be created

    """
    signature = pygit2.Signature(
        dnfstackci.NAME, '{}@example.com'.format(dnfstackci.NAME))
    context.titodn = tempfile.mkdtemp()
    dst_spec = os.path.join(context.titodn, b'foo.spec')
    shutil.copy(
        os.path.join(os.path.dirname(__file__), b'resources', b'foo.spec'),
        dst_spec)
    try:
        titorepo = pygit2.init_repository(context.titodn)
        titorepo.index.add(os.path.relpath(dst_spec, titorepo.workdir))
        titorepo.index.write()
        titorepo.create_commit(
            'refs/heads/master', signature, signature, 'Add a spec file.',
            titorepo.index.write_tree(), [])
    # FIXME: https://github.com/libgit2/pygit2/issues/531
    except Exception:
        raise ValueError('Git repository creation failed')
    # FIXME: https://github.com/dgoodwin/tito/issues/171
    subprocess.check_call(['tito', 'init'], cwd=context.titodn)
    context.librepodn = tempfile.mkdtemp()
    try:
        libreporepo = pygit2.clone_repository(
            'https://github.com/Tojaj/librepo.git', context.librepodn)
        libreporepo.reset(
            'd9bed0d9f96b505fb86a1adc50b3d6f8275fab93', pygit2.GIT_RESET_HARD)
    # FIXME: https://github.com/libgit2/pygit2/issues/531
    except Exception:
        raise ValueError('Git repository creation failed')
    context.libcompsdn = tempfile.mkdtemp()
    try:
        libcompsrepo = pygit2.clone_repository(
            'https://github.com/midnightercz/libcomps.git', context.libcompsdn)
        libcompsrepo.reset(
            'eb966bc43097c0d00e154abe7f40f4d1d75fbcd1', pygit2.GIT_RESET_HARD)
    # FIXME: https://github.com/libgit2/pygit2/issues/531
    except Exception:
        raise ValueError('Git repository creation failed')


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
def before_scenario(context, scenario):  # pylint: disable=unused-argument
    """Do the preparation that must be done before every scenario.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param scenario: the next tested scenario
    :type scenario: behave.model.Scenario

    """
    context.chr_option = []
    context.proj_option = None
    context.repo_option = []
    context.rel_option = None
    context.temp_coprs = set()


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
def after_scenario(context, scenario):  # pylint: disable=unused-argument
    """Do the preparation that must be done after every scenario.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param scenario: the next tested scenario
    :type scenario: behave.model.Scenario
    :raises exceptions.ValueError: if the temporary Copr projects cannot
       be removed

    """
    while True:
        try:
            name = context.temp_coprs.pop()
        except KeyError:
            break
        # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
        try:
            client = copr.client.CoprClient.create_from_file_config()
            client.delete_project(name)
        except Exception:
            raise ValueError('Copr failed')


def after_all(context):
    """Do the cleanup that can be done at the very end.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.OSError: if the tito-enabled project cannot be
       removed

    """
    shutil.rmtree(context.librepodn)
    shutil.rmtree(context.titodn)
