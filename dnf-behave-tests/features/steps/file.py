import behave
import re
import os

from common import *

@behave.given('I create file "{filepath}" with')
def step_impl(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_directory_exists(os.path.dirname(full_path))
    create_file_with_contents(full_path, context.text)


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
