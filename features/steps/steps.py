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

import os
import subprocess

import behave
import copr
import createrepo_c
import rpm

import dnfstackci


def _run_ci(args, cwd=None):
    """Run dnfstackci.py from command line.

    The "createrepo_c", "mock", "python" and "tito" executables must be
    available.

    :param args: additional command line arguments
    :type args: list[unicode]
    :param cwd: a name of the desired working directory
    :type cwd: unicode | None
    :raises exceptions.OSError: if an executable cannot be executed
    :raises subprocess.CalledProcessError: if the script fails

    """
    subprocess.check_call(
        ['python', os.path.abspath('dnfstackci.py')] + args, cwd=cwd)


def _run_setup(name, chroots, repos=()):
    """Run the setup command of dnfstackci.py from command line.

    The "createrepo_c", "mock", "python" and "tito" executables must be
    available.

    :param name: a name of the project
    :type name: unicode
    :param chroots: names of the chroots to be used in the project
    :type chroots: collections.Iterable[unicode]
    :param repos: the URL of each additional repository that is required
    :type repos: collections.Iterable[unicode]
    :raises exceptions.OSError: if an executable cannot be executed
    :raises subprocess.CalledProcessError: if the command fails

    """
    args = ['setup'] + list(chroots) + [name]
    for url in repos:
        args.insert(1, url)
        args.insert(1, '--add-repository')
    _run_ci(args)


def _libcomps_rpms(dirname):
    """Get the headers of the RPMs of the libcomps fork in a directory.

    :param dirname: a name of the directory
    :type dirname: unicode
    :return: a generator yielding the RPM headers
    :rtype: generator[rpm.hdr]

    """
    # There is no reliable way how to test whether given RPMs were build
    # from given sources. Thus we just find RPMs.
    return (
        pair[1] for pair in dnfstackci.rpm_headers(dirname)
        if not pair[1].isSource())


@behave.given('a Copr project {name} exists')  # pylint: disable=no-member
def _prepare_copr(context, name):
    """Prepare a Copr project.

    The "createrepo_c", "mock", "python" and "tito" executables must be
    available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param name: a name of the project
    :type name: unicode
    :raises exceptions.OSError: if an executable cannot be executed
    :raises subprocess.CalledProcessError: if the creation fails

    """
    _run_setup(name, ['rawhide'])
    context.temp_coprs.add(name)


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
        if row[0] == 'CHROOT' and len(row) == 2:
            context.chr_option.append(row[1])
        elif row[0] == 'PROJECT' and len(row) == 2:
            context.proj_option = row[1]
        elif row[0] == '--add-repository' and len(row) == 2:
            context.repo_option.append(row[1])
        elif row[0] == '--release' and len(row) == 2:
            context.rel_option = row[1]
        elif row[0] == 'ARCHITECTURE' and len(row) == 2:
            context.arch_option = row[1]
        elif row[0] == '--add-non-rawhide' and len(row) == 2:
            context.nonrawhide_option.append(row[1])
        elif row[0] == '--add-rawhide' and len(row) == 1:
            context.rawhide_option = True
        elif row[0] == '--root' and len(row) == 2:
            context.root_option = row[1]
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
@behave.when('I create a Copr project')  # pylint: disable=no-member
def _create_copr(context):
    """Create a Copr project.

    The "createrepo_c", "mock", "python" and "tito" executables must be
    available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.OSError: if an executable cannot be executed
    :raises subprocess.CalledProcessError: if the creation fails

    """
    old = '$URL'
    new = context.repourl if context.substitute else old
    name = context.proj_option.replace(old, new)
    _run_setup(
        name, context.chr_option,
        (url.replace(old, new) for url in reversed(context.repo_option)))
    context.temp_coprs.add(name)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.when('I build RPMs of the {project}')  # pylint: disable=no-member
