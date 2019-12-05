@no_installroot
Feature: microdnf install command on packages


Background:
Given I delete file "/etc/dnf/dnf.conf"
  And I delete file "/etc/yum.repos.d/*.repo" with globs


@bz1734350
Scenario: Install package from local repodata with local xml:base
#2. local repo with local packages (different package location specified using xml:base)
Given I copy repository "dnf-ci-fedora" for modification
  And I use repository "dnf-ci-fedora"
  And I execute "createrepo_c --baseurl file://{context.dnf.installroot}/xml_base/dnf-ci-fedora /{context.dnf.repos[dnf-ci-fedora].path}"
  And I copy directory "{context.dnf.repos[dnf-ci-fedora].path}" to "/xml_base/dnf-ci-fedora"
 When I execute microdnf with args "install abcde"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | flac-0:1.3.2-8.fc29.x86_64                |
      | install       | abcde-0:2.9.2-1.fc29.noarch               |
  And file "/xml_base/dnf-ci-fedora/noarch/abcde-2.9.2-1.fc29.noarch.rpm" exists
