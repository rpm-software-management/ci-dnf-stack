#!/usr/bin/python -tt

import os
import re
import subprocess


SPEC_BASE = """\
Name:		{NAME}
Version:	1.0.0
Release:	{REL}
Summary:	Richdeps test package

#Group:
License:	MIT
URL:		http://127.0.0.1/
Source0:	testdata.tar.gz
BuildArch:  noarch

#BuildRequires:

Requires:   {REQ}

%description
Richdeps test package

%prep
%setup -q -n data/
%install
%files
%license
%doc
%changelog\n"""

dir_name = "test-1/spec"
dir_rpm = "test-1/build"


def ensure_dir(f):
    if not os.path.exists(f):
        os.makedirs(f)


def spec_creator():
    with open("spec.txt", 'r') as f:
        for line in f:
            line = line.split("\t")
            name = line[0]
            rel = line[1]
            try:
                req = line[2]
                spec_bases = SPEC_BASE
                m=re.search('\w+', req)
                if not m:
                    spec_bases = re.sub("Requires:.*REQ.*", '', SPEC_BASE)
            except IndexError:
                spec_bases = re.sub("Requires:.*REQ.*", '', SPEC_BASE)
                req = ""
            new_file = spec_bases.format(NAME=name, REL=rel, REQ=req)
            ensure_dir(dir_name)
            new_spec = open(dir_name + "/" + name + "-" + rel + ".spec", "w")
            new_spec.write(new_file)


def create_rpm():
    subprocess.check_call(['rpmdev-setuptree'], stdout=subprocess.PIPE)
    subprocess.check_call(['cp *tar.gz ~/rpmbuild/SOURCES'], shell=True)
    subprocess.check_call(['cp ' + dir_name + '/* ~/rpmbuild/SPECS'], shell=True)
    subprocess.check_call(['rpmbuild ~/rpmbuild/SPECS/* -bb --rmspec'], shell=True)
    ensure_dir(dir_rpm)
    subprocess.check_call(['mv ~/rpmbuild/RPMS/noarch/* ' + dir_rpm], shell=True)


def create_repo():
    subprocess.check_call(['createrepo_c -v ' + dir_rpm + '/ --no-database --simple-md-filenames'], shell=True)


spec_creator()
create_rpm()
create_repo()
