from __future__ import absolute_import
from __future__ import unicode_literals

import codecs
import os

import six
from six.moves import configparser

from command_steps import step_i_successfully_run_command

def readline_generator(f):
    line = f.readline()
    while line:
        yield line
        line = f.readline()

def ensure_directory_exists(dirname):
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    assert os.path.exists(dirname), "ENSURE: dir exists {!r}".format(dirname)
    assert os.path.isdir(dirname), "ENSURE: is a dir {!r}".format(dirname)

def create_file_with_contents(filename, contents, encoding="utf-8"):
    """
    :param str filename: Path to file
    :param str|list|configparser.ConfigParser contents: Contents to write
    :param str encoding: File encoding
    """
    ensure_directory_exists(os.path.dirname(filename))
    if os.path.exists(filename):
        os.remove(filename)
    with codecs.open(filename, "w", encoding) as outstream:
        newline = False
        if isinstance(contents, configparser.ConfigParser):
            contents.write(outstream)
        elif isinstance(contents, list):
            outstream.writelines(contents)
            newline = not contents[-1].endswith("\n")
        else:
            outstream.write(contents)
            newline = not contents.endswith("\n")
        if newline:
            outstream.write("\n")
        outstream.flush()
    assert os.path.exists(filename), "ENSURE: file exists {!r}".format(filename)

def read_ini_file(filename):
    conf = configparser.ConfigParser()
    with open(filename, "r") as instream:
        if six.PY2:
            conf.readfp(instream)
        else:
            conf.read_file(readline_generator(instream))
    return conf

def set_dir_content_ownership(ctx, directory, user=None):
    if not user:
        if directory.startswith('/var/www/html'):
            user = 'apache'
        elif directory.startswith('/var/ftp'):
            user = 'ftp'
        else:
            user = 'root'
    cmd = 'chown -R {!s} {!s}'.format(user, directory)
    step_i_successfully_run_command(ctx, cmd)
