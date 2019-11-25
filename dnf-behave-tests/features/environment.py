# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import operator
import os
import shutil
import sys
import tempfile

# add the behave tests root to python path so that the `common` module can be found
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
# make sure behave loads the common steps
import common

from behave import fixture, use_fixture, model
from behave.tag_matcher import ActiveTagMatcher
from behave.formatter.ansi_escapes import escapes

from common.lib.file import ensure_directory_exists
from steps.fixtures.httpd import HttpServerContext
from steps.fixtures.ftpd import FtpServerContext


FIXTURES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "fixtures"))

DEFAULT_DNF_COMMAND = "dnf"
DEFAULT_CONFIG = os.path.join(FIXTURES_DIR, "dnf.conf")
DEFAULT_REPOS_LOCATION = os.path.join(FIXTURES_DIR, "repos")
DEFAULT_RELEASEVER="29"
DEFAULT_PLATFORM_ID="platform:f29"

# If a test is marked with any of these tags, it will be considered
# "destructive" to the system running it.
DESTRUCTIVE_TAGS = [
    "destructive",
]


class VersionedActiveTagMatcher(ActiveTagMatcher):
    @staticmethod
    def version_compare_operator(tag_value_str, current_value_str, is_negated=False):
        tag_key, tag_oper, tag_value = tag_value_str.split("__", 2)
        try:
            current_key, current_value = current_value_str.split("__", 1)
        except ValueError:
            return is_negated

        # convert versions into list of integers for correct comparing
        tag_value = [int(i) for i in tag_value.split(".")]
        try:
            current_value = [int(i) for i in current_value.split(".")]
        except:
            return is_negated

        if tag_oper not in ["lt", "le", "eq", "ne", "ge", "gt"]:
            raise ValueError("Invalid operator in tag: %s" % tag_value_str)

        if tag_key != current_key:
            # always return false if keys do not match
            return is_negated

        op = getattr(operator, tag_oper)
        result = op(current_value, tag_value)
        if is_negated:
            result = not(result)
        return result

    def is_tag_group_enabled(self, group_category, group_tag_pairs):
        """Modified ActiveTagMatcher.is_tag_group_enabled()"""
        if not group_tag_pairs:
            # -- CASE: Empty group is always enabled (CORNER-CASE).
            return True

        current_value = self.value_provider.get(group_category, None)
        if current_value is None and self.ignore_unknown_categories:
            # -- CASE: Unknown category, ignore it.
            return True

        tags_enabled = []
        for category_tag, tag_match in group_tag_pairs:
            tag_prefix = tag_match.group("prefix")
            category = tag_match.group("category")
            tag_value = tag_match.group("value")
            assert category == group_category
            tag_enabled = self.version_compare_operator(tag_value, current_value, self.is_tag_negated(tag_prefix))
            tags_enabled.append(tag_enabled)
        return any(tags_enabled)    # -- PROVIDES: LOGICAL-OR expression


active_tag_value_provider = {}
active_tag_matcher = VersionedActiveTagMatcher(active_tag_value_provider)


class DNFContext(object):
    def __init__(self, userdata, force_installroot=False):
        self._scenario_data = {}

        self.repos = {}
        self.ports = {}

        self.tempdir = tempfile.mkdtemp(prefix="dnf_ci_tempdir_")
        # some tests need to be run inside the installroot, it can be forced
        # per scenario by using @force_installroot decorator
        if "installroot" in userdata and not force_installroot:
            self.installroot = userdata["installroot"]
            # never delete user defined installroot - this allows running tests on /
            self.delete_installroot = False
        else:
            self.installroot = tempfile.mkdtemp(prefix="dnf_ci_installroot_")
            # if we're creating installroot, ensure /etc/yum.repos.d exists,
            # otherwise dnf picks repo configs from the host
            ensure_directory_exists(os.path.join(self.installroot, "etc/yum.repos.d"))
            self.delete_installroot = True

        self.dnf_command = userdata.get("dnf_command", DEFAULT_DNF_COMMAND)
        self.config = userdata.get("config", DEFAULT_CONFIG)
        self.releasever = userdata.get("releasever", DEFAULT_RELEASEVER)
        self.module_platform_id = userdata.get("module_platform_id", DEFAULT_PLATFORM_ID)
        self.repos_location = userdata.get("repos_location", DEFAULT_REPOS_LOCATION)
        self.fixturesdir = FIXTURES_DIR
        self.disable_plugins = True
        self.disable_repos_option = "--disablerepo='*'"
        self.assumeyes_option = "-y"
        self.working_dir = None

        self.preserve_temporary_dirs = "none"
        preserve = userdata.get("preserve", "no")
        if preserve in ("yes", "y", "1", "true"):
            self.preserve_temporary_dirs = "all"
        elif preserve in ("failed", "fail", "f"):
            self.preserve_temporary_dirs = "failed"

        self.scenario_failed = False

    def __del__(self):
        preserved_dirs = []
        if os.path.realpath(self.tempdir) not in ["/", "/tmp"]:
            if (self.preserve_temporary_dirs == "all"
                    or (self.preserve_temporary_dirs == "failed" and self.scenario_failed)):
                preserved_dirs.append(self.tempdir)
            else:
                shutil.rmtree(self.tempdir)

        if self.delete_installroot and os.path.realpath(self.installroot) not in ["/"]:
            if (self.preserve_temporary_dirs == "all"
                    or (self.preserve_temporary_dirs == "failed" and self.scenario_failed)):
                preserved_dirs.append(self.installroot)
            else:
                shutil.rmtree(self.installroot)

        if preserved_dirs:
            print(escapes["undefined"] + "Temporary directories have been preserved for your browsing pleasure:")
            for d in preserved_dirs:
                print("   " + d)
            print(escapes["reset"])

    def __getitem__(self, name):
        return self._scenario_data[name]

    def __setitem__(self, name, value):
        self._scenario_data[name] = value

    def __contains__(self, name):
        return name in self._scenario_data

    def _get(self, name):
        if name in self:
            return self[name]
        return getattr(self, name, None)

    def _set(self, name, value):
        return setattr(self, name, value)

    def get_cmd(self, context):
        result = [self.dnf_command]
        result.append(self.assumeyes_option)

        # installroot can't be set via context for safety reasons
        if self.installroot:
            result.append("--installroot={0}".format(self.installroot))

        config = self._get("config")
        if config:
            result.append("--config={0}".format(config))

        releasever = self._get("releasever")
        if releasever:
            result.append("--releasever={0}".format(releasever))

        module_platform_id = self._get("module_platform_id")
        if module_platform_id:
            result.append("--setopt=module_platform_id={0}".format(module_platform_id))

        disable_plugins = self._get("disable_plugins")
        if disable_plugins:
            result.append("--disableplugin='*'")
        plugins = self._get("plugins") or []
        for plugin in plugins:
            result.append("--enableplugin='{0}'".format(plugin))

        setopts = self._get("setopts") or {}
        for key,value in setopts.items():
            result.append("--setopt={0}={1}".format(key, value))

        return result


