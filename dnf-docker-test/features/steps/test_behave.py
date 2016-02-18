#!/usr/bin/python -tt

from behave import *
import os
import subprocess
import glob
import re
import shutil
from time import sleep

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
    dnfverstr = subprocess.check_output(['dnf', 'repoquery', '--installed', '--disableexclude=all', '-Cq', '--queryformat',
                                         '%{name}-%{version}-%{release}'])
    pkgverstr = pkgverstr.splitlines()
    comparerpmver = pkgverstr
    for pkg in comparerpmver:
        if pkg.decode().startswith('gpg-pubkey'):
            comparerpmver.remove(pkg)
    assert sorted(comparerpmver) == sorted(dnfverstr.splitlines())
    return pkgverstr


def diff_package_lists(a, b):
    """ Computes both left/right diff between lists `a` and `b` """
    sa, sb = set(a), set(b)
    return (map(_left_decorator, list(sa - sb)),
        map(_right_decorator, list(sb - sa)))


def package_version_lists(pkg, list_ver):
    """ Select package versions """
    found_pkgs = [x for x in list_ver if x.startswith(pkg)]
    assert len(found_pkgs) == 1
    return str(found_pkgs[0])


def package_absence(pkg, list_ver):
    """ Select package versions """
    found_pkgs = [x for x in list_ver if re.search('^' + pkg, x)]
    assert len(found_pkgs) == 0
    return None


def execute_dnf_command(dnf_command_version, cmd, reponame):
    """ Execute DNF command with default flags and the specified `reponame` enabled """
    flags = DNF_FLAGS + ['--enablerepo={0}'.format(reponame)]
    subprocess.check_call([dnf_command_version] + flags + cmd, stdout=subprocess.PIPE)
    return sleep(1)


def execute_rpm_command(pkg, action):
    """ Execute given action over specified pkg(s) """
    if not isinstance(pkg, list):
        pkg = [pkg]
    if action == "remove":
        rpm_command = RPM_ERASE_FLAGS
    elif action == "install":
        rpm_command = RPM_INSTALL_FLAGS
        pkg = decorate_rpm_packages(pkg)
    subprocess.check_call(['rpm'] + rpm_command + pkg, stdout=subprocess.PIPE)
    return sleep(1)


def piecewise_compare(a, b):
    """ Check if the two sequences are identical regardless of ordering """
    return sorted(a) == sorted(b)


def splitter(pkgs):
    return [p.strip() for p in pkgs.split(',')]


@given('I use the repository "{repo}"')
def given_repo_condition(context, repo):
    """ :type context: behave.runner.Context """
    assert repo
    context.repo = repo
    for file in glob.glob('/etc/yum.repos.d/*.repo'):
        os.remove(file)
    assert os.path.exists('/var/www/html/repo/' + repo)
    for root, dirs, files in os.walk('/repo'):
        for f in files:
            os.unlink(os.path.join(root, f))
        for d in dirs:
            shutil.rmtree(os.path.join(root, d))
    subprocess.check_call(['cp -rs /var/www/html/repo/' + repo + '/* /repo/'], shell=True)
    with open('/etc/yum.repos.d/' + repo + '.repo', 'w') as f:
        f.write('[' + repo + ']\nname=' + repo + '\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0')


@when('I "{action}" a package "{pkgs}" with "{manager}"')
def when_action_package(context, action, pkgs, manager):
    assert pkgs
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    dnf_command_version = context.config.userdata['dnf_command_version']
    assert dnf_command_version
    if manager == 'rpm':
        if action in ["install", "remove"]:
            execute_rpm_command(splitter(pkgs), action)
        else:
            raise AssertionError('The action {} is not allowed parameter with rpm manager'.format(action))
    elif manager == 'dnf':
        if action == 'upgrade':
            if pkgs == 'all':
                execute_dnf_command(dnf_command_version, [action], context.repo)
            else:
                execute_dnf_command(dnf_command_version, [action] + splitter(pkgs), context.repo)
        elif action == 'autoremove':
            subprocess.check_call([dnf_command_version, '-y', action],
                                  stdout=subprocess.PIPE)
            sleep(1)
        elif action in ["install", "remove", "downgrade", "upgrade-to"]:
            execute_dnf_command(dnf_command_version, [action] + splitter(pkgs), context.repo)
        else:
            raise AssertionError('The action {} is not allowed parameter with dnf manager'.format(action))
    else:
        raise AssertionError('The manager {} is not allowed parameter'.format(manager))


