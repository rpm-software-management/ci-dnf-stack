import behave
import os

from common import *

@behave.given('I create file "{filepath}" with')
def step_impl(context, filepath):
    full_path = os.path.join(context.dnf.installroot, filepath.lstrip("/"))
    ensure_directory_exists(os.path.dirname(full_path))
    create_file_with_contents(full_path, context.text)
