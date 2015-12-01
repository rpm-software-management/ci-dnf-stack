#!/usr/bin/python -tt

import subprocess
from sys import argv
import dnf


class DnfEnvSetup():
    def create_repo(self):
        with open('/etc/yum.repos.d/dnf-pull-requests.repo', 'w') as f:
            f.write('[dnf-pull-requests]\nname=dnf-pull-requests\nbaseurl=https://copr-be.cloud.fedoraproject.org'
                    '/results/rpmsoftwaremanagement/dnf-pull-requests/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')

    def dnf_version(self, package_name):
        with dnf.Base() as base:
            base.read_all_repos()
            base.fill_sack()
            query = base.sack.query().filter(nevra__glob=package_name + argv[1] + '*').filter(arch__neq="src")
            assert len(query) > 0
            for n in range(0,len(query)):
                str(query[0]) == str(query[n])
            print ("\nINFO: DNF will upgrade to {}\n".format(str(query[0])))
            return str(query[0])

    def upgrade_dnf_dependencies_from_nightly(self):
        with open('/etc/yum.repos.d/dnf-nightly.repo', 'w') as f:
            f.write('[dnf-nightly]\nname=dnf-nightly\nbaseurl=https://copr-be.cloud.fedoraproject.org/results/'
                    'rpmsoftwaremanagement/dnf-nightly/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')
        subprocess.check_call(['dnf', 'install', '--disablerepo=*', '--enablerepo=dnf-nightly', '--allowerasing', '-y',
                               'dnf-plugins-core'])
        return subprocess.check_call(['dnf', 'upgrade', '-y', '--disablerepo=*', '--enablerepo=dnf-nightly', '--best'])

    def upgrade_dnf_from_pull_request(self, pkg):
        subprocess.check_call(['dnf', 'install', '-y', '--disablerepo=*', '--enablerepo=dnf-pull-requests',
                               '--allowerasing', pkg])
        subprocess.check_call(['rpm', '-q', pkg])

installer = DnfEnvSetup()
installer.upgrade_dnf_dependencies_from_nightly()
installer.create_repo()
installer.upgrade_dnf_from_pull_request(installer.dnf_version('dnf-'))
installer.upgrade_dnf_from_pull_request(installer.dnf_version('python2-dnf-'))
