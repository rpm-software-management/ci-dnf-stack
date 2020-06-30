# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import dbus
import os
import subprocess
import time

from common.lib.behave_ext import check_context_table
from common.lib.diff import print_lines_diff


TIMEOUT = 5


def get_proxy(bus_name='org.rpm.dnf.v0.rpm.RepoConf', object_path='/org/rpm/dnf/v0/rpm/RepoConf'):
    bus = dbus.SystemBus()
    proxy = bus.get_object(bus_name, object_path)
    return proxy


def repoconfig_call(context, method, args):
    # all repoconfig methods accept one argument
    # convert comma separated strings into a list, leave out empty strings
    params = [a.strip() for a in args.split(',') if a.strip()]
    proxy = get_proxy()
    iface = dbus.Interface(proxy, dbus_interface='org.rpm.dnf.v0.rpm.RepoConf')
    method_callable = getattr(iface, method)
    if method == 'get':
        # all methods except for "get" accept a list of repository ids as a argument
        # the get method accepts only one repo id.
        assert len(params) == 1, 'Wrong number of arguments for "{}" method.'.format(method)
        params = params[0]
    try:
        context.repoconf_results = method_callable(params)
        context.repoconf_exception = None
    except AssertionError:
        raise
    except Exception as exc:
        context.repoconf_results = None
        context.repoconf_exception = exc


@behave.given('I start dnf-repoconfig-daemon')
def start_dnf_repoconfig_daemon(context):
    """
    Start dnf-repoconfig-daemon and wait till it is ready. Also underlying
    dbus-daemon and polkitd are started.
    """
    config_path = os.path.join(context.dnf.fixturesdir, 'config_files/dbus-system-minimal.conf')
    proc_dbus = subprocess.Popen(['/usr/bin/dbus-daemon', '--config-file', config_path])
    proc_polkit = subprocess.Popen(['/usr/lib/polkit-1/polkitd', '-n'])
    proc_repoconfig = subprocess.Popen(['/usr/bin/dnf-repoconfig-daemon'])

    # wait till dnf-repoconfig-daemon is ready
    start_time = time.time()
    while True:
        try:
            get_proxy()
            break
        except dbus.exceptions.DBusException:
            if time.time() - start_time > TIMEOUT:
                assert False, 'Unable to start dnf-repoconfig-daemon'
            time.sleep(0.1)


@behave.step('I call repoconfig-daemon method "{method}" with args "{args}"')
def call_repoconfig_daemon_method_args(context, method, args):
    """
    Call given method of org.rpm.dnf.v0.rpm.RepoConf interface with given args
    via dbus and store results to context.repoconf_results
    """
    repoconfig_call(context, method, args)


@behave.step('I call repoconfig-daemon method "list"')
def call_repoconfig_daemon_method(context):
    """
    Call given method of org.rpm.dnf.v0.rpm.RepoConf interface via dbus and
    store results to context.repoconf_results
    """
    repoconfig_call(context, 'list', '')


@behave.then('I got an exception with message "{message}"')
def i_got_exception(context, message):
    """
    Check that context.repoconf_exception contains exception with given error message.
    """
    assert isinstance(context.repoconf_exception, Exception),\
        'context.repoconf_exception does not contain an exception'
    assert str(context.repoconf_exception) == message,\
        'Invalid exception message. Expected "{}" but "{}" was found'.format(
            message, str(context.repoconf_exception))


@behave.then('listed repositories are')
def repositories_are(context):
    """
    Check the results of "list" method.
    Each line of context.table is one repository, headings of the table contains
    names of the attributes being checked and the cells its respective values for
    each repository.
    """
    separator = ' | ' 
    repo_attrs = context.table.headings
    expected = []
    for line in context.table:
        expected.append(separator.join(c for c in line))
    expected.sort()
    found = []
    for repo in context.repoconf_results:
        found.append(separator.join(str(repo[a]) for a in repo_attrs))
    found.sort()
    if expected != found:
        print_lines_diff(expected, found)
        raise AssertionError('Repositories do not match.')


@behave.then('the repository is')
def repository_is(context):
    """
    Check that repository stored in context.repoconf_results has attributes with values
    specified in context.table.
    Each line of context.table is key / value pair.
    """
    check_context_table(context, ['key', 'value'])
    assert context.repoconf_results, 'context.repoconf_results is empty'
    for key, value in context.table:
        assert str(context.repoconf_results[key]) == value,\
               'Invalid repository attribute "{}" value. '\
               'Expected "{}" but "{}" was found'.format(
                    key, value, str(context.repoconf_results[key]))


@behave.then('ids of changed repositories are')
def changed_repositories_are(context):
    """
    Check for enable/disable methods.
    Check that context.repoconf_results contains repository ids specified in context.table.
    """
    expected = [line['repoid'] for line in context.table]
    expected.sort()
    found = [str(repoid) for repoid in context.repoconf_results]
    found.sort()
    if expected != found:
        print_lines_diff(expected, found)
        raise AssertionError('Changed repositories do not match.')
