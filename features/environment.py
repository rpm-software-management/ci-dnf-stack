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
directory and an empty working directory which is created before
every feature.

The :class:`behave.runner.Context` instance passed to the environmental
controls and to the step implementations is expected to have following
attributes:

:attr:`!titodn` : :class:`str`
    A name of the directory with the tito-enabled project.
:attr:`!workdn` : :data:`types.UnicodeType`
    A name of the working directory.
:attr:`!arch_option` : :data:`types.UnicodeType`
    A value of the Mock's "config_opts['target_arch']" option used by
    dnf-stack-ci.
:attr:`!dest_option` : :data:`types.UnicodeType`
    A name of the destination directory of dnf-stack-ci.

"""


from __future__ import absolute_import
from __future__ import unicode_literals

import os
import shutil
import subprocess
import tempfile

import pkg_resources
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
    src_spec = pkg_resources.resource_stream(
        dnfstackci.__name__, 'resources/foo.spec')
    dst_spec = open(os.path.join(context.titodn, 'foo.spec'), 'wb')
    with src_spec, dst_spec:
        shutil.copyfileobj(src_spec, dst_spec)
    try:
        repository = pygit2.init_repository(context.titodn)
        repository.index.add(
            os.path.relpath(dst_spec.name, repository.workdir))
        repository.index.write()
        repository.create_commit(
            'refs/heads/master', signature, signature, 'Add a spec file.',
            repository.index.write_tree(), [])
    # FIXME: https://github.com/libgit2/pygit2/issues/531
    except Exception:
        raise ValueError('Git repository creation failed')
    # FIXME: https://github.com/dgoodwin/tito/issues/171
    subprocess.check_call(['tito', 'init'], cwd=context.titodn)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
def before_feature(context, feature):  # pylint: disable=unused-argument
    """Do the preparation that must be done before every feature.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param feature: the next tested feature
    :type feature: behave.model.Feature

    """
    context.workdn = dnfstackci.decode_path(tempfile.mkdtemp())
    context.arch_option = 'x86_64'
    context.dest_option = context.workdn


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
def after_feature(context, feature):  # pylint: disable=unused-argument
    """Do the preparation that must be done after every feature.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param feature: the next tested feature
    :type feature: behave.model.Feature
    :raises exceptions.OSError: if the working directory cannot be
       removed

    """
    shutil.rmtree(context.workdn)


def after_all(context):
    """Do the cleanup that can be done at the very end.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.OSError: if the tito-enabled project cannot be
       removed

    """
    shutil.rmtree(context.titodn)
