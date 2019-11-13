# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import subprocess


def run(cmd, shell=True, cwd=None):
    """
    Run a command.
    Return exitcode, stdout, stderr
    """

    proc = subprocess.Popen(
        cmd,
        shell=shell,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )

    stdout, stderr = proc.communicate()
    return proc.returncode, stdout, stderr


def run_in_context(context, cmd, can_fail=False, **run_args):
    if getattr(context, "faketime", None) is not None:
        cmd = context.faketime + cmd

    context.cmd = cmd

    if context.dnf.working_dir and 'cwd' not in run_args:
        run_args['cwd'] = context.dnf.working_dir

    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, **run_args)

    if not can_fail and context.cmd_exitcode != 0:
        raise AssertionError('Running command "%s" failed: %s' % (cmd, context.cmd_exitcode))


def get_boot_time():
    """Return the boot time of this system (as a timestamp)."""
    key = 'btime '
    with open('/proc/stat') as f:
        for line in f:
            if not line.startswith(key):
                continue
            return int(line[len(key):].strip())


def start_server_based_on_type(context, server_dir, rtype, certs=None):
    if rtype == "http":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'
        host, port = context.httpd.new_http_server(server_dir)
    elif rtype == "ftp":
        assert (hasattr(context, 'ftpd')), 'Ftpd fixture not set. Use @fixture.ftpd tag.'
        host, port = context.ftpd.new_ftp_server(server_dir)
    elif rtype == "https":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'

        host, port = context.httpd.new_https_server(
            server_dir, certs["cacert"], certs["cert"], certs["key"],
            client_verification=bool(context.dnf._get("client_ssl")))
    else:
        raise AssertionError("Unknown server type: %s" % rtype)

    return host, port
