import os
import shutil
import tempfile


FIXTURES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "fixtures"))

DEFAULT_DNF_COMMAND = "dnf"
DEFAULT_CONFIG = os.path.join(FIXTURES_DIR, "dnf.conf")
DEFAULT_REPOSDIR = os.path.join(FIXTURES_DIR, "repos.d")
DEFAULT_RELEASEVER="29"


class DNFContext(object):
    def __init__(self, userdata):
        self._scenario_data = {}

        if "installroot" in userdata:
            self.installroot = userdata["installroot"]
            # never delete user defined installroot - this allows running tests on /
            self.delete_installroot = False
        else:
            self.installroot = tempfile.mkdtemp(prefix="dnf_ci_")
            self.delete_installroot = True

        self.dnf_command = userdata.get("dnf_command", DEFAULT_DNF_COMMAND)
        self.config = userdata.get("config", DEFAULT_CONFIG)
        self.releasever = userdata.get("releasever", DEFAULT_RELEASEVER)
        self.module_platform_id = userdata.get("module_platform_id", None)
        self.reposdir = userdata.get("reposdir", DEFAULT_REPOSDIR)
        self.fixturesdir = FIXTURES_DIR

    def __del__(self):
        if self.delete_installroot:
            if self.installroot != "/":
                print("RMTREE", self.installroot)
                #shutil.rmtree(self.installroot)

    def __getitem__(self, name):
        return self._scenario_data[name]

    def __setitem__(self, name, value):
        self._scenario_data[name] = value

    def __contains__(self, name):
        return name in self._scenario_data

    def _get(self, context, name):
        if name in self:
            return self[name]
        return getattr(self, name, None)

    def get_cmd(self, context):
        result = [self.dnf_command]
        result.append("-y")

        # installroot can't be set via context for safety reasons
        if self.installroot:
            result.append("--installroot={0}".format(self.installroot))

        config = self._get(context, "config")
        if config:
            result.append("--config={0}".format(config))

        reposdir = self._get(context, "reposdir")
        if reposdir:
            result.append("--setopt=reposdir={0}".format(reposdir))

        releasever = self._get(context, "releasever")
        if releasever:
            result.append("--releasever={0}".format(releasever))

        module_platform_id = self._get(context, "module_platform_id")
        if module_platform_id:
            result.append("--setopt=module_platform_id={0}".format(module_platform_id))

        result.append("--disablerepo='*'")
        repos = self._get(context, "repos") or []
        for repo in repos:
            result.append("--enablerepo='{0}'".format(repo))

        result.append("--disableplugin='*'")
        repos = self._get(context, "plugins") or []
        for repo in repos:
            result.append("--enableplugin='{0}'".format(repo))

        return result


def before_step(context, step):
    pass


def after_step(context, step):
    pass


def before_scenario(context, scenario):
    context.dnf = DNFContext(context.config.userdata)


def after_scenario(context, scenario):
    del context.dnf


def before_feature(context, feature):
    pass

def after_feature(context, feature):
    pass


def before_tag(context, tag):
    pass


def after_tag(context, tag):
    pass


def before_all(context):
    pass


def after_all(context):
    pass