@when('I execute "{type_of_command}" command "{command}" with "{result}"')
def when_action_command(context, type_of_command, command, result):
    assert command
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    dnf_command_version = context.config.userdata['dnf_command_version']
    assert dnf_command_version
    if type_of_command == 'dnf':
        dnf_command_version = dnf_command_version + " " + command
    elif type_of_command == 'bash':
        dnf_command_version = command
    else:
        raise AssertionError('The type of command {} is not allowed parameter (allowed: dnf, bash)'
                             .format(type_of_command))
    cmd_output = subprocess.Popen(
            dnf_command_version, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    context.cmd_output, context.cmd_error = cmd_output.communicate()
    context.cmd_rc = cmd_output.returncode
    if context.cmd_error:
        print(context.cmd_error)
    if result == "success":
        assert context.cmd_rc == 0
    elif result == "fail":
        assert context.cmd_rc != 0
    else:
        raise AssertionError('The option {} is not allowed option for expected result of command. '
                             'Allowed options are "success" and "fail"'.format(result))


@when('I create a file "{file_with_path}" with content: "{file_content}"')
def when_action_command(context, file_with_path, file_content):
    if not os.path.exists(os.path.dirname(file_with_path)):
        os.makedirs(os.path.dirname(file_with_path))
    file_content = file_content.replace(u'\\n', u'\n')
    with open(file_with_path, 'w') as f:
        f.write(file_content + '\n')


@then('package "{pkgs}" should be "{state}"')
def then_package_state(context, pkgs, state):
    assert pkgs
    pkgs_rpm = get_rpm_package_list()
    pkgs_rpm_ver = get_rpm_package_version_list()
    assert pkgs_rpm
    assert context.pre_rpm_packages
    removed, installed = diff_package_lists(context.pre_rpm_packages, pkgs_rpm)
    assert removed is not None and installed is not None
  
    for n in splitter(pkgs):
        if state == 'installed':
            assert ('+' + n.split('-', 1)[0]) in installed
            installed.remove('+' + n.split('-', 1)[0])
            post_rpm_present = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_present
        elif state == 'removed':
            assert ('-' + n) in removed
            removed.remove('-' + n)
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
        elif state == 'absent':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
        elif state == 'upgraded':
            pre_rpm_ver = package_version_lists(n.split('-', 1)[0], context.pre_rpm_packages_version)
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
            pre_rpm_ver = package_version_lists(n.split('-', 1)[0], context.pre_rpm_packages_version)
            post_rpm_ver = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_ver
            assert pre_rpm_ver
            assert post_rpm_ver < pre_rpm_ver
        elif state == 'present':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
            post_rpm_present = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_present

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

@then('line from "{std_message}" should "{state}" with "{line_start}"')
def then_package_state(context, std_message, state, line_start):
    counter = 0
    if std_message == 'stdout':
        message = context.cmd_output.split('\n')
    elif std_message == 'stderr':
        message = context.cmd_error.split('\n')
    else:
        raise AssertionError('The std_message {} is not allowed option for Then statement (allowed stdout, stderr)'
                             .format(std_message))
    for line in message:
        if line.startswith(line_start):
            counter += 1
    if state == 'start':
        assert counter > 0
    elif state == 'not start':
        assert counter == 0
    else:
        raise AssertionError('The state {} is not allowed option for Then statement (allowed start, not start)'
                             .format(state))


@then('the file "{path_to_file}" should be "{state}"')
def then_file_presence(context, path_to_file, state):
    file_existence = os.path.isfile(path_to_file)
    if state == 'present':
        assert file_existence
    elif state == 'absent':
        assert not file_existence
    else:
        raise AssertionError('The state {} is not allowed option for Then statement (allowed present, absent)'
                             .format(state))


@then('the file "{path_to_file}" should contain "{content}"')
def then_file_contein(context, path_to_file, content):
    assert os.path.isfile(path_to_file), "The file {} is not a file or doesn't exist".format(path_to_file)
    with open(path_to_file, 'r') as f:
        assert content in f, "The file {} doesn't contain '{}'".format(path_to_file, content)

