#!/usr/bin/python -tt

import os
import sys
import subprocess
import re

DOCKER_IMAGE='jmracek/dnftest:1.0.1'

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

if len(sys.argv) == 1:
  print("Missing configuration file argument")
  sys.exit(1)

repo = sys.argv[1]

def container_run(repo, pkg):
  work_dir = os.path.realpath(__file__)
  r = os.path.join(os.path.dirname(work_dir), 'repo') + ':/build:Z'
  f = os.path.join(os.path.dirname(work_dir), 'features') + ':/behave:Z'
  g = os.path.join(os.path.dirname(work_dir), 'initial_settings') + ':/initial_settings:Z'
  DOCKER_RUN = ['docker', 'run', '-i', '-v', r, '-v', f, '-v', g, DOCKER_IMAGE, repo, pkg]
  print('Starting container:\n ' + (' '.join(DOCKER_RUN)) + '\n')

  rc = subprocess.call(DOCKER_RUN)

  if rc != 0:
    print('-'*80)
    print("Container returned non zero value({})".format(rc))
    print('-'*80)

  return rc

print('Running test:\n ' + repo)

r = container_run(repo, get_dnf_testing_version())
if not r:
  print('OK')
else:
    exit(1)