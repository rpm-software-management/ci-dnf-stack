#!/usr/bin/python -tt

import os, sys, subprocess, json, pprint

REPOS_BASE = '/etc/yum.repos.d/'
DNF_FLAGS = ['-y', '--disablerepo=*', '--nogpgcheck']
RPM_INSTALL_FLAGS = ['-Uvh']
RPM_ERASE_FLAGS = ['-e']

def _left_decorator(item):
  " Removed packages "
  return u'-' + item

def _right_decorator(item):
  " Installed packages "
  return u'+' + item

def read_stdin_json():
  " Read JSON document from stdin "
  with os.fdopen(0) as f:
    return json.load(f)

def get_package_list():
  " Gets all installed packages in the system "
  pkgstr = subprocess.check_output(['rpm', '-qa', '--queryformat', '%{NAME}\n'])
  return pkgstr.splitlines()

def diff_package_lists(a, b):
  " Computes both left/right diff between lists `a` and `b` "
  sa, sb = set(a), set(b)
  return (map(_left_decorator, list(sa - sb)),
      map(_right_decorator, list(sb - sa)))

def inject_repository(name, **kwargs):
  " Injects the repository configuration "
  repofile = os.path.join(REPOS_BASE, name + ".repo")
  with open(repofile, "w") as fp:
    fp.write("[{0}]\n".format(name))
    fp.write("name={0}\n".format(name))
    for k, v in kwargs:
      fp.write("{0}={1}\n".format(k, v))
  return True

def execute_dnf_command(cmd, reponame):
  " Execute DNF command with default flags and the specified `reponame` enabled "
  flags = DNF_FLAGS + ['--enablerepo={0}'.format(reponame)]
  return subprocess.check_call(['dnf'] + flags + cmd, stdout=subprocess.PIPE)

def piecewise_compare(a, b):
  " Check if the two sequences are identical regardless of ordering "
  return sorted(a) == sorted(b)

class CaseResult(object):
  def __init__(self, rc, l, r, c):
    self.left_diff = l
    self.right_diff = r
    self.return_code = rc
    self.case = c

class CaseSpec(object):
  def __init__(self, pre, post, rc, cmd):
    self.pre_packages = pre
    self.post_packages = post
    self.return_code = rc
    self.command = cmd

  def on_before_execute(self):
    return get_package_list()

  def on_after_execute(self):
    return get_package_list()

  def execute(self):
    pre, post, rc = None, None, -1
    #if self.pre_packages:
    pre = self.on_before_execute()
    rc = self._execute()
    #if self.post_packages:
    post = self.on_after_execute()
    return CaseResult(rc, pre, post, self)

  def _execute(self):
    pass

  @staticmethod
  def from_json(jobj):
    t = jobj['type']
    arg = [jobj['pre_packages'], jobj['post_packages'],
           jobj['return_code'], jobj['command']]
    if t == 'dnf':
      return DnfSpec(*arg)
    elif t == 'rpm':
      return RpmSpec(*arg)
    raise ValueError('Invalid case type: {0}'.format(t))

class DnfSpec(CaseSpec):
  def _execute(self):
    return execute_dnf_command(self.command, 'test')

class RpmSpec(CaseSpec):
  def _execute(self):
    return subprocess.check_call(['rpm'] + self.command)

class TestSuite(object):
  def __init__(self, cases):
    self.cases = cases
    self.results = []

  def execute(self):
    for case in self.cases:
      self.results.append(case.execute())

class TestReader(object):
  def __init__(self, path):
    self.config_path = path

  def read_suite(self):
    obj = None
    with open(self.config_path, "r") as fp:
      obj = json.load(fp)
    if not obj:
      raise RuntimeError("Invalid JSON config file")

    cases = []
    for case in obj['cases']:
      cases.append(CaseSpec.from_json(case))
    return TestSuite(cases)

if __name__ == '__main__':
  obj = read_stdin_json()
  cases = []

  for case in obj['cases']:
    cases.append(CaseSpec.from_json(case))

  ts = TestSuite(cases)
  ts.execute()

  for rs in ts.results:
    removed, installed = diff_package_lists(rs.left_diff, rs.right_diff)
    r = None
    if installed and rs.case.post_packages:
      r = piecewise_compare(installed, rs.case.post_packages)
    if removed and rs.case.pre_packages:
      r = piecewise_compaer(removed, rs.case.pre_packages)

    if r == None:
      raise RuntimeError("Vague test case")
    elif r == False:
      print('Test case failed!')
      print(json.dumps(obj, indent=2))
      print('Removed packages:\n ' + str(removed))
      print('Installed packages:\n ' + str(installed))
      print('Case spec (remove):\n ' + str(rs.case.pre_packages) + '\nCase spec (install):\n ' + str(rs.case.post_packages))
      sys.exit(1)
