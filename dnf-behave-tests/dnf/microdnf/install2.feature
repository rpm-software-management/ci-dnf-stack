Feature: microdnf install command on packages


@bz1734350
Scenario: Install package from local repodata with local xml:base
#2. local repo with local packages (different package location specified using xml:base)
Given I copy repository "dnf-ci-fedora" for modification
  And I generate repodata for repository "dnf-ci-fedora" with extra arguments "--baseurl file://{context.dnf.installroot}/xml_base/dnf-ci-fedora"
  And I use repository "dnf-ci-fedora"
  And I copy directory "{context.dnf.repos[dnf-ci-fedora].path}" to "/xml_base/dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install       | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
  And file "/xml_base/dnf-ci-fedora/x86_64/kernel-4.18.16-300.fc29.x86_64.rpm" exists
