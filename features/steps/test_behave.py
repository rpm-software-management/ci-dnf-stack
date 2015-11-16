#!/usr/bin/python -tt

from behave import *
import os
import subprocess
import glob
import re
import shutil

DNF_FLAGS = ['-y', '--disablerepo=*', '--nogpgcheck']
RPM_INSTALL_FLAGS = ['-Uvh']
RPM_ERASE_FLAGS = ['-e']


def _left_decorator(item):
    """ Removed packages """
    return u'-' + item


def _right_decorator(item):
    """ Installed packages """
    return u'+' + item


def find_pkg(pkg):
    """ Find the package file in the repository """
    candidates = glob.glob('/repo/' + pkg + '*.rpm')
    if len(candidates) == 0:
        print("No candidates for: '{0}'".format(pkg))
    assert len(candidates) == 1
    return candidates[0]


def decorate_rpm_packages(pkgs):
    """ Converts package names like TestA, TestB into absolute paths """
    return [find_pkg(p) for p in pkgs]


def get_rpm_package_list():
    """ Gets all installed packages in the system """
    pkgstr = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}\n'])
    return pkgstr.splitlines()


def get_rpm_package_version_list():
    """ Gets all installed packages in the system with version"""
    pkgverstr = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}-%{VERSION}-%{RELEASE}\n'])
    return pkgverstr.splitlines()


def get_dnf_package_version_list():
    """ Gets all installed packages in the system with version to check that dnf has same data about installed packages"""
    pkgverstr = subprocess.check_output(['dnf', 'repoquery', '--installed', '-Cq', '--queryformat', '%{name}.%{version}.%{release}\n'])
    pkgverstr = pkgverstr.splitlines()
    return pkgverstr


def diff_package_lists(a, b):
    """ Computes both left/right diff between lists `a` and `b` """
    sa, sb = set(a), set(b)
    return (map(_left_decorator, list(sa - sb)),
        map(_right_decorator, list(sb - sa)))


def package_version_lists(pkg, list_ver):
    """ Select package versions """
    found_pkgs = [x for x in list_ver if re.search('^' + pkg, x)]
    assert len(found_pkgs) == 1
    return str(found_pkgs[0])


def package_absence(pkg, list_ver):
    """ Select package versions """
    found_pkgs = [x for x in list_ver if re.search('^' + pkg, x)]
    assert len(found_pkgs) == 0
    return None


def execute_dnf_command(cmd, reponame):
    """ Execute DNF command with default flags and the specified `reponame` enabled """
    flags = DNF_FLAGS + ['--enablerepo={0}'.format(reponame)]
    return subprocess.check_call(['dnf'] + flags + cmd, stdout=subprocess.PIPE)


def execute_rpm_command(pkg, action):
    """ Execute given action over specified pkg(s) """
    if not isinstance(pkg, list):
        pkg = [pkg]
    if action == "remove":
        action = RPM_ERASE_FLAGS
    elif action == "install":
        action = RPM_INSTALL_FLAGS
        pkg = decorate_rpm_packages(pkg)
    return subprocess.check_call(['rpm'] + action + pkg, stdout=subprocess.PIPE)


def piecewise_compare(a, b):
    """ Check if the two sequences are identical regardless of ordering """
    return sorted(a) == sorted(b)


def split(pkg):
    return [p.strip() for p in pkg.split(',')]


@given('I use the repository "{repo}"')
def given_repo_condition(context, repo):
    """ :type context: behave.runner.Context """
    assert repo
    context.repo = repo
    assert os.path.exists('/var/www/html/repo/' + repo)
    for root, dirs, files in os.walk('/repo'):
        for f in files:
    	    os.unlink(os.path.join(root, f))
        for d in dirs:
    	    shutil.rmtree(os.path.join(root, d))
    subprocess.check_call(['cp -rs /var/www/html/repo/' + repo + '/* /repo/'], shell=True)
    with open('/etc/yum.repos.d/' + repo + '.repo', 'w') as f:
        f.write('[' + repo + ']\nname=' + repo + '\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0')


