#!/usr/bin/python -tt

import re
import subprocess


class DnfUpgrageTo():
    def create_repo(self):
        subprocess.check_call(['echo -ne "[dnf-pull-requests]\nname=dnf-pull-requests\nbaseurl=https://copr-be.'
                               'cloud.fedoraproject.org/results/rpmsoftwaremanagement/dnf-pull-requests/'
                               'fedora-rawhide-x86_64/\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/'
                               'dnf-pull-requests.repo'], shell=True)

    def dnf_version(self):
        f = open("/initial_settings/ci-dnf-stack.log")
        version = []
        for line in f:
            m = re.search("(dnf-\d+[.]\d+[.]\d+-\d+[.]git[.][a-zA-Z0-9.]+)[.]fc", line)
            if m:
                version.append(m.group(1))
        version = list(set(version))
        assert len(version) == 1
        m = re.search("(dnf-\d+[.]\d+[.]\d+)(-\d+[.]git[.][a-zA-Z0-9.]+)", version[0])
        dnf_in_repository = subprocess.check_output(['dnf', 'repoquery', '-q', m.group(1), '--queryformat',
                                                     '%{name}-%{version}-%{release}']).splitlines()
        dnf_in_repository = list(set(dnf_in_repository))
        assert len(dnf_in_repository) == 1
        return dnf_in_repository

    def upgrade_nightly(self):
        subprocess.check_call(['echo -ne "[dnf-nightly]\nname=dnf-nightly\nbaseurl=https://copr-be.cloud'
                               '.fedoraproject.org/results/rpmsoftwaremanagement/dnf-nightly/fedora-rawhide-x86_64/\n'
                               'enabled=1\ngpgcheck=0" > /etc/yum.repos.d/dnf-nightly.repo'], shell=True)
        return subprocess.check_call(['dnf', 'upgrade', '-y', '--disablerepo=*', '--enablerepo=dnf-nightly'])

    def upgrade(self, pkg):
        return subprocess.check_call(['dnf', 'upgrade-to', '-y', '--disablerepo=*',
                                      '--enablerepo=dnf-pull-requests'] + pkg)

installer = DnfUpgrageTo()
installer.upgrade_nightly()
installer.create_repo()
installer.upgrade(installer.dnf_version())
