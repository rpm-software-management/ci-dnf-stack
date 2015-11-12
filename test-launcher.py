#!/usr/bin/python -tt

import os
import sys
import subprocess
import re

DOCKER_IMAGE = 'jmracek/dnftest:1.0.1'


def get_dnf_testing_version():
    f = open("ci-dnf-stack.log")
    version = []
    for line in f:
        m = re.search('"src_version": "([^"]*)[.][\w]+"', line)
        if m:
            version.append(m.group(1))
    version = set(version)
    assert len(version) == 1
    return version.pop()


def container_run(repo, pkg):
    work_dir = os.path.realpath(__file__)
    rp = os.path.join(os.path.dirname(work_dir), 'repo') + ':/build:Z'
    fp = os.path.join(os.path.dirname(work_dir), 'features') + ':/behave:Z'
    gp = os.path.join(os.path.dirname(work_dir), 'initial_settings') + ':/initial_settings:Z'
    docker_run = ['docker', 'run', '-i', '-v', rp, '-v', fp, '-v', gp, DOCKER_IMAGE, repo, pkg]
    print('Starting container:\n ' + (' '.join(docker_run)) + '\n')

    rc = subprocess.call(docker_run)

    if rc != 0:
        print('-'*80)
        print("Container returned non zero value({})".format(rc))
        print('-'*80)

    return rc


if len(sys.argv) == 1:
    print("Missing configuration file argument")
    sys.exit(1)

repo = sys.argv[1]

print('Running test:\n ' + repo)

r = container_run(repo, get_dnf_testing_version())
if not r:
    print('OK')
else:
    exit(1)
