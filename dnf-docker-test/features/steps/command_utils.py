from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import codecs
import shlex
import subprocess

import six

__all__ = ["run"]

class CommandResult(object):
    def __init__(self, **kwargs):
        self.command = kwargs.pop("command", None)
        self.returncode = kwargs.pop("returncode", 0)
        self.stdout = kwargs.pop("stdout", "")
        self.stderr = kwargs.pop("stderr", "")
        if kwargs:
            names = ", ".join("{!r}".format(x) for x in kwargs)
            raise ValueError("Unexpected: {!s}".format(names))

    @property
    def failed(self):
        return self.returncode != 0

    def clear(self):
        self.command = None
        self.returncode = 0
        self.stdout = ""
        self.stderr = ""

class Command(object):
    COMMAND_MAP = {}

    @classmethod
    def run(cls, command, **kwargs):
        """
        Make a subprocess call, collect its output and return code.
        """
        assert isinstance(command, six.string_types)
        cmd_result = CommandResult()
        cmd_result.command = command

        if six.PY2 and isinstance(command, six.text_type):
            # In PY2, shlex.split() requires bytes string (non-unicode).
            # In PY3, shlex.split() accepts unicode string.
            command = codecs.encode(command, "utf-8")
        cmdargs = shlex.split(command)

        command0 = cmdargs[0]
        real_command = cls.COMMAND_MAP.get(command0, None)
        if real_command:
            cmdargs0 = real_command.split()
            cmdargs = cmdargs0 + cmdargs[1:]

        try:
            process = subprocess.Popen(cmdargs,
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       universal_newlines=True,
                                       **kwargs)
            out, err = process.communicate()
            if six.PY2: # py3: we get unicode strings, py2 not
                out = six.text_type(out, process.stdout.encoding or "utf-8")
                err = six.text_type(err, process.stderr.encoding or "utf-8")
            process.poll()
            assert process.returncode is not None
            cmd_result.stdout = out
            cmd_result.stderr = err
            cmd_result.returncode = process.returncode
            print("shell.command: {!r}".format(cmdargs))
            print("shell.command.stdout:\n{!s}".format(cmd_result.stdout))
            print("shell.command.stderr:\n{!s}".format(cmd_result.stderr))
        except OSError as e:
            cmd_result.stderr = "OSError: {!r}".format(e)
            cmd_result.returncode = int(e.errno)
            assert cmd_result.returncode != 0

        return cmd_result

def run(ctx, *args, **kwargs):
    Command.COMMAND_MAP = ctx.command_map
    return Command.run(*args, **kwargs)

def extract_section_content_from_text(section_header, text):
    SECTION_HEADERS = [
            'Installing:', 'Upgrading:', 'Removing:', 'Downgrading:', 'Installing dependencies:',
            'Removing unused dependencies:', # dnf install/remove... transaction listing
            'Installed:', 'Upgraded:', 'Removed:', 'Downgraded:', # dnf install/remove/... result
            'Installed Packages', 'Available Packages', # dnf list
            ]
    parsed = ''
    copy = False
    for line in text.split('\n'):
        if (not copy) and section_header == line:
            copy = True
            continue
        if copy:  # copy lines until hitting empty line or another known header
            if line.strip() and line not in SECTION_HEADERS:
                parsed += "%s\n" % line
            else:
                return parsed
    return parsed
