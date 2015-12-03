#!/usr/bin/python3 -tt

from rpmfluff import SimpleRpmBuild
from rpmfluff import YumRepoBuild
from pathlib import PurePosixPath
import os
import shutil

work_file = os.path.realpath(__file__)
work_dir = os.path.dirname(work_file)
file_base_mane = PurePosixPath(work_file).stem
repo_dir = os.path.join(work_dir, file_base_mane)
temp_dir = os.path.join(repo_dir, 'temp')

if not os.path.exists(repo_dir):
    os.makedirs(repo_dir)

if not os.path.exists(temp_dir):
    os.makedirs(temp_dir)


os.chdir(temp_dir)

pkgs = []
rpm = SimpleRpmBuild('TestA', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestB')
pkgs.append(rpm)
# Used for install remove tests if requirement TestB is handled properly.

rpm = SimpleRpmBuild('TestB', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestA

rpm = SimpleRpmBuild('TestC', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Used for install remove tests as a negative control - should not be installed if you install TestA.

rpm = SimpleRpmBuild('TestD', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestE = 1.0.0-1')
pkgs.append(rpm)
# Used for install remove tests if requirement with = version is handled properly.

rpm = SimpleRpmBuild('TestE', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestD

rpm = SimpleRpmBuild('TestF', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestG >= 1.0.0-1, TestH = 1.0.0-1')
pkgs.append(rpm)
# Used for install remove tests if requirement with >= version and multiple requirements are handled properly.

rpm = SimpleRpmBuild('TestG', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestF

rpm = SimpleRpmBuild('TestH', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestF

rpm = SimpleRpmBuild('TestI', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestJ >= 1.0.0-2')
pkgs.append(rpm)
# Used for install test. This package cannot ge installed due to requirement.

rpm = SimpleRpmBuild('TestJ', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestI with unsufficient version

rpm = SimpleRpmBuild('TestK', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestM')
pkgs.append(rpm)
# Used for remove tests. Multiple packages require TestM therefore TestM cannot be removed if package is required by
# other package.

rpm = SimpleRpmBuild('TestL', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestM')
pkgs.append(rpm)
# Used for remove tests. Multiple packages require TestM therefore TestM cannot be removed if package is required by
# other package.

rpm = SimpleRpmBuild('TestM', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Requirement of TestK and TestL.

rpm = SimpleRpmBuild('TestN', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)
# Used in upgrade tests

rpm = SimpleRpmBuild('TestO', '1.0.0', '1', ['noarch'])
rpm.add_requires('TestC')
rpm.add_provides('ProvideA')
pkgs.append(rpm)

repo = YumRepoBuild(pkgs)

repo.repoDir = repo_dir

repo.make("noarch")

shutil.rmtree(temp_dir)

print("DNF repo is located at %s" % repo.repoDir)
