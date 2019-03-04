#!/usr/bin/python -tt

from behave import *
import dnf
import glob
import re
import os
import shutil
import subprocess
import time


def sack_rpm_comparator():
    """ Gets all installed packages in the system, compare rpm output with DNF sack, and return sack"""
    comparerpmver = shell_call(['rpm', '-qa', '--queryformat',
                                '%{NAME}-%|epoch?{%{epoch}:}:{0:}|%{VERSION}-%{RELEASE}.%{ARCH}\n'])
    comparerpmver = [p for p in comparerpmver.splitlines() if not p.startswith('gpg-pubkey')]
    set_comparerpmver = set(comparerpmver)
    assert len(comparerpmver) == len(set_comparerpmver), 'RPM found multiple packages with same nevra'
    sack = dnf.Base().fill_sack(load_available_repos=False)
    list_sack = ['{}-{}:{}-{}.{}'.format(pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch
                                         ) for pkg in sack.query().installed()]
    set_sack = set(list_sack)
    assert len(set_sack) == len(list_sack), 'DNF sack has multiple packages with same nevra'
    assert set_sack == set_comparerpmver, 'There are different items in DNF sack and RPM-db'
    return sack


def shell_call(list_command):
    cmd_output = subprocess.Popen(list_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    output, error = cmd_output.communicate()
    if error:
        print(error)
    if cmd_output.returncode:
        print(output)
        assert not cmd_output.returncode, 'Command {!r} returned {:d} return code, but expected 0'.format(
            ' '.join(list_command), cmd_output.returncode)
    return output


def diff_query_lists(sack_a, sack_b):
    """ Computes diff between sack_a and sack_b """
    sa, sb = list(sack_a.query().installed()), list(sack_b.query().installed())
    rem = [x for x in sa if x not in sb]
    inst = [x for x in sb if x not in sa]
    return rem, inst


def ensure_path_exist(path):
    """Ensure that os path exist. If doesn't exist it create the path."""
    if not os.path.exists(path):
        os.makedirs(path)


def package_finder(sack, package_string, package_count=1):
    """
    @param sack: sack with packages
    @param package_string: package description in nevra format
    @return: name of package

    """
    subj = dnf.subject.Subject(package_string)
    candidate = subj.get_best_query(sack)
    assert len(candidate) == package_count, 'The number of found packages {} (packages - {}) for string "{}" differs ' \
                                            'from expected {}'.format(
        len(candidate), ' '.join([str(pkg) for pkg in candidate]), package_string, package_count)

    if package_count == 1:
        return candidate[0]


def splitter(pkgs):
    return [p.strip() for p in pkgs.split(',')]


@given('_deprecated I use the repository "{repo}"')
def given_repo_condition(context, repo):
    """ :type context: behave.runner.Context """
    assert repo, 'Repository name was not specified'
    context.repo = repo
    for file in glob.glob('/etc/yum.repos.d/*.repo'):
        os.remove(file)
    assert os.path.exists('/var/www/html/repo/' + repo), "The directory {} for repository {} doesn't exist" \
                                                         "".format('/var/www/html/repo/' + repo, repo)
    for root, dirs, files in os.walk('/repo'):
        for f in files:
            os.unlink(os.path.join(root, f))
        for d in dirs:
            shutil.rmtree(os.path.join(root, d))
    for src in glob.glob(os.path.join('/var/www/html/repo/', repo, '*.rpm')):
        os.symlink(src, '/repo/' + os.path.basename(src))
    with open('/etc/yum.repos.d/' + repo + '.repo', 'w') as f:
        f.write('[' + repo + ']\nname=' + repo + '\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0')


@step('_deprecated I execute "{type_of_command}" command "{command}" with "{result}"')
def when_action_command(context, type_of_command, command, result):
    assert command, 'Command was not specified'
    dnf_command_version = context.command_map["dnf"]
    assert dnf_command_version
    context.pre_sack = sack_rpm_comparator()
    assert context.pre_sack
    if type_of_command == 'dnf':
        dnf_command_version = dnf_command_version + " " + command
    elif type_of_command == 'bash':
        dnf_command_version = command
    else:
        raise AssertionError('The type of command {!r} is not allowed parameter (allowed: dnf, bash)'
                             .format(type_of_command))
    cmd_output = subprocess.Popen(
            dnf_command_version, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    context.cmd_output, context.cmd_error = cmd_output.communicate()
    context.cmd_rc = cmd_output.returncode
    if context.cmd_error:
        print(context.cmd_error)
    if result == "success":
        assert context.cmd_rc == 0, 'Return code was {}, but expected 0'.format(context.cmd_rc)
    elif result == "fail":
        assert context.cmd_rc != 0, 'Return code was {}, but expected non zero (fail)'.format(context.cmd_rc)
    else:
        raise AssertionError('The option {!r} is not allowed option for expected result of command. '
                             'Allowed options are "success" and "fail"'.format(result))


@when('_deprecated I create a file "{file_with_path}" with content: "{file_content}"')
def when_action_command(context, file_with_path, file_content):
    ensure_path_exist(os.path.dirname(file_with_path))
    file_content = file_content.replace(u'\\n', u'\n')
    with open(file_with_path, 'w') as f:
        f.write(file_content + '\n')


@when('_deprecated I copy plugin module "{plugin_modules}" from default plugin path into "{directory}"')
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


@then('_deprecated transaction changes are as follows')
def then_transaction_changes(context):
    if not context.table:
        raise ValueError('table not found')
    if context.table.headings != ['State', 'Packages']:
        raise NotImplementedError('configuration format not supported')
    post_sack = sack_rpm_comparator()
    removed_packages, installed_packages = diff_query_lists(context.pre_sack, post_sack)
    for state, packages in context.table:
        for pkg in splitter(packages):
            if state == 'installed':
                candidate = package_finder(post_sack, pkg)
                installed_packages.remove(candidate)
            elif state == 'removed':
                candidate = package_finder(context.pre_sack, pkg)
                removed_packages.remove(candidate)
            elif state == 'absent':
                package_finder(post_sack, pkg, package_count=0)
                package_finder(context.pre_sack, pkg, package_count=0)
            elif state == 'upgraded':
                package_upgr = package_finder(post_sack, pkg)
                package_orig = package_finder(context.pre_sack, package_upgr.name)
                assert package_upgr > package_orig, "The original package {!r} is not upgraded (package after transaction - {!r})".format(str(package_orig), str(package_upgr))
                installed_packages.remove(package_upgr)
                removed_packages.remove(package_orig)
            elif state == 'downgraded':
                package_down = package_finder(post_sack, pkg)
                package_orig = package_finder(context.pre_sack, package_down.name)
                assert package_down < package_orig, "The original package {!r} is not downgraded (package after transaction - {!r})".format(str(package_orig), str(package_down))
                installed_packages.remove(package_down)
                removed_packages.remove(package_orig)
            elif state == 'present':
                package_post = package_finder(post_sack, pkg)
                package_orig = package_finder(context.pre_sack, pkg)
                assert package_post == package_orig, "The original package {} is not identical (package after transaction - {})".format(str(package_orig), str(package_post))
            else:
                raise AssertionError('The state {!r} is not allowed option for Then statement'.format(state))
    assert not installed_packages and not removed_packages, 'Packages (installed {!r} or removed {!r}) were ' \
                                                            'unexpectably changed'.format(
        ' '.join([str(pkg) for pkg in installed_packages]),' '.join([str(pkg) for pkg in removed_packages]))


@then('_deprecated exit code of command should be equal to "{exit_code}"')
def then_package_state(context, exit_code):
    exit_code = int(exit_code)
    assert context.cmd_rc == exit_code


@then('_deprecated line from "{std_message}" should "{state}" with "{line_start}"')
def then_package_state(context, std_message, state, line_start):
    counter = 0
    contains = 0
    if std_message == 'stdout':
        message = context.cmd_output.split('\n')
    elif std_message == 'stderr':
        message = context.cmd_error.split('\n')
    else:
        raise AssertionError('The std_message {!r} is not allowed option for Then statement (allowed stdout, stderr)'
                             .format(std_message))
    for line in message:
        if line.startswith(line_start):
            counter += 1
            contains += 1
        elif line_start in line:
            contains += 1

    if state == 'start':
        assert counter > 0, 'The line starting with {!r} was not found in {!r}'.format(line_start, std_message)
    elif state == 'not start':
        assert counter == 0, 'The line starting with {!r} was found in {!r}, but should be absent'.format(line_start, std_message)
    elif state == 'contain':
        # line from "stderr" should "contain" with "foo" sounds terrible,
        # but it was a minimal change without duplicating code
        assert contains > 0, "Line containing '{!r}' wasn't found in {!r}".format(line_start, std_message)
    else:
        raise AssertionError('The state {!r} is not allowed option for Then statement (allowed start, not start)'
                             .format(state))


@then('_deprecated the path "{path_to_object}" should be "{state}"')
def then_file_presence(context, path_to_object, state):
    assert path_to_object, "The path was not specified"
    if path_to_object.endswith('/'):
        result = os.path.isdir(path_to_object)
    elif path_to_object.endswith('/*'):
        result = glob.glob(path_to_object)
    else:
        result = os.path.isfile(path_to_object)
    if state == 'present':
        assert result, 'Object not found'
    elif state == 'absent':
        assert not result, "Object was found but should be absent (hint - {!r})".format(str(result))
    else:
        raise AssertionError('The state {!r} is not allowed option for Then statement (allowed present, absent)'
                             .format(state))


@then('_deprecated the file "{path_to_file}" should contain "{content}"')
def then_file_contein(context, path_to_file, content):
    path = glob.glob(path_to_file)
    assert len(path) == 1, '{} objects ({}) were found instead of 1'.format(len(path), ' '.join(path))
    assert os.path.isfile(path[0]), "The file {!r} is not a file or doesn't exist".format(path[0])
    with open(path[0], 'r') as f:
        assert content in f, "The file {!r} doesn't contain {!r}".format(path[0], content)


@then('_deprecated the "{section}" section should contain packages "{pkgs}"')
@then('_deprecated the "{section}" section should contain package "{pkgs}"')
def then_the_section(context, section, pkgs):
    pkgs = splitter(pkgs)
    lines = iter(context.cmd_output.split('\n'))
    try:
        while not re.match('^{}:'.format(section), next(lines)):
            pass
        while True:
            pkg_line = next(lines)
            if not pkg_line.startswith(' '):
                raise AssertionError('packages {} has not been found in {} section'.format(pkgs, section))
            pkg_name = pkg_line.split()[0]
            if pkg_name in pkgs:
                pkgs.remove(pkg_name)
                if not pkgs:
                    return
    except StopIteration:
        raise AssertionError('section {} has not been found'.format(section))
