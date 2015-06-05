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
import rpm


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
    if context.table.headings != ['Option', 'Value']:
        raise NotImplementedError('configuration format not supported')
    for option, value in context.table:
        if option == 'ARCHITECTURE':
            context.arch_option = value
        else:
            raise NotImplementedError('option not supported')


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
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we test just whether there are some RPMs.
    filenames = glob.iglob(os.path.join(context.workdn, 'packages', '*.rpm'))
    transaction = rpm.TransactionSet()
    for filename in filenames:
        try:
            with open(filename) as file_:
                header = transaction.hdrFromFdno(file_.fileno())
        except (IOError, rpm.error):
            continue
        if not header.isSource():
            return
    assert False, 'no readable binary RPM found'


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
