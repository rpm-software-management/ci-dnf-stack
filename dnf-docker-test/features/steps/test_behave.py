#!/usr/bin/python -tt

from behave import *
import dnf
import glob
import os
import re
import shutil
import subprocess
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
    comparerpmver = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n'])
    dnfverstr = subprocess.check_output(['dnf', 'repoquery', '--installed', '--disableexclude=all', '-Cq',
                                         '--queryformat', '%{name}-%{version}-%{release}.%{arch}'])
    comparerpmver = [p for p in comparerpmver.splitlines() if not p.decode().startswith('gpg-pubkey')]
    assert sorted(comparerpmver) == sorted(dnfverstr.splitlines())
    sack = dnf.Base().fill_sack(load_available_repos=False)
    list_sack = list(sack.query().installed())
    assert len(list_sack) == len(comparerpmver)
    comparerpmver_remove = list(comparerpmver)
    for pkg in comparerpmver:
        subj = dnf.subject.Subject(pkg)
        candidate = subj.get_best_query(sack)
        assert len(candidate) == 1
        list_sack.remove(candidate[0])
        comparerpmver_remove.remove(pkg)
    assert not list_sack
    assert not comparerpmver_remove
    return comparerpmver


def diff_package_lists(a, b):
    """ Computes both left/right diff between lists `a` and `b` """
    sa, sb = set(a), set(b)
    return (map(_left_decorator, list(sa - sb)),
        map(_right_decorator, list(sb - sa)))


def diff_query_lists(sack_a, sack_b):
    """ Computes diff between sack_a and sack_b """
    sa, sb = list(sack_a.query().installed()), list(sack_b.query().installed())
    rem = [x for x in sa if x not in sb]
    inst = [x for x in sb if x not in sa]
    return rem, inst


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


def ensure_path_exist(path):
    """Ensure that os path exist. If doesn't exist it create the path."""
    if not os.path.exists(path):
        os.makedirs(path)


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


def package_name_finder(sack, package_string):
    """
    @param sack: sack with packages
    @param package_string: package description in nevra format
    @return: name of package

    """
    subj = dnf.subject.Subject(package_string)
    candidate = subj.get_best_query(sack)
    assert len(candidate) == 1
    return candidate[0].name


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
    context.pre_sack = dnf.Base().fill_sack(load_available_repos=False)
    assert context.pre_sack
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


@step('I execute "{type_of_command}" command "{command}" with "{result}"')
def when_action_command(context, type_of_command, command, result):
    assert command
    context.pre_rpm_packages = get_rpm_package_list()
    assert context.pre_rpm_packages
    context.pre_rpm_packages_version = get_rpm_package_version_list()
    assert context.pre_rpm_packages_version
    dnf_command_version = context.config.userdata['dnf_command_version']
    assert dnf_command_version
    context.pre_sack = dnf.Base().fill_sack(load_available_repos=False)
    assert context.pre_sack
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
    ensure_path_exist(os.path.dirname(file_with_path))
    file_content = file_content.replace(u'\\n', u'\n')
    with open(file_with_path, 'w') as f:
        f.write(file_content + '\n')


@when('I copy plugin module "{plugin_modules}" from default plugin path into "{directory}"')
def when_plugin_dir_creator(context, plugin_modules, directory):
    """Create directory with list of plugins

    @param context: the context in which the function is called
    @param directory: pluginpath directory that will be created
    @param plugin_module: modules comma separated that will be copied into directory
    """
    with dnf.Base() as base:
        plugindn = base.conf.pluginpath[0]
    ensure_path_exist(directory)
    for module in splitter(plugin_modules):
        shutil.copy2(os.path.join(plugindn, module), directory)


@then('package "{pkgs}" should be "{state}"')
def then_package_state(context, pkgs, state):
    assert pkgs
    pkgs_rpm = get_rpm_package_list()
    pkgs_rpm_ver = get_rpm_package_version_list()
    post_sack = dnf.Base().fill_sack(load_available_repos=False)
    assert pkgs_rpm
    assert context.pre_rpm_packages
    removed, installed = diff_package_lists(context.pre_rpm_packages, pkgs_rpm)
    assert removed is not None and installed is not None
    removed_packages, installed_packages = diff_query_lists(context.pre_sack, post_sack)

    for n in splitter(pkgs):
        if state == 'installed':
            package_name = package_name_finder(post_sack, n)
            assert ('+' + package_name) in installed
            installed.remove('+' + package_name)
            for package in installed_packages:
                if n in '{}-{}-{}'.format(package.name, package.version, package.release):
                    installed_packages.remove(package)
                    break

            post_rpm_present = package_version_lists(n, pkgs_rpm_ver)
            assert post_rpm_present
        elif state == 'removed':
            package_name = package_name_finder(context.pre_sack, n)
            assert ('-' + n) in removed
            removed.remove('-' + n)
            for package in removed_packages:
                if n in '{}-{}-{}'.format(package.name, package.version, package.release):
                    removed_packages.remove(package)
                    break
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
        elif state == 'absent':
            assert ('+' + n) not in installed
            assert ('-' + n) not in removed
            post_rpm_absence = package_absence(n, pkgs_rpm_ver)
            assert not post_rpm_absence
        elif state == 'upgraded':
            package_name = package_name_finder(post_sack, n)
            pre_rpm_ver = package_version_lists(package_name, context.pre_rpm_packages_version)
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
            package_name = package_name_finder(post_sack, n)
            pre_rpm_ver = package_version_lists(package_name, context.pre_rpm_packages_version)
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
        assert not installed_packages and not removed_packages


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


@then('the path "{path_to_object}" should be "{state}"')
def then_file_presence(context, path_to_object, state):
    assert path_to_object, "The path was not specified"
    if path_to_object.endswith('/'):
        result = os.path.isdir(path_to_object)
    elif path_to_object.endswith('/*'):
        result = glob.glob(path_to_object)
    else:
        result = os.path.isfile(path_to_object)
    if state == 'present':
        assert result
    elif state == 'absent':
        assert not result
    else:
        raise AssertionError('The state {} is not allowed option for Then statement (allowed present, absent)'
                             .format(state))


@then('the file "{path_to_file}" should contain "{content}"')
def then_file_contein(context, path_to_file, content):
    assert os.path.isfile(path_to_file), "The file {} is not a file or doesn't exist".format(path_to_file)
    with open(path_to_file, 'r') as f:
        assert content in f, "The file {} doesn't contain '{}'".format(path_to_file, content)

