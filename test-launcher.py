#!/usr/bin/python -tt

import os, sys, subprocess, json

DOCKER_IMAGE='jmracek/dnftest:1.0.1'

class Colors(object):
  HEADER = '\033[95m'
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  WARNING = '\033[93m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'

def copy_log():
  subprocess.check_call(['cp ci-dnf-stack.log ' + os.path.join(os.path.dirname(os.path.realpath(__file__)), 'initial_settings')], shell=True)


def color_text(c, text):
  return "{}{}{}".format(c, text, Colors.ENDC)

def blue_text(t):
  return color_text(Colors.OKBLUE, t)

def red_text(t):
  return color_text(Colors.FAIL, t)

def green_text(t):
  return color_text(Colors.OKGREEN, t)

def header_text(t):
  return color_text(Colors.HEADER, t)

if len(sys.argv) == 1:
  print("Missing configuration file argument")
  sys.exit(1)

repo = sys.argv[1]

def container_run(repo):
  work_dir = os.path.realpath(__file__)
  r = os.path.join(os.path.dirname(work_dir), 'repo') + ':/build:Z'
  f = os.path.join(os.path.dirname(work_dir), 'features') + ':/behave:Z'
  g = os.path.join(os.path.dirname(work_dir), 'initial_settings') + ':/initial_settings:Z'
  DOCKER_RUN = ['docker', 'run', '-i', '-v', r, '-v', f, '-v', g, DOCKER_IMAGE, repo]
  print('Starting container:\n ' + blue_text(' '.join(DOCKER_RUN)) + '\n')

  rc = subprocess.call(DOCKER_RUN)

  if rc != 0:
    print(red_text('-'*80))
    print(header_text("Container returned non zero value({})".format(rc)))
    print(red_text('-'*80))

  return rc

print('Running test:\n ' + blue_text(repo))

copy_log()
r = container_run(repo)
if not r:
  print(green_text('OK'))
