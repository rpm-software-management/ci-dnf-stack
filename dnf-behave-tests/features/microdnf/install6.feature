@no_installroot
Feature: microdnf install command on packages


@bz1734350
@not.with_os=rhel__eq__8
Scenario: Install packages from remote repodata with xml:base pointing to packages on different remote
#6. remote repo with remote packages (different package location (different url) specified using xml:base)
Given I make packages from repository "dnf-ci-fedora" accessible via http
  And I copy repository "dnf-ci-fedora" for modification
  And I execute "createrepo_c --baseurl http://localhost:{context.dnf.ports[dnf-ci-fedora]} /{context.dnf.repos[dnf-ci-fedora].path}"
  And I use repository "dnf-ci-fedora" as http
  And I execute microdnf with args "install dwm"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | dwm-0:6.1-1.x86_64                        |
