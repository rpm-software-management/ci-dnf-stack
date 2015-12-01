#!/usr/bin/python3 -tt

import subprocess
from sys import argv
import dnf


class DnfEnvSetup:
    def create_repo(self, job_name):
        with open('/etc/yum.repos.d/dnf-pull-requests.repo', 'w') as f:
            f.write('[dnf-pull-requests]\nname=dnf-pull-requests\nbaseurl=https://copr-be.cloud.fedoraproject.org'
                    '/results/rpmsoftwaremanagement/' + job_name +
                    '/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')

    def command_cl_runner(self, command_in_list):
        command = ' '.join(command_in_list)
        print('-'*80)
        print("\nINFO: The following command will be performed: {}\n".format(command))
        print('-'*80)
        cmd_run = subprocess.check_output(command_in_list, stderr=subprocess.STDOUT)
        print(cmd_run.decode())

    def dnf_version(self, package_name):
        with dnf.Base() as base:
            base.read_all_repos()
            base.fill_sack()
            query = base.sack.query().filter(nevra__glob=package_name + '*').filter(arch__neq="src")
            assert len(query) > 0
            for n in range(0, len(query)):
                str(query[0]) == str(query[n])
            return str(query[0])

    def upgrade_dnf_dependencies_from_nightly(self):
        with open('/etc/yum.repos.d/dnf-nightly.repo', 'w') as f:
            f.write('[dnf-nightly]\nname=dnf-nightly\nbaseurl=https://copr-be.cloud.fedoraproject.org/results/'
                    'rpmsoftwaremanagement/dnf-nightly/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')
        command_in_list = ['dnf', 'install', '--disablerepo=*', '--enablerepo=dnf-nightly', '--allowerasing', '-y',
                           'dnf-plugins-core']
        self.command_cl_runner(command_in_list)
        command_in_list = ['dnf', 'upgrade', '-y', '--disablerepo=*', '--enablerepo=dnf-nightly', '--best']
        self.command_cl_runner(command_in_list)

    def upgrade_copr_built_package(self, pkg):
        command_in_list = ['dnf', 'install', '-y', '--allowerasing', pkg]
        self.command_cl_runner(command_in_list)
        command_in_list = ['rpm', '-q', pkg]
        self.command_cl_runner(command_in_list)

installer = DnfEnvSetup()
installer.upgrade_dnf_dependencies_from_nightly()
package_name = argv[1]
job_name = argv[2]
if job_name != 'dnf-nightly':
    installer.create_repo(job_name)
installer.upgrade_copr_built_package(installer.dnf_version(package_name))
