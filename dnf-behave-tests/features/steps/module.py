import behave

from common import *

def check_module_list(context):
    check_context_table(context, ["Repository", "Name", "Stream", "Profiles"])
    
    lines = context.cmd_stdout.splitlines()
    modules = parse_module_list(lines)
    
    for repository, name, stream, profiles_txt in context.table: 
        if not repository or not name or not stream:
            raise ValueError("Invalid row in modules table. Repository, name and "
                             "stream columns are required")
        if profiles_txt:
            profiles = set([p.strip() for p in profiles_txt.split(',')])
        else:
            profiles = None
        if not repository in modules:
            raise AssertionError("No modules found for repository '{}'".format(repository))
        for idx,module in enumerate(modules[repository]):
            if module['name'] == name \
               and module['stream'] == stream \
               and (module['profiles'] == profiles if profiles else True):
                modules[repository].pop(idx)
                break
        else:
            raise AssertionError(
                "Module '{}:{}' with profiles '{}' not found in repository '{}'.".format(
                    name, stream, profiles_txt, repository))
    return modules

@behave.then("module list contains")
def step_impl(context):
    check_module_list(context)

@behave.then("module list is")
def step_impl(context):
    remained = []
    for repository, modules in check_module_list(context).items():
        if modules:
            remained.extend(modules)
    if remained:
        modules = ["{}:{}/{} in repository '{}'".format(m['name'], m['stream'],
                                                        m['profiles'],
                                                        m['repository'])
                   for m in modules]

        raise AssertionError("Following modules were not captured in the table: %s" % (
            '\n'.join(modules)))
