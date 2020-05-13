# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
from fnmatch import fnmatch
import os
import parse

from fixtures import start_server_based_on_type


@parse.with_pattern(r"http|https|ftp")
def parse_server_type(text):
    if text in ("http", "https", "ftp"):
        return text
    assert False
behave.register_type(server_type=parse_server_type)


@behave.step("the server starts responding with HTTP status code {code}")
def step_server_down(context, code):
    context.scenario.httpd.conf['status'] = int(code)


@behave.step("I start capturing outbound HTTP requests")
def step_start_http_capture(context):
    context.scenario.httpd.conf['logging'] = True


@behave.step('I require client certificate verification with certificate "{client_cert}" and key "{client_key}"')
def step_impl(context, client_cert, client_key):
    if "client_ssl" not in context.dnf:
        context.dnf["client_ssl"] = dict()
    context.dnf["client_ssl"]["certificate"] = os.path.join(context.dnf.fixturesdir,
                                                            client_cert)
    context.dnf["client_ssl"]["key"] = os.path.join(context.dnf.fixturesdir,
                                                    client_key)


@behave.step("I forget any HTTP requests captured so far")
def step_clear_http_logs(context):
    context.scenario.httpd.clear_log()


@behave.step("{quantifier} HTTP {command} request should match")
@behave.step("{quantifier} HTTP {command} requests should match")
def step_check_http_log(context, quantifier, command):
    # Obtain the httpd log for this command
    log = [record
           for record in context.scenario.httpd.log
           if record.command == command]
    assert log, 'No HTTP requests have been received!'

    # Find matches
    if 'header' in context.table.headings:
        good = [record
                for record in log
                for row in context.table
                if record.headers[row['header']] == row['value']]
    elif 'path' in context.table.headings:
        good = [record
                for record in log
                for row in context.table
                if fnmatch(record.path, row['path'])]
    else:
        assert False, 'No supported column heading found in the table'

    bad = [record for record in log if record not in good]

    def dump(log):
        return '\n' + '\n'.join(map(str, log)) + '\n'

    if quantifier == 'every':
        assert not bad, \
            '%i requests did not match:%s' \
            % (len(bad), dump(bad))
    elif quantifier.startswith('exactly '):
        num = quantifier.split(' ')[1]
        if num == 'one':
            num = 1
        num = int(num)
        assert len(good) == num, \
            'Expected %i matches but got %i instead, full log:%s' \
            % (num, len(good), dump(log))
    elif quantifier == 'no':
        assert not good, \
            'Expected no matches but got %i:%s' \
            % (len(good), dump(good))


@behave.step("HTTP log contains")
def step_http_log_contains(context):
    expected = context.text.format(context=context).rstrip().split('\n')
    found = ["%s %s" % (r.command, r.path) for r in context.scenario.httpd.log]

    for e in expected:
        if e not in found:
            raise AssertionError('HTTP log does not contain "%s": %s' % (e, "\n" + "\n".join(found) + "\n"))
