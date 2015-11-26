#!/usr/bin/python -tt

import sys
import subprocess


def container_run(repo, dnf_command_version, docker_image):
    docker_run = ['docker', 'run', '--rm', '-i', docker_image, repo, dnf_command_version]
    print('Starting container:\n ' + (' '.join(docker_run)) + '\n')

    rc = subprocess.call(docker_run)

    if rc != 0:
        print('-'*80)
        print("FAIL: Container returned non zero value({})".format(rc))
        print('-'*80)

    return rc

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Missing configuration file argument")
        sys.exit(1)

    test_name = sys.argv[1]
    dnf_command_version = sys.argv[2]
    docker_image = sys.argv[3]

    print('Running test:\n ' + test_name)

    r = container_run(test_name, dnf_command_version, docker_image)
    if not r:
        print('OK')
    else:
        exit(1)
