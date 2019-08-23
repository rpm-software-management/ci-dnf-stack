Feature: Test for dnf repoquery, options --all, --installed, --available, --upgrades, --extras, --repo, --location

# --extras: installed pkgs, not from known repos
Scenario: dnf repoquery --extras (when there are such pkgs) Given I use the repository "dnf-ci-fedora"
 When I execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm"
 When I execute dnf with args "repoquery --extras"
 Then stdout contains "setup-0:2.12.1-1.fc29.noarch"
 Then stdout does not contain "\*system\*"


Scenario: dnf repoquery --extras XTest (when there's no such extra pkg installed)
 When I execute dnf with args "repoquery --extras XTest"
 Then the exit code is 0
 Then stdout does not contain "\*system\*"
 Then stdout does not contain "\*Test\*"


Scenario: dnf repoquery --available setup* (when there are no such pkgs)
 When I execute dnf with args "repoquery --available setup\*"
 Then the exit code is 0
 Then stdout does not contain "\*system\*"
 Then stdout does not contain "\*setup\*"


Scenario: dnf repoquery --available glibc\* (when there are such pkgs in repos)
Given I use the repository "dnf-ci-fedora"
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "repoquery --available glibc\*"
 Then the exit code is 0
 Then stdout contains "glibc-0:2.28-9.fc29.src"
 Then stdout contains "glibc-0:2.28-26.fc29.src"
 Then stdout contains "glibc-0:2.28-26.fc29.x86_64"
 Then stdout contains "glibc-0:2.28-9.fc29.x86_64"
 Then stdout does not contain "setup"
 Then stdout does not contain "flac"


Scenario: dnf repoquery --available CQRlib\* with --repo  (when there are such pkgs in listed repos)
Given I do not disable all repos
 When I execute dnf with args "repoquery --available --repo dnf-ci-fedora --repo dnf-ci-fedora-updates CQRlib\*"
 Then the exit code is 0
 Then stdout contains "CQRlib-0:1.1.1-4.fc29.x86_64"
 Then stdout contains "CQRlib-0:1.1.2-16.fc29.src"
 Then stdout contains "CQRlib-0:1.1.2-16.fc29.x86_64"
 Then stdout contains "CQRlib-devel-0:1.1.2-16.fc29.src"
 Then stdout contains "CQRlib-devel-0:1.1.2-16.fc29.x86_64"
 Then stdout does not contain "glibc"
 Then stdout does not contain "system"


Scenario: dnf repoquery --upgrades (when there are such pkgs)
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "repoquery --upgrades"
 Then stdout contains "glibc-0:2.28-26.fc29.x86_64"
 Then stdout does not contain "filesystem"
 Then stdout does not contain "flac"


Scenario: dnf repoquery --upgrades Test\* (when there are no such pkgs)
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I disable the repository "dnf-ci-fedora"
 When I execute dnf with args "repoquery --upgrades glibc\*"
 Then stdout is empty
   

Scenario: dnf repoquery --upgrades --repo dnf-ci-fedora-updates (when there are such pkgs in listed repos)
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I do not disable all repos
 When I execute dnf with args "repoquery --upgrades --repo dnf-ci-fedora-updates"
 Then the exit code is 0
 Then stdout does not contain "setup"
 Then stdout does not contain "basesystem"
 Then stdout contains "glibc-0:2.28-26.fc29.x86_64"
 Then stdout contains "glibc-all-langpacks-0:2.28-26.fc29.x86_64"
 Then stdout contains "glibc-common-0:2.28-26.fc29.x86_64"


Scenario: dnf repoquery --installed setup\* (when there are no such pkgs)
 When I execute dnf with args "repoquery --installed setup\*"
 Then stdout does not contain "setup"
   

Scenario: dnf repoquery --installed glibc\* (when there are such pkgs)
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "upgrade glibc"
 Then the exit code is 0
 When I execute dnf with args "repoquery --installed glib\*"
 Then the exit code is 0
 Then stdout contains "glibc-0:2.28-26.fc29.x86_64"
 Then stdout contains "glibc-common-0:2.28-26.fc29.x86_64"
 Then stdout contains "glibc-all-langpacks-0:2.28-26.fc29.x86_64"

   
Scenario: dnf repoquery --installed setup filesystem (when setup is installed and filesystem not)
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "repoquery --installed setup filesystem"
 Then the exit code is 0
 Then stdout contains "setup-0:2.12.1-1.fc29.noarch"
 Then stdout does not contain "filesystem"
  

Scenario: dnf repoquery --all glibc (when there's no such pkg)
 When I execute dnf with args "repoquery --all glibc"
 Then stdout is empty
   

Scenario: dnf repoquery --all glibc\* (when there are such pkgs)
Given I use the repository "dnf-ci-fedora"
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "repoquery --all glibc\*"
 Then stdout contains "glibc-0:2.28-26.fc29.src"
 Then stdout contains "glibc-0:2.28-9.fc29.src"
 Then stdout contains "glibc-0:2.28-9.fc29.x86_64"
 Then stdout contains "glibc-0:2.28-26.fc29.x86_64"
 Then stdout does not contain "\*system\*"
 Then stdout does not contain "setup"


Scenario: dnf repoquery --all --repo dnf-ci-fedora glibc\* (when there are such pkgs in listed repo)
Given I do not disable all repos
 When I execute dnf with args "repoquery --all --repo dnf-ci-fedora \*system\*"
 Then the exit code is 0
 Then stdout contains "basesystem-0:11-6.fc29.noarch"
 Then stdout contains "basesystem-0:11-6.fc29.src"
 Then stdout contains "filesystem-0:3.9-2.fc29.src"
 Then stdout contains "filesystem-0:3.9-2.fc29.x86_64"
 Then stdout contains "filesystem-content-0:3.9-2.fc29.x86_64"
 Then stdout does not contain "glibc"
 Then stdout does not contain "setup"


@bz1639827
Scenario: dnf repoquery --location
Given I use the repository "dnf-ci-fedora"
Given I use the repository "dnf-ci-fedora-updates"
Given I use the repository "dnf-ci-thirdparty"
 When I execute dnf with args "repoquery SuperRipper --location"
 Then the exit code is 0
 Then stdout matches line by line
 """
 .+/fixtures/repos/dnf-ci-thirdparty/src/SuperRipper-1.0-1.src.rpm
 .+/fixtures/repos/dnf-ci-thirdparty/x86_64/SuperRipper-1.0-1.x86_64.rpm
 """


# the bug is missing, fixed in upstream
@not.with_os=rhel__eq__8
@bz1744073
Scenario: dnf repoquery --querytags is working
 When I execute dnf with args "repoquery --querytags"
 Then the exit code is 0
 And stdout is
 """
 Available query-tags: use --queryformat ".. %{tag} .."

 name, arch, epoch, version, release, reponame (repoid), evr,
 debug_name, source_name, source_debug_name,
 installtime, buildtime, size, downloadsize, installsize,
 provides, requires, obsoletes, conflicts, sourcerpm,
 description, summary, license, url, reason
 """