@when('I "{action}" a package "{pkg}" with "{manager}"')
def when_action_package(context, action, pkg, manager):
    assert pkg
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    context.pre_dnf_packages_version = get_dnf_package_version_list()
    assert context.pre_dnf_packages_version
    if manager == 'rpm':
        if action in ["install", "remove"]:
            execute_rpm_command(split(pkg), action)
        else:
            raise AssertionError('The action {} is not allowed parameter with rpm manager'.format(action))
    elif manager == 'dnf':
        if action == 'upgrade':
            if pkg == 'all':
                execute_dnf_command([action], context.repo)
            else:
                execute_dnf_command([action] + split(pkg), context.repo)
        elif action == 'autoremove':
            subprocess.check_call(['dnf', '-y', action], stdout=subprocess.PIPE)
        elif action in ["install", "remove", "downgrade", "upgrade-to"]:
            execute_dnf_command([action] + split(pkg), context.repo)
        else:
            raise AssertionError('The action {} is not allowed parameter with dnf manager'.format(action))
    else:
        raise AssertionError('The manager {} is not allowed parameter'.format(manager))


@when('I execute command "{command}" with "{result}"')
def when_action_command(context, command, result):
    assert command
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    context.pre_dnf_packages_version = get_dnf_package_version_list()
    assert context.pre_dnf_packages_version
    cmd_output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    context.cmd_rc = cmd_output.returncode
    if result == "success":
        assert context.cmd_rc == 0
    elif result == "fail":
        assert context.cmd_rc != 0
    else:
        raise AssertionError('The option {} is not allowed option for expected result of command. '
                             'Allowed options are "success" and "fail"'.format(result))


@then('package "{pkg}" should be "{state}"')
def then_package_state(context, pkg, state):
    assert pkg
    pkgs_rpm = get_rpm_package_list()
    pkgs_rpm_ver = get_rpm_package_version_list()
    pkgs_dnf_ver = get_dnf_package_version_list()
    assert pkgs_rpm
    assert context.pre_rpm_packages
    removed, installed = diff_package_lists(context.pre_rpm_packages, pkgs_rpm)
    assert removed is not None and installed is not None
  
    for n in split(pkg):
        if state == 'installed':
            assert ('+' + n) in installed
            installed.remove('+' + n)
            post_rpm_present = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_present
            post_dnf_present = package_version_lists(n, pkgs_dnf_ver)
            assert post_dnf_present
        elif state == 'removed':
            assert ('-' + n) in removed
            removed.remove('-' + n)
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
            post_dnf_absence = package_absence(n, pkgs_dnf_ver)
            assert not post_dnf_absence
        elif state == 'absent':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
            post_dnf_absence = package_absence(n, pkgs_dnf_ver)
            assert not post_dnf_absence
        elif state == 'upgraded':
            pre_rpm_ver = package_version_lists(n, context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver > pre_rpm_ver
        elif state == 'unupgraded':
            pre_rpm_ver = package_version_lists(n, context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver == pre_rpm_ver
        elif state == 'downgraded':
            pre_rpm_ver = package_version_lists(n, context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver < pre_rpm_ver
        elif state == 'present':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
            post_rpm_present = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_present
            post_dnf_present = package_version_lists(n, pkgs_dnf_ver)
            assert post_dnf_present
        elif state == 'upgraded-to':
            assert n in package_version_lists(n, pkgs_rpm_ver)
        else:
            raise AssertionError('The state {} is not allowed option for Then statement'.format(state))

    """ This checks that installations/removals are always fully specified,
    so that we always cover the requirements/expecations entirely """
    if state in ["installed", "removed"]:
        assert not installed and not removed


@then('exit code of command should be equal to "{exit_code}"')
def then_package_state(context, exit_code):
    exit_code = int(exit_code)
    assert context.cmd_rc == exit_code
