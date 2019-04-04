import behave
import re
import os

from common import *

@behave.given('I create directory "{dirpath}"')
def step_impl(context, dirpath):
    full_path = os.path.join(context.dnf.installroot, dirpath.lstrip("/"))
    ensure_directory_exists(full_path)


@behave.given('I create file "{filepath}" with')
def step_impl(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_directory_exists(os.path.dirname(full_path))
    create_file_with_contents(full_path, context.text)


@behave.given('I create and substitute file "{filepath}" with')
def step_impl(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_directory_exists(os.path.dirname(full_path))
    create_file_with_contents(full_path, context.text.format(context=context))


@behave.given('I delete file "{filepath}"')
def step_delete_file(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    delete_file(full_path)


@behave.given('I delete directory "{dirpath}"')
def step_delete_directory(context, dirpath):
    full_path = os.path.join(context.dnf.installroot, dirpath.lstrip("/"))
    delete_directory(full_path)


@behave.step('file "{filepath}" exists')
def file_exists(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_file_exists(full_path)


@behave.given('file "{filepath}" does not exist')
def file_does_not_exist(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_file_does_not_exist(full_path)


@behave.step('file "{filepath}" contains lines')
def file_contains(context, filepath):
    regexp_lines = context.text.split('\n')
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_directory_exists(os.path.dirname(full_path))
    read_str = read_file_contents(full_path)
    for line in regexp_lines:
        if not re.search(line, read_str):
            print("line: " + line + " not found")
            raise AssertionError("File %s contains: \n%s" % (filepath, read_str))
    return


@behave.step('I copy directory "{source}" to "{destination}"')
def step_impl(context, source, destination):
    source = source.format(context=context)
    destination = os.path.join(context.dnf.installroot, destination.lstrip("/"))
    ensure_directory_exists(os.path.dirname(destination))
    copy_tree(source, destination)
