#!/usr/bin/python -tt

import re
import subprocess


class dnf_upgrage_to():
    def create_repo(self):
        with open('/etc/yum.repos.d/dnf-pull-requests.repo', 'w') as f:
            f.write('[dnf-pull-requests]\nname=dnf-pull-requests\nbaseurl=https://copr-be.cloud.fedoraproject.org'
                    '/results/rpmsoftwaremanagement/dnf-pull-requests/fedora-rawhide-x86_64/\nenabled=1\ngpgcheck=0')

    def dnf_version(self):
        f = open("/initial_settings/ci-dnf-stack.log")
        version = []
        for line in f:
            m = re.search("(dnf-\d+[.]\d+[.]\d+-\d+[.]git[.][a-zA-Z0-9.]+[.]fc2)", line)
            if m:

                version.append(m.group(0) + "4")
        version = list(set(version))
        assert len(version) == 1
        return version
    def upgrade_dnf_dependencies_from_nightly(self):
        with open('/etc/yum.repos.d/dnf-nightly.repo', 'w') as f:
            f.write('[dnf-nightly]\nname=dnf-nightly\nbaseurl=https://copr-be.cloud.fedoraproject.org/results/'
                    'rpmsoftwaremanagement/dnf-nightly/fedora-rawhide-x86_64/\nenabled=1\ngpgcheck=0')
        return subprocess.check_call(['dnf', 'upgrade', '-y', '--disablerepo=*', '--enablerepo=dnf-nightly'])

    def upgrade_dnf_from_pull_request(self, pkg):
        return subprocess.check_call(['dnf', 'upgrade-to', '-y'] + pkg)

installer = dnf_upgrage_to()
installer.upgrade_dnf_dependencies_from_nightly()
installer.create_repo()
installer.upgrade_dnf_from_pull_request(installer.dnf_version())
