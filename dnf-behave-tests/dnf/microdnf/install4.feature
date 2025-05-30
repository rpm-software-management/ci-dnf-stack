Feature: microdnf install command on packages


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
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install       | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
      | install       | alternator-0:1.1-1.x86_64                 |
