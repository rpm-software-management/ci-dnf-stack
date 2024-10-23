@dnf5
Feature: microdnf install command on packages


@bz1734350
@bz1779757
Scenario: Install package from local repodata with local packages
#1. local repo with local packages
Given I use repository "dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install-dep   | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install-dep   | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |


@bz1734350
Scenario: Install package from local repodata with local xml:base
#2. local repo with local packages (different package location specified using xml:base)
Given I copy repository "dnf-ci-fedora" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl file://{context.dnf.installroot}/xml_base/dnf-ci-fedora"
  And I use repository "dnf-ci-fedora"
  And I copy directory "{context.dnf.repos[dnf-ci-fedora].path}" to "/xml_base/dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install-dep   | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install-dep   | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
  And file "/xml_base/dnf-ci-fedora/x86_64/kernel-4.18.16-300.fc29.x86_64.rpm" exists


@bz1734350
Scenario: Install package from local repodata with xml:base pointing to remote packages
#3. local repo with remote packages (different package location specified using xml:base)
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]}"
  And I use repository "dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install-dep   | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install-dep   | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |


@bz1734350
Scenario: Install packages from local repodata that have packages with xml:base pointing to a remote as well as local packages
#4. local repo with local and remote packages; installing both at the same time.
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I copy repository "dnf-ci-thirdparty" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]}"
  And I execute "mergerepo_c --repo file://{context.dnf.repos[dnf-ci-fedora].path} --repo file://{context.dnf.repos[dnf-ci-thirdparty].path}" in "{context.dnf.installroot}"
  And I configure a new repository "merged-repo" with
      | key     | value                                        |
      | baseurl | file://{context.dnf.installroot}/merged_repo |
  When I execute microdnf with args "install kernel alternator"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install-dep   | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install-dep   | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
      | install       | alternator-0:1.1-1.x86_64                 |


@bz1734350
Scenario: Install packages from remote repodata with remote packages
#5. remote repo with remote packages
Given I use repository "dnf-ci-fedora" as http
 When I execute microdnf with args "remove lame"
 When I execute microdnf with args "install lame"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install       | lame-0:3.100-4.fc29.x86_64                |
      | install-dep   | lame-libs-0:3.100-4.fc29.x86_64           |


@bz1734350
Scenario: Install packages from remote repodata with xml:base pointing to packages on different remote
#6. remote repo with remote packages (different package location (different url) specified using xml:base)
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]}"
  And I use repository "dnf-ci-fedora" as http
  And I execute microdnf with args "install dwm"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | install       | dwm-0:6.1-1.x86_64                        |


@bz1855542
@bz1725863
Scenario: Install a package specifying a lower version than currently installed
Given I use repository "dnf-ci-fedora"
  And I use repository "dnf-ci-fedora-updates"
  And I successfully execute microdnf with args "install flac"
 When I execute microdnf with args "install flac-1.3.2-8.fc29"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                                   |
      | downgrade     | flac-0:1.3.2-8.fc29.x86_64                |