def _build_rpms(context, project):
    """Build RPMs of a project.

    The "createrepo_c", "git", "mock", "python", "rpmbuild", "sh",
    "tito" and "xz" executables must be available.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param project: a description of the project
    :type project: unicode
    :raises exceptions.OSError: if the executable cannot be executed
    :raises subprocess.CalledProcessError: if the build fails

    """
    old = '$URL'
    new = context.repourl if context.substitute else old
    args = ['build']
    if project in {'tito-enabled project', 'librepo project fork'}:
        args.insert(1, context.proj_option.replace(old, new))
        if project == 'tito-enabled project':
            args.insert(1, 'tito')
            cwd = context.titodn
        elif project == 'libcomps project fork':
            args.insert(2, '38f323b94ea6ba3352827518e011d818202167a3')
            if context.rel_option:
                args.insert(1, context.rel_option)
                args.insert(1, '--release')
            args.insert(1, 'librepo')
            cwd = context.librepodn
    elif project == 'libcomps project fork':
        args.insert(1, context.dest_option.replace(old, new))
        args.insert(1, context.arch_option.replace(old, new))
        if context.rel_option:
            args.insert(1, context.rel_option)
            args.insert(1, '--release')
        if context.root_option:
            args.insert(1, context.root_option.replace(old, new))
            args.insert(1, '--root')
        for url in reversed(context.repo_option):
            args.insert(1, url.replace(old, new))
            args.insert(1, '--add-repository')
        if context.rawhide_option:
            args.insert(1, '--add-rawhide')
        for version in reversed(context.nonrawhide_option):
            args.insert(1, version.replace(old, new))
            args.insert(1, '--add-non-rawhide')
        args.insert(1, 'libcomps')
        cwd = context.libcompsdn
    else:
        raise NotImplementedError('project not supported')
    _run_ci(args, cwd)


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have a Copr project called {name} with chroots {chroots}')
def _test_copr_project(context, name, chroots):  # pylint: disable=W0613
    """Test whether a Copr project exists.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param name: the name of the project
    :type name: unicode
    :param chroots: names of the chroots to be used in the project
    :type chroots: unicode
    :raises exceptions.ValueError: if the details of the project cannot
       be retrieved

    """
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
    try:
        client = copr.client.CoprClient.create_from_file_config()
        client.get_project_details(name)
    except Exception:
        raise ValueError('Copr failed')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259608


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have the {repository} repository added to the Copr project '
    'called {name}')
def _test_copr_repo(context, repository, name):  # pylint: disable=W0613
    """Test whether a repository has been added to a Copr project.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :param repository: the URL of the repository
    :type repository: unicode
    :param name: the name of the project
    :type name: unicode
    :raises exceptions.AssertionError: if the test fails

    """
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
    try:
        client = copr.client.CoprClient.create_from_file_config()
        details = client.get_project_details(name)
    except Exception:
        raise ValueError('Copr failed')
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259683
    repos = details.data['detail']['additional_repos'].split(' ')
    assert repository in repos, 'repository not added'


@behave.then('the build should have succeeded')  # pylint: disable=no-member
def _test_success(context):  # pylint: disable=unused-argument
    """Test whether the preceding build have succeeded.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context

    """
    # Behave would fail otherwise so the build must have succeeded if we
    # are here.
    pass


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    'I should have RPMs of the libcomps fork')
def _test_libcomps(context):
    """Test whether the work dir. contains binary RPMs of libcomps.

    :param context: the context as described in the environment file
    :type context: behave.runner.Context
    :raises exceptions.AssertionError: if the test fails

    """
    dirname = os.path.join(context.workdn, 'packages')
    rpmnevras = {
        (header[rpm.RPMTAG_N], str(header[rpm.RPMTAG_EPOCHNUM]),
         header[rpm.RPMTAG_V], header[rpm.RPMTAG_R], header[rpm.RPMTAG_ARCH])
        for header in _libcomps_rpms(dirname)}
    assert rpmnevras, 'readable binary RPMs not found'
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
    # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1228751
    # There is no way how to test whether the RPMs were built using the
    # given option since it's not specified what the option does.
    pass


# FIXME: https://bitbucket.org/logilab/pylint/issue/535
@behave.then(  # pylint: disable=no-member
    "I should have the result that is produced if config_opts['root'] == "
    "'test-libcomps-x86_64-rawhide'")
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
        # FIXME: https://bugzilla.redhat.com/show_bug.cgi?id=1259293
        # There is no documented way how to obtain the RPMs.
        return
    elif project == 'libcomps':
        headers = _libcomps_rpms(rpmsdn)
    else:
        raise NotImplementedError('project not supported')
    headers = list(headers)
    assert headers, 'readable binary RPMs not found'
    release = b'99.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'
    assert all(header[rpm.RPMTAG_RELEASE] == release for header in headers)
