@no_installroot
Feature: microdnf install command on packages


Background:
Given I delete file "/etc/dnf/dnf.conf"
  And I delete file "/etc/yum.repos.d/*.repo" with globs


@bz1734350
Scenario: Install package from local repodata with xml:base pointing to remote packages
#3. local repo with remote packages (different package location specified using xml:base)
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I execute "createrepo_c --baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]} /{context.dnf.repos[dnf-ci-fedora].path}"
  And I use repository "dnf-ci-fedora"
 When I execute microdnf with args "install abcde"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | flac-0:1.3.2-8.fc29.x86_64                |
      | install       | abcde-0:2.9.2-1.fc29.noarch               |
