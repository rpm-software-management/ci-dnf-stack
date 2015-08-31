#!/usr/bin/python -tt

from behave import *
import os, sys, subprocess, glob

DNF_FLAGS = ['-y', '--disablerepo=*', '--nogpgcheck']
RPM_INSTALL_FLAGS = ['-Uvh']
RPM_ERASE_FLAGS = ['-e']

def _left_decorator(item):
  " Removed packages "
  return u'-' + item

def _right_decorator(item):
  " Installed packages "
  return u'+' + item

def find_pkg(pkg):
  " Find the package file in the repository "
  candidates = glob.glob('/repo/'+pkg+'*.rpm')
  assert len(candidates) == 1
  return candidates[0]

def decorate_rpm_packages(pkgs):
  " Converts package names like TestA, TestB into absolute paths "
  return [find_pkg(p) for p in pkgs]

def get_package_list():
  " Gets all installed packages in the system "
  pkgstr = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}\n'])
  return pkgstr.splitlines()

def diff_package_lists(a, b):
  " Computes both left/right diff between lists `a` and `b` "
  sa, sb = set(a), set(b)
  return (map(_left_decorator, list(sa - sb)),
      map(_right_decorator, list(sb - sa)))

def execute_dnf_command(cmd, reponame):
  " Execute DNF command with default flags and the specified `reponame` enabled "
  flags = DNF_FLAGS + ['--enablerepo={0}'.format(reponame)]
  return subprocess.check_call(['dnf'] + flags + cmd, stdout=subprocess.PIPE)

def execute_rpm_command(pkg, action):
  " Execute given action over specified pkg(s) "
  if not isinstance(pkg, list):
    pkg = [pkg]
  if action == "remove":
    action = RPM_ERASE_FLAGS
  elif action == "install":
    action = RPM_INSTALL_FLAGS
    pkg = decorate_rpm_packages(pkg)
  return subprocess.check_call(['rpm'] + action + pkg, stdout=subprocess.PIPE)

def piecewise_compare(a, b):
  " Check if the two sequences are identical regardless of ordering "
  return sorted(a) == sorted(b)

def split(pkg):
  return [p.strip() for p in pkg.split(',')]

@given('I use the repository "{repo}"')
def given_repo_condition(context, repo):
  " :type context: behave.runner.Context "
  assert repo
  assert os.path.exists('/build/' + repo)
  a = [os.remove(p) for p in os.listdir('/repo')]
  assert subprocess.check_call(['cp -rs /build/' + repo + '/* /repo/'], shell=True) == 0
  context.pre_packages = get_package_list()
  assert context.pre_packages

@when('I "{action}" a package "{pkg}" with "{manager}"')
def when_action_package(context, action, pkg, manager):
  assert action in ["install", "remove"]
  assert manager in ["rpm", "dnf", "pkcon"]
  assert pkg
  if manager == 'rpm':
    assert execute_rpm_command(pkg.split(','), action) == 0
  elif manager == 'dnf':
    assert execute_dnf_command([action] + pkg.split(','), 'test') == 0

@then('package "{pkg}" should be "{state}"')
def then_package_state(context, pkg, state):
  assert state in ["installed", "removed", "absent"]
  assert pkg
  pkgs = get_package_list()
  assert pkgs
  removed, installed = diff_package_lists(context.pre_packages, pkgs)
  assert removed != None and installed != None
  
  for n in split(pkg):
    if state == 'installed':
      assert ('+' + n) in installed
    if state == 'removed':
      assert ('-' + n) in removed
    if state == 'absent':
      assert ('+' + n) not in installed
      assert ('-' + n) not in removed

