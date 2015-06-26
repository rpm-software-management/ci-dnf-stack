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


def _rpm_headers(dirname):
    """Iterate over the headers of the RPMs in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: a generator yielding the RPM headers
    :rtype: generator[rpm.hdr]

    """
    filenames = glob.iglob(os.path.join(dirname, '*.rpm'))
    transaction = rpm.TransactionSet()
    for filename in filenames:
        try:
            with open(filename) as file_:
                header = transaction.hdrFromFdno(file_.fileno())
        except (IOError, rpm.error):
            continue
        if not header.isSource():
            yield header


def _tito_rpm(dirname):
    """Get the RPM header of the tito-enabled project in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: the header of the RPM file
    :rtype: rpm.hdr | None

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we just find an RPM.
    return next(_rpm_headers(dirname), None)


def _librepo_rpms(dirname):
    """Get the headers of the RPMs of the librepo fork in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: a generator yielding the RPM headers
    :rtype: generator[rpm.hdr]

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we just find RPMs.
    return _rpm_headers(dirname)


def _libcomps_rpms(dirname):
    """Get the headers of the RPMs of the libcomps fork in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: a generator yielding the RPM headers
    :rtype: generator[rpm.hdr]

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we just find RPMs.
    return _rpm_headers(dirname)


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
        elif row[0] == '--add-non-rawhide' and len(row) == 2:
            context.nonrawhide_option.append(row[1])
        elif row[0] == '--add-rawhide' and len(row) == 1:
            context.rawhide_option = True
        elif row[0] == '--add-repository' and len(row) == 2:
            context.repo_option.append(row[1])
        elif row[0] == '--define' and len(row) == 3:
            context.def_option.append((row[1], row[2]))
        elif row[0] == '--root' and len(row) == 2:
            context.root_option = row[1]
        elif row[0] == '--release' and len(row) == 2:
            context.rel_option = row[1]
        else:
            raise NotImplementedError('configuration not supported')


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.given(  # pylint: disable=no-member
    '“$URL” is replaced with the URL of a testing repository in all options')
def _assign_substitution(context):
    """Assign a value that should replace a value in all options.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context

    """
    context.substitute = True


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.when('I build RPMs of the {project}')  # pylint: disable=no-member
def _build_rpms(context, project):
    """Build RPMs of a project.

    The "createrepo_c", "mock", "python" and "tito" executables must be
    available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param project: a description of the project
    :type project: unicode
    :raises exceptions.OSError: if the executable cannot be executed
    :raises subprocess.CalledProcessError: if the build fails

    """
    old = '$URL'
    new = context.repourl if context.substitute else old
    cmdline = [
        'python', os.path.abspath('dnfstackci.py'),
        context.arch_option.replace(old, new),
        context.dest_option.replace(old, new)]
    if project == 'tito-enabled project':
        for name, value in reversed(context.def_option):
            cmdline.insert(2, value.replace(old, new))
            cmdline.insert(2, name.replace(old, new))
            cmdline.insert(2, '--define')
        cmdline.insert(2, 'tito')
        cwd = context.titodn
    elif project == 'librepo project fork':
        cmdline.insert(4, '38f323b94ea6ba3352827518e011d818202167a3')
        if context.rel_option:
            cmdline.insert(2, context.rel_option)
            cmdline.insert(2, '--release')
        cmdline.insert(2, 'librepo')
        cwd = context.librepodn
    elif project == 'libcomps project fork':
        if context.rel_option:
            cmdline.insert(2, context.rel_option)
            cmdline.insert(2, '--release')
        cmdline.insert(2, 'libcomps')
        cwd = context.libcompsdn
    else:
        raise NotImplementedError('project not supported')
    if context.root_option:
        cmdline.insert(2, context.root_option.replace(old, new))
        cmdline.insert(2, '--root')
    for url in reversed(context.repo_option):
        cmdline.insert(2, url.replace(old, new))
        cmdline.insert(2, '--add-repository')
    if context.rawhide_option:
        cmdline.insert(2, '--add-rawhide')
    for version in reversed(context.nonrawhide_option):
        cmdline.insert(2, version.replace(old, new))
        cmdline.insert(2, '--add-non-rawhide')
    subprocess.check_call(cmdline, cwd=cwd)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then('I should have RPMs of the {project}')  # pylint: disable=E1101
def _test_rpms(context, project):
    """Test whether the work dir. contains binary RPMs of a project.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param project: a description of the project
    :type project: unicode
    :raises exceptions.AssertionError: if the test fails

    """
    dirname = os.path.join(context.workdn, 'packages')
    if project == 'tito-enabled project':
        headers = [_tito_rpm(dirname)]
        assert headers[0], 'no readable binary RPM found'
    elif project == 'librepo fork':
        headers = list(_librepo_rpms(dirname))
        assert headers, 'readable binary RPMs not found'
    elif project == 'libcomps fork':
        headers = list(_libcomps_rpms(dirname))
        assert headers, 'readable binary RPMs not found'
    else:
        raise NotImplementedError('project not supported')
    rpmnevras = {
        (header[rpm.RPMTAG_N], str(header[rpm.RPMTAG_EPOCHNUM]),
         header[rpm.RPMTAG_V], header[rpm.RPMTAG_R], header[rpm.RPMTAG_ARCH])
        for header in headers}
    repository = createrepo_c.Metadata()
    # FIXME: https://github.com/Tojaj/createrepo_c/issues/29
    # noinspection PyBroadException
    try:
        repository.locate_and_load_xml(dirname)
    except Exception:  # pylint: disable=broad-except
        assert False, 'no readable repository found'
    reponevras = {
        (pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch)
        for pkg in (repository.get(key) for key in repository.keys())}
    assert rpmnevras <= reponevras, 'repository not correct'


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    "I should have the result that is produced if config_opts['target_arch'] "
    "== 'i686'")
def _test_architecture(context):  # pylint: disable=unused-argument
    """Test whether the result is affected by a Mock's "target_arch".

    :param context: the context as described in the environment file
    :type context: behave.runner.Context

    """
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.
    pass


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

    """
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1230749
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.
    pass


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have the result that is produced if %{{snapshot}} == '
    "'.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'")
def _test_rpmmacros(context):
    """Test whether the result is affected by RPM macro definitions.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.AssertionError: if the test fails

    """
    release = b'.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'
    header = _tito_rpm(os.path.join(context.workdn, 'packages'))
    assert header, 'no readable binary RPM found'
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1205830
    assert release in header[rpm.RPMTAG_RELEASE], 'macro not defined'


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    "I should have the result that is produced if config_opts['root'] == "
    "'test-hawkey-x86_64-rawhide'")
def _test_root(context):  # pylint: disable=unused-argument
    """Test whether the result is affected by a Mock's "root".

    :param context: the context as described in the environment file
    :type context: behave.runner.Context

    """
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.
    pass


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'the release number of the resulting RPMs of the {project} fork should be '
    '99.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm')
def _test_release(context, project):
    """Test whether the result is affected by RPM macro definitions.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param project: a description of the project
    :type project: unicode
    :raises exceptions.AssertionError: if the test fails

    """
    rpmsdn = os.path.join(context.workdn, 'packages')
    if project == 'librepo':
        headers = _librepo_rpms(rpmsdn)
    elif project == 'libcomps':
        headers = _libcomps_rpms(rpmsdn)
    else:
        raise NotImplementedError('project not supported')
    headers = list(headers)
    assert headers, 'readable binary RPMs not found'
    release = b'99.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'
    assert all(header[rpm.RPMTAG_RELEASE] == release for header in headers)
