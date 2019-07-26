# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import operator
import os
import shutil
import tempfile

from behave import fixture, use_fixture
from behave.tag_matcher import ActiveTagMatcher

from steps.fixtures.httpd import HttpServerContext
from steps.fixtures.ftpd import FtpServerContext


FIXTURES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "fixtures"))

DEFAULT_DNF_COMMAND = "dnf"
DEFAULT_CONFIG = os.path.join(FIXTURES_DIR, "dnf.conf")
DEFAULT_REPOSDIR = os.path.join(FIXTURES_DIR, "repos.d")
DEFAULT_REPOS_LOCATION = os.path.join(FIXTURES_DIR, "repos")
DEFAULT_RELEASEVER="29"
DEFAULT_PLATFORM_ID="platform:f29"


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

        self.tempdir = tempfile.mkdtemp(prefix="dnf_ci_tempdir_")
        # some tests need to be run inside the installroot, it can be forced
        # per scenario by using @force_installroot decorator
        if "installroot" in userdata and not force_installroot:
            self.installroot = userdata["installroot"]
            # never delete user defined installroot - this allows running tests on /
            self.delete_installroot = False
        else:
            self.installroot = tempfile.mkdtemp(prefix="dnf_ci_installroot_")
            self.delete_installroot = True

        self.dnf_command = userdata.get("dnf_command", DEFAULT_DNF_COMMAND)
        self.config = userdata.get("config", DEFAULT_CONFIG)
        self.releasever = userdata.get("releasever", DEFAULT_RELEASEVER)
        self.module_platform_id = userdata.get("module_platform_id", DEFAULT_PLATFORM_ID)
        self.reposdir = userdata.get("reposdir", DEFAULT_REPOSDIR)
        self.repos_location = userdata.get("repos_location", DEFAULT_REPOS_LOCATION)
        self.preserve_temporary_dirs = True if userdata.get("preserve", "no") in ("yes", "y", "1", "true") else False
        self.fixturesdir = FIXTURES_DIR
        self.disable_plugins = True
        self.disable_repos_option = "--disablerepo='*'"
        self.assumeyes_option = "-y"

        # temporarily use DNF0 for substituting fixturesdir in repo files
        # the future could be in named environment variable like DNF_VAR_FIXTURES_DIR
        os.environ['DNF0'] = self.fixturesdir

    def __del__(self):
        if not self.preserve_temporary_dirs and os.path.realpath(self.tempdir) not in ["/", "/tmp"]:
            shutil.rmtree(self.tempdir)

        if not self.preserve_temporary_dirs and self.delete_installroot:
            if os.path.realpath(self.installroot) not in ["/"]:
                shutil.rmtree(self.installroot)

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

    def _set(self, name, value):
        return setattr(self, name, value)

    def get_cmd(self, context):
        result = [self.dnf_command]
        result.append(self.assumeyes_option)

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

        result.append(self.disable_repos_option)
        repos = self._get(context, "repos") or []
        for repo in repos:
            result.append("--enablerepo='{0}'".format(repo))

        disable_plugins = self._get(context, "disable_plugins")
        if disable_plugins:
            result.append("--disableplugin='*'")
        plugins = self._get(context, "plugins") or []
        for plugin in plugins:
            result.append("--enableplugin='{0}'".format(plugin))

        setopts = self._get(context, "setopts") or {}
        for key,value in setopts.items():
            result.append("--setopt={0}={1}".format(key, value))

        return result


@fixture
def httpd_context(context, *args, **kwargs):
    context.httpd = HttpServerContext(*args, **kwargs)
    yield context.httpd
    context.httpd.shutdown()


@fixture
def ftpd_context(context):
    context.ftpd = FtpServerContext()
    yield context.ftpd
    context.ftpd.shutdown()


def before_step(context, step):
    pass


def after_step(context, step):
    pass


def before_scenario(context, scenario):
    if active_tag_matcher.should_exclude_with(scenario.effective_tags):
        scenario.skip(reason="DISABLED ACTIVE-TAG")
    if not context.feature_global_dnf_context:
        context.dnf = DNFContext(context.config.userdata,
                                 force_installroot='force_installroot' in scenario.tags)


def after_scenario(context, scenario):
    if not context.feature_global_dnf_context:
        del context.dnf


def before_feature(context, feature):
    context.feature_global_dnf_context = 'global_dnf_context' in feature.tags
    if context.feature_global_dnf_context:
        context.dnf = DNFContext(context.config.userdata)


def after_feature(context, feature):
    if context.feature_global_dnf_context:
        del context.dnf


def before_tag(context, tag):
    if tag.startswith('fixture.httpd'):
        parts = tag.split('.')
        use_fixture(httpd_context, context,
                    logging=(len(parts) == 3 and parts[2] == 'log'))
    if tag == 'fixture.ftpd':
        use_fixture(ftpd_context, context)


def after_tag(context, tag):
    pass


def before_all(context):
    os = context.config.userdata.get("os", None)
    if os:
        active_tag_value_provider["os"] = os


def after_all(context):
    pass
