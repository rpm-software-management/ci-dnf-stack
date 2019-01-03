import subprocess


def run(cmd, shell=False, can_fail=True):
    """
    Run a command.
    Return exitcode, stdout, stderr
    """

    proc = subprocess.Popen(
        cmd,
        shell=shell,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )

    stdout, stderr = proc.communicate()

    if not can_fail and proc.returncode != 0:
        raise RuntimeError("Running command failed: %s" % cmd)

    return proc.returncode, stdout, stderr
