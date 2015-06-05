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
@behave.when(  # pylint: disable=no-member
    'I build RPMs of the tito-enabled project')
def _build_tito_rpms(context):
    """Build RPMs of the tito-enabled project.

    The "python" executable must be available.

    :raises exceptions.OSError: if the executable cannot be executed
    :raises subprocess.CalledProcessError: if the build fails

    """
    subprocess.check_call(
        [b'python', os.path.abspath(b'dnfstackci.py'), context.workdn],
        cwd=context.titodn)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have RPMs of the tito-enabled project')
def _test_rpms(context):
    """Test whether the work dir. contains binary RPMs of a project.

    :raises exceptions.AssertionError: if the test fails

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we test just whether there are some RPMs.
    filenames = glob.iglob(os.path.join(context.workdn, b'packages', b'*.rpm'))
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
