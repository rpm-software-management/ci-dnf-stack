import unittest

class dummy(unittest.TestCase):
    maxDiff = None

    def runTest(self):
        pass

def before_all(ctx):
    ctx.command_map = {
        "dnf": ctx.config.userdata.get("dnf_cmd", "dnf")
    }
    ctx.rpmdb = None
    ctx.wipe_rpmdb = False
    ctx.assertion = dummy()

def after_step(ctx, step):
    if ctx.wipe_rpmdb:
        ctx.rpmdb = None
