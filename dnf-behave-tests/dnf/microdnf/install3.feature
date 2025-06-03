Feature: microdnf install command on packages


@bz1734350
Scenario: Install package from local repodata with xml:base pointing to remote packages
#3. local repo with remote packages (different package location specified using xml:base)
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]}"
  And I use repository "dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install       | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
