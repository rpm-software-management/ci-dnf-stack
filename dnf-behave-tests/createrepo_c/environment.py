# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import os
import shutil
import sys
import tempfile

# add the behave tests root to python path so that the `common` module can be found
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
# make sure behave loads the common steps
import common
import consts

from behave import model
from behave.formatter.ansi_escapes import escapes

from common.lib.cmd import print_last_command


class TempDirManager(object):
    def __init__(self, userdata):
        self.tempdir = tempfile.mkdtemp(prefix="createrepo_c_ci_tempdir_")

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

        if preserved_dirs:
            print(escapes["undefined"] + "Temporary directories have been preserved for your browsing pleasure:")
            for d in preserved_dirs:
                print("   " + d)
            print(escapes["reset"])


def before_step(context, step):
    pass


def after_step(context, step):
    pass


def before_scenario(context, scenario):
    context.tempdir_manager = TempDirManager(context.config.userdata)

    context.scenario.default_tmp_dir = context.tempdir_manager.tempdir
    context.scenario.repos_location = os.path.join(consts.FIXTURES_DIR, "repos")


def after_scenario(context, scenario):
    if scenario.status == model.Status.failed:
        context.tempdir_manager.scenario_failed = True
        print_last_command(context)

    del context.tempdir_manager


def before_feature(context, feature):
    pass


def after_feature(context, feature):
    pass


def after_tag(context, tag):
    pass


def before_all(context):
    pass


def after_all(context):
    pass
