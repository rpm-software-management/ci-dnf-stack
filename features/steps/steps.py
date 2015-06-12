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

"""This module implements the feature steps."""


from __future__ import absolute_import
from __future__ import unicode_literals

import glob
import os
import subprocess

import behave
import createrepo_c
import rpm


def _rpm_header(dirname):
    """Get the header of the RPM of the testing project in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: the header of the RPM file
    :rtype: rpm.hdr | None

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we just find an RPM.
    filenames = glob.iglob(os.path.join(dirname, '*.rpm'))
    transaction = rpm.TransactionSet()
    for filename in filenames:
        try:
            with open(filename) as file_:
                header = transaction.hdrFromFdno(file_.fileno())
        except (IOError, rpm.error):
            continue
        if not header.isSource():
            return header
    return None


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.given(  # pylint: disable=no-member
    'following options are configured as follows')
def _configure_options(context):
    """Configure the user-defined options.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.ValueError: if the context has no table

    """
    if not context.table:
        raise ValueError('table not found')
    expected = [
        ['Option'], ['Option', 'Value'], ['Option', 'Value #1', 'Value #2']]
    if context.table.headings not in expected:
        raise NotImplementedError('configuration format not supported')
    for row in context.table:
        if row[0] == 'ARCHITECTURE' and len(row) == 2:
            context.arch_option = row[1]
        elif row[0] == '--fedora' and len(row) == 2:
            context.fedora_option = row[1]
        elif row[0] == '--add-non-rawhide' and len(row) == 2:
            context.nonrawhide_option.append(row[1])
        elif row[0] == '--add-rawhide' and len(row) == 1:
            context.rawhide_option = True
        elif row[0] == '--define' and len(row) == 3:
            context.def_option.append((row[1], row[2]))
        else:
            raise NotImplementedError('configuration not supported')


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.when('I execute this program')  # pylint: disable=no-member
# FIXME: https://bitbucket.org/logilab/pylint/issue/535
def _execute(context):  # pylint: disable=unused-argument
    """Execute this program.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context

    """
    # So far, it's easier to execute the program in the "then" clause.
    pass


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.when(  # pylint: disable=no-member
    'I build RPMs of the tito-enabled project')
def _build_tito_rpms(context):
    """Build RPMs of the tito-enabled project.

    The "python" executable must be available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.OSError: if the executable cannot be executed
    :raises subprocess.CalledProcessError: if the build fails

    """
    cmdline = [
        'python', os.path.abspath('dnfstackci.py'), context.arch_option,
        context.dest_option]
    for name, value in reversed(context.def_option):
        cmdline.insert(2, value)
        cmdline.insert(2, name)
        cmdline.insert(2, '--define')
    if context.rawhide_option:
        cmdline.insert(2, '--add-rawhide')
    for version in reversed(context.nonrawhide_option):
        cmdline.insert(2, version)
        cmdline.insert(2, '--add-non-rawhide')
    if context.fedora_option is not None:
        cmdline.insert(2, context.fedora_option)
        cmdline.insert(2, '--fedora')
    subprocess.check_call(cmdline, cwd=context.titodn)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have RPMs of the tito-enabled project')
def _test_rpms(context):
    """Test whether the work dir. contains binary RPMs of a project.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.AssertionError: if the test fails

    """
    dirname = os.path.join(context.workdn, 'packages')
    header = _rpm_header(dirname)
    assert header, 'no readable binary RPM found'
    rpmnevra = (
        header[rpm.RPMTAG_N], str(header[rpm.RPMTAG_EPOCHNUM]),
        header[rpm.RPMTAG_V], header[rpm.RPMTAG_R], header[rpm.RPMTAG_ARCH])
    repository = createrepo_c.Metadata()
    # FIXME: https://github.com/Tojaj/createrepo_c/issues/29
    # noinspection PyBroadException
    try:
        repository.locate_and_load_xml(dirname)
    except Exception:  # pylint: disable=broad-except
        assert False, 'no readable repository found'
    reponevras = (
        (pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch)
        for pkg in (repository.get(key) for key in repository.keys()))
    assert rpmnevra in reponevras, 'repository not correct'


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    "I should have the result that is produced if config_opts['target_arch'] "
    "== 'i686'")
def _test_architecture(context):
    """Test whether the result is affected by a Mock's "target_arch".

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.ValueError: if the result cannot be obtained or
       if the test fails

    """
    try:
        context.execute_steps("""
            When I build RPMs of the tito-enabled project
            Then I should have RPMs of the tito-enabled project""")
    # FIXME: https://github.com/behave/behave/issues/308
    except Exception:
        raise ValueError('execution failed')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then('I should have the result for Fedora 22')  # pylint: disable=E1101
def _test_releasever(context):
    """Test whether the result is for Fedora 22.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.ValueError: if the result cannot be obtained
    :raises exceptions.AssertionError: if the test fails

    """
    try:
        context.execute_steps('When I build RPMs of the tito-enabled project')
    # FIXME: https://github.com/behave/behave/issues/308
    except Exception:
        raise ValueError('execution failed')
    header = _rpm_header(os.path.join(context.workdn, 'packages'))
    assert header, 'no readable binary RPM found'
    expected = {b'/usr/share/foo/fedora', b'/usr/share/foo/22'}
    assert set(header[rpm.RPMTAG_FILENAMES]) >= expected, 'RPM not for F22'


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    "I should have the result that is produced if config_opts['yum.conf'] "
    'contains the {repository} repository')
def _test_repository(context, repository):  # pylint: disable=unused-argument
    """Test whether the result is affected by a repo. in "yum.conf".

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param repository: a name of the repository
    :type repository: unicode
    :raises exceptions.ValueError: if the result cannot be obtained or
       if the test fails

    """
    try:
        context.execute_steps("""
            When I build RPMs of the tito-enabled project
            Then I should have RPMs of the tito-enabled project""")
    # FIXME: https://github.com/behave/behave/issues/308
    except Exception:
        raise ValueError('execution failed')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1230749
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have the result that is produced if %{{snapshot}} == '
    "'.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'")
def _test_rpmmacros(context):
    """Test whether the result is affected by RPM macro definitions.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.ValueError: if the result cannot be obtained
    :raises exceptions.AssertionError: if the test fails

    """
    release = b'.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'
    try:
        context.execute_steps('When I build RPMs of the tito-enabled project')
    # FIXME: https://github.com/behave/behave/issues/308
    except Exception:
        raise ValueError('execution failed')
    header = _rpm_header(os.path.join(context.workdn, 'packages'))
    assert header, 'no readable binary RPM found'
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1205830
    assert release in header[rpm.RPMTAG_RELEASE], 'macro not defined'
