#!/usr/bin/python -tt

import os
import sys
import subprocess

DOCKER_IMAGE='jmracek/dnftest:1.0.2'


def container_run(repo, dnf_command_version):
    docker_run = ['docker', 'run', '-i', DOCKER_IMAGE, repo, dnf_command_version]
    print('Starting container:\n ' + (' '.join(docker_run)) + '\n')

    rc = subprocess.call(docker_run)

    if rc != 0:
        print('-'*80)
        print("FAIL: Container returned non zero value({})".format(rc))
        print('-'*80)

    return rc

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Missing configuration file argument")
        sys.exit(1)

    test_name = sys.argv[1]
    dnf_command_version = sys.argv[2]

    print('Running test:\n ' + test_name)

    r = container_run(test_name, dnf_command_version)
    if not r:
        print('OK')
    else:
        exit(1)
