#!/usr/bin/python -tt

from behave import *
import os
import subprocess
import glob
import re

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
    pkgverstr = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}.%{VERSION}.%{RELEASE}\n'])
    return pkgverstr.splitlines()


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
    a = [os.remove(p) for p in os.listdir('/repo')]
    subprocess.check_call(['cp -rs /var/www/html/repo/' + repo + '/* /repo/'], shell=True)
    with open('/etc/yum.repos.d/' + repo + '.repo', 'w') as f:
        f.write('[' + repo + ']\nname=' + repo + '\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0')


@when('I "{action}" a package "{pkg}" with "{manager}"')
def when_action_package(context, action, pkg, manager):
    assert action in ["install", "remove", "upgrade"]
    assert manager in ["rpm", "dnf", "pkcon"]
    assert pkg
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    if manager == 'rpm':
        execute_rpm_command(split(pkg), action)
    elif manager == 'dnf':
        if action == 'upgrade':
            if pkg == 'all':
                execute_dnf_command([action], context.repo)
            else:
                execute_dnf_command([action] + split(pkg), context.repo)
        else:
            execute_dnf_command([action] + split(pkg), context.repo)


@then('package "{pkg}" should be "{state}"')
def then_package_state(context, pkg, state):
    assert state in ["installed", "removed", "absent", "upgraded", 'unupgraded']
    assert pkg
    pkgs_rpm = get_rpm_package_list()
    pkgs_rpm_ver = get_rpm_package_version_list()
    assert pkgs_rpm
    assert context.pre_rpm_packages
    removed, installed = diff_package_lists(context.pre_rpm_packages, pkgs_rpm)
    assert removed != None and installed != None
  
    for n in split(pkg):
        if state == 'installed':
            assert ('+' + n) in installed
            installed.remove('+' + n)
        if state == 'removed':
            assert ('-' + n) in removed
            removed.remove('-' + n)
        if state == 'absent':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
        if state == 'upgraded':
            pre_rpm_ver = package_version_lists(n, context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver > pre_rpm_ver
        if state == 'unupgraded':
            pre_rpm_ver = package_version_lists(n, context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver == pre_rpm_ver

    """ This checks that installations/removals are always fully specified,
    so that we always cover the requirements/expecations entirely """
    if state != 'absent':
        assert not installed and not removed
