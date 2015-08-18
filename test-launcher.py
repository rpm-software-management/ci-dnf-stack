#!/usr/bin/python -tt

import os, sys, subprocess, json

DOCKER_IMAGE='richdeps:1.0.0'

class Colors(object):
  HEADER = '\033[95m'
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  WARNING = '\033[93m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'

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

config = sys.argv[1]

if not os.path.exists(config):
  print("Path to configuration file is invalid")
  sys.exit(1)

test_data, jo = '', None
with open(config, 'r') as fp:
  test_data = fp.read()
  jo = json.loads(test_data)

def container_run(repo, test_input):
  r = os.path.join(os.getcwd(), repo) + ':/repo:Z'
  DOCKER_RUN = ['docker', 'run', '-i', '-v', r, DOCKER_IMAGE]
  print('Starting container:\n ' + blue_text(' '.join(DOCKER_RUN)) + '\n')

  p = subprocess.Popen(DOCKER_RUN, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
  out, _ = p.communicate(test_input)
  rc = p.poll()

  if rc != 0:
    print(red_text("Container returned non zero value({}), stdout:\n ".format(rc)) + out)
    print(red_text('-'*80))

  return rc

print('Loading test configuration from:\n ' + blue_text(config))

r = container_run(jo['repository'], test_data)
if not r:
  print(green_text('OK'))