class OSRelease(object):
    """Represents the os-release(5) file."""
    def __init__(self, path):
        self._path = path
        self._backup = None
        # Back up the original file (if any)
        if os.path.exists(path):
            with open(path) as f:
                self._backup = f.read()

    def set(self, data):
        """Store the given data in this file."""
        content = ('%s=%s' % (k, v) for k, v in data.items())
        with open(self._path, 'w') as f:
            f.write('\n'.join(content))

    def delete(self):
        """Delete the file."""
        if os.path.exists(self._path):
            os.remove(self._path)

    def __del__(self):
        """Restore the backup."""
        self.delete()
        if self._backup is not None:
            with open(self._path, 'w') as f:
                f.write(self._backup)


@fixture
def httpd_context(context):
    context.httpd = HttpServerContext()
    yield context.httpd
    context.httpd.shutdown()


@fixture
def ftpd_context(context):
    context.ftpd = FtpServerContext()
    yield context.ftpd
    context.ftpd.shutdown()


@fixture
def osrelease(context):
    try:
        context.osrelease = OSRelease('/usr/lib/os-release')
        yield context.osrelease
    finally:
        del context.osrelease


def before_step(context, step):
    pass


def after_step(context, step):
    pass


def before_scenario(context, scenario):
    if active_tag_matcher.should_exclude_with(scenario.effective_tags):
        scenario.skip(reason="DISABLED ACTIVE-TAG")

    # Skip if destructive and not explicitly allowed by the user
    if ((set(scenario.effective_tags) & set(DESTRUCTIVE_TAGS)) and not
            context.config.userdata.get('destructive', 'no') == 'yes'):
        scenario.skip(reason="DESTRUCTIVE")

    context.dnf = DNFContext(context.config.userdata,
                             force_installroot='force_installroot' in scenario.tags)


def after_scenario(context, scenario):
    if scenario.status == model.Status.failed:
        context.dnf.scenario_failed = True

        if getattr(context, "cmd", ""):
            print(
                "%sLast Command: %s%s" %
                (escapes["failed"], escapes["failed_arg"], context.cmd)
            )
            print(escapes["reset"])
        if getattr(context, "cmd_stdout", ""):
            print("%sLast Command stdout:%s" % (escapes['outline_arg'], escapes['executing']))
            print(context.cmd_stdout.strip())
            print(escapes["reset"])
        if getattr(context, "cmd_stderr", ""):
            print("%sLast Command stderr:%s" % (escapes['outline_arg'], escapes['executing']))
            print(context.cmd_stderr.strip())
            print(escapes["reset"])

    del context.dnf


def before_feature(context, feature):
    pass


def after_feature(context, feature):
    pass


def before_tag(context, tag):
    if tag == 'fixture.httpd':
        use_fixture(httpd_context, context)
    if tag == 'fixture.ftpd':
        use_fixture(ftpd_context, context)


def after_tag(context, tag):
    pass


def before_all(context):
    os = context.config.userdata.get("os", None)
    if os:
        active_tag_value_provider["os"] = os

    context.repos = {}


def after_all(context):
    pass
