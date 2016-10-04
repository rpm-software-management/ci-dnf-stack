#!/usr/bin/python3 -tt

from rpmfluff import SimpleRpmBuild
from rpmfluff import YumRepoBuild
from pathlib import PurePosixPath
import os
import shutil
import subprocess

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
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestA', '3.0.0', '1', ['noarch'])
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestB', '1.0.0', '1', ['noarch'])
rpm.add_provides('TestA = 2.0.0')
rpm.add_obsoletes('TestA < 2.0.0')
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestC', '1.0.0', '1', ['noarch'])
rpm.add_provides('TestA = 4.0.0')
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestD', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestE', '1.0.0', '1', ['noarch'])
rpm.add_provides('TestD = 2.0.0')
rpm.add_obsoletes('TestD < 2.0.0')
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestF', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestF', '2.0.1', '1', ['noarch'])
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestG', '1.0.0', '1', ['noarch'])
rpm.add_provides('TestF = 3.0.0')
rpm.add_obsoletes('TestF < 3.0.0')
pkgs.append(rpm)

repo = YumRepoBuild(pkgs)

repo.repoDir = repo_dir

repo.make("noarch")

shutil.rmtree(temp_dir)

shutil.rmtree(os.path.join(repo_dir, 'repodata'))

subprocess.check_call(['createrepo_c', repo_dir])

print("DNF repo is located at %s" % repo.repoDir)
