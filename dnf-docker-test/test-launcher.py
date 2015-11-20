#!/usr/bin/python -tt

import os
import sys
import subprocess

DOCKER_IMAGE='jmracek/dnftest:1.0.2'

def container_run(repo):
    work_dir = os.path.realpath(__file__)
    rp = os.path.join(os.path.dirname(work_dir), 'repo') + ':/build:Z'
    fp = os.path.join(os.path.dirname(work_dir), 'features') + ':/behave:Z'
    docker_run = ['docker', 'run', '-i', '-v', rp, '-v', fp, DOCKER_IMAGE, repo]
    print('Starting container:\n ' + (' '.join(docker_run)) + '\n')

    rc = subprocess.call(docker_run)

    if rc != 0:
        print('-'*80)
        print("FAIL: Container returned non zero value({})".format(rc))
        print('-'*80)

    return rc

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("Missing configuration file argument")
        sys.exit(1)

    repo = sys.argv[1]

    print('Running test:\n ' + repo)

    r = container_run(repo)
    if not r:
        print('OK')
    else:
        exit(1)
