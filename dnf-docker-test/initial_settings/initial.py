#!/usr/bin/python3 -tt

import fnmatch
import glob
import dnf
import os.path
import shutil
import subprocess
import sys


class DnfEnvSetup:
    def create_repo(self, job_name):
        with open('/etc/yum.repos.d/dnf-pull-requests.repo', 'w') as f:
            f.write('[dnf-pull-requests]\nname=dnf-pull-requests\nbaseurl=https://copr-be.cloud.fedoraproject.org'
                    '/results/rpmsoftwaremanagement/' + job_name +
                    '/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')

    def command_cl_runner(self, command_in_list):
        command = ' '.join(command_in_list)
        print('='*160)
        print("\nINFO: The following command will be performed: {}\n".format(command))
        print('='*160)
        commandrun = subprocess.Popen(command_in_list, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        output = commandrun.communicate()[0]
        print(output)
        if commandrun.returncode != 0:
            print('=' * 160)
            sys.exit("\nERROR: The command {} FAILED\n".format(command))

    def dnf_version(self, package_name):
        with dnf.Base() as base:
            base.read_all_repos()
            base.fill_sack()
            query = base.sack.query().filter(nevra__glob=package_name + '*').filter(arch__neq="src")
            assert len(query) > 0
            for n in range(0, len(query)):
                assert str(query[0]) == str(query[n])
            return str(query[0])

    def upgrade_dnf_dependencies_from_nightly(self, update_copr_repo):
        with open('/etc/yum.repos.d/dnf-nightly.repo', 'w') as f:
            f.write('[' + update_copr_repo.rsplit('/', 1)[1] + ']\nname=' + update_copr_repo.rsplit('/', 1)[1] +
                    '\nbaseurl=https://copr-be.cloud.fedoraproject.org/results/' +
                    update_copr_repo + '/fedora-$releasever-$basearch/\nenabled=1\ngpgcheck=0')
        command_in_list = ['dnf', 'install', '--disablerepo=*', '--enablerepo=' + update_copr_repo.rsplit('/', 1)[1],
                           '--allowerasing', '-y', 'dnf-plugins-core']
        self.command_cl_runner(command_in_list)
        command_in_list = ['dnf', '-y', '--disablerepo=*', '--enablerepo=' + update_copr_repo.rsplit('/', 1)[1],
                           '--best', 'upgrade']
        self.command_cl_runner(command_in_list)

    def upgrade_copr_built_package(self, pkg):
        command_in_list = ['dnf', 'install', '-y', '--allowerasing', pkg]
        self.command_cl_runner(command_in_list)
        command_in_list = ['rpm', '-q', pkg]
        self.command_cl_runner(command_in_list)

installer = DnfEnvSetup()
package_name = sys.argv[1]
job_name = sys.argv[2]
update_copr_repo = sys.argv[3]
installer.upgrade_dnf_dependencies_from_nightly(update_copr_repo)
if job_name != 'dnf-nightly':
    if job_name != 'local-build':
        installer.create_repo(job_name)
if job_name == 'local-build':
    project_dirs = glob.glob('/local_rpm/*/*')
    for project_dir in sorted(project_dirs):
        spec = glob.glob(project_dir + '/*.spec')
        cmd = ['dnf', '-y', '--allowerasing', 'builddep'] + spec
        installer.command_cl_runner(cmd)
        rpm_path = os.path.split(project_dir)[0]
        os.chdir(project_dir)
        temp_rpm_file = os.path.join(rpm_path, 'build')
        os.mkdir(temp_rpm_file)
        tito_cmd = ['tito', 'build', '--rpm', '--test','--output={}'.format(temp_rpm_file)]
        installer.command_cl_runner(tito_cmd)
        rpm_files = []
        for root, dirnames, filenames in os.walk(temp_rpm_file):
            for filename in fnmatch.filter(filenames, '*.rpm'):
                rpm_files.append(os.path.join(root, filename))
        for rpm_file in rpm_files:
            if not rpm_file.endswith('.src.rpm'):
                shutil.move(rpm_file, rpm_path)
        rpms = glob.glob(rpm_path + '/*.rpm')
        cmd = ['dnf', '-y', '--allowerasing', 'install'] + rpms
        installer.command_cl_runner(cmd)
else:
    installer.upgrade_copr_built_package(installer.dnf_version(package_name))
repo_files = glob.glob('/etc/yum.repos.d/*')
for repo_file in repo_files:
    shutil.move(repo_file, '/temp/dnf.repo')
shutil.rmtree('/var/cache/dnf')
os.mkdir('/var/cache/dnf')
