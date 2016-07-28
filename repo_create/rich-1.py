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
rpm.add_requires('(TestB or TestC)')
rpm.add_recommends('TestC')
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestB', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)

rpm = SimpleRpmBuild('TestC', '1.0.0', '1', ['noarch'])
pkgs.append(rpm)

repo = YumRepoBuild(pkgs)

repo.repoDir = repo_dir

repo.make("noarch")

shutil.rmtree(temp_dir)
