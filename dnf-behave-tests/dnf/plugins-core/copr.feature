@destructive
Feature: Test the COPR plugin

Background:
Given I create directory "/{context.dnf.tempdir}/copr"
  And I start http server "copr" at "{context.dnf.tempdir}/copr"
  And I create and substitute file "//etc/dnf/plugins/copr.conf" with
      """
      [main]
      distribution = Fedora
      releasever = 30
      [testhub]
      hostname = localhost
      protocol = http
      port = {context.dnf.ports[copr]}
      """
  And I create and substitute file "/{context.dnf.tempdir}/copr/coprs/testuser/testproject/repo/fedora-30/dnf.repo" with
      """
      [copr:localhost:testuser:testproject]
      name=Copr test project
      baseurl=http://project_base_url/
      type=rpm-md
      """


Scenario: Test enabling and disabling a project
 When I execute dnf with args "copr enable testhub/testuser/testproject"
 Then the exit code is 0
  And stdout is
      """
      Repository successfully enabled.
      """
  And stderr is
      """
      Enabling a Copr repository. Please note that this repository is not part
      of the main distribution, and quality may vary.

      The Fedora Project does not exercise any power over the contents of
      this repository beyond the rules outlined in the Copr FAQ at
      <https://docs.pagure.org/copr.copr/user_documentation.html#what-i-can-build-in-copr>,
      and packages are not held to any quality or security level.

      Please do not file bug reports about these packages in Fedora
      Bugzilla. In case of problems, contact the owner of this repository.
      """
 When I execute dnf with args "copr disable testhub/testuser/testproject"
 Then the exit code is 0
  And stdout is
      """
      Repository successfully disabled.
      """
  And stderr is empty


Scenario: Test disabling a project that is not enabled
 When I execute dnf with args "copr disable testhub/testuser/testproject"
 Then the exit code is 1
  And stderr is
      """
      Error: Failed to disable copr repo testuser/testproject
      """


Scenario: Test enabling a non-existent repo
 When I execute dnf with args "copr enable testhub/testuser/nonexistent"
 Then the exit code is 1
  And stderr is
      """
      Enabling a Copr repository. Please note that this repository is not part
      of the main distribution, and quality may vary.

      The Fedora Project does not exercise any power over the contents of
      this repository beyond the rules outlined in the Copr FAQ at
      <https://docs.pagure.org/copr.copr/user_documentation.html#what-i-can-build-in-copr>,
      and packages are not held to any quality or security level.

      Please do not file bug reports about these packages in Fedora
      Bugzilla. In case of problems, contact the owner of this repository.
      Error: It wasn't possible to enable this project.
      Project testuser/nonexistent does not exist.
      """


Scenario: Test enabling a repo with invalid copr configuration
Given I create and substitute file "//etc/dnf/plugins/copr.conf" with
      """
      [main]
      distribution = Fedora
      releasever = 30
      [testhub]
      hostname = localhost
      protocol = http
      # hopefully nothing is ever listening on this port
      port = 2
      """
 When I execute dnf with args "copr enable testhub/testuser/testproject"
 Then the exit code is 1
  And stderr is
      """
      Enabling a Copr repository. Please note that this repository is not part
      of the main distribution, and quality may vary.

      The Fedora Project does not exercise any power over the contents of
      this repository beyond the rules outlined in the Copr FAQ at
      <https://docs.pagure.org/copr.copr/user_documentation.html#what-i-can-build-in-copr>,
      and packages are not held to any quality or security level.

      Please do not file bug reports about these packages in Fedora
      Bugzilla. In case of problems, contact the owner of this repository.
      Error: Failed to connect to http://localhost:2/coprs/testuser/testproject/repo/fedora-30/dnf.repo?arch=x86_64: Connection refused
      """


Scenario: Test enabling a repo without any builds for the distribution
Given I create and substitute file "//etc/dnf/plugins/copr.conf" with
      """
      [main]
      distribution = Fedora
      releasever = 31
      [testhub]
      hostname = localhost
      protocol = http
      port = {context.dnf.ports[copr]}
      """
  And HTTP server GET /coprs/testuser/testproject/repo/fedora-31/dnf.repo?arch=x86_64 response headers are
      """
      Copr-Error-Data=eyJhdmFpbGFibGUgY2hyb290cyI6IFsiZmVkb3JhLTMwLXg4Nl82NCJdfQ==
      """
  And the server starts responding with HTTP status code 404
 When I execute dnf with args "copr enable testhub/testuser/testproject"
 Then the exit code is 1
  And stderr is
      """
      Enabling a Copr repository. Please note that this repository is not part
      of the main distribution, and quality may vary.

      The Fedora Project does not exercise any power over the contents of
      this repository beyond the rules outlined in the Copr FAQ at
      <https://docs.pagure.org/copr.copr/user_documentation.html#what-i-can-build-in-copr>,
      and packages are not held to any quality or security level.

      Please do not file bug reports about these packages in Fedora
      Bugzilla. In case of problems, contact the owner of this repository.
      Error: It wasn't possible to enable this project.
      Repository 'fedora-31-x86_64' does not exist in project 'testuser/testproject'.
      Available repositories: 'fedora-30-x86_64'

      If you want to enable a non-default repository, use the following command:
        'dnf copr enable testuser/testproject <repository>'
      But note that the installed repo file will likely need a manual modification.
      """


Scenario: Test enabling and disabling a repository with dependencies
Given I create and substitute file "/{context.dnf.tempdir}/copr/coprs/testuser/project-with-deps/repo/fedora-30/dnf.repo" with
      """
      [copr:localhost:testuser:project-with-deps]
      name=Copr test project
      baseurl=http://repo_base_url/
      type=rpm-md

      [coprdep:localhost:testuser:dep1]
      name=Copr dependency 1
      baseurl=http://repo_base_url/
      type=rpm-md

      [coprdep:some-external-repo]
      name=Copr dependency 2
      baseurl=https://repo_base_url/
      type=rpm-md
      """
 When I execute dnf with args "copr enable testhub/testuser/project-with-deps"
 Then the exit code is 0
  And stdout is
      """
      Repository successfully enabled.
      """
  And stderr is
      """
      Enabling a Copr repository. Please note that this repository is not part
      of the main distribution, and quality may vary.

      The Fedora Project does not exercise any power over the contents of
      this repository beyond the rules outlined in the Copr FAQ at
      <https://docs.pagure.org/copr.copr/user_documentation.html#what-i-can-build-in-copr>,
      and packages are not held to any quality or security level.

      Please do not file bug reports about these packages in Fedora
      Bugzilla. In case of problems, contact the owner of this repository.

      Maintainer of the enabled Copr repository decided to make
      it dependent on other repositories. Such repositories are
      usually necessary for successful installation of RPMs from
      the main Copr repository (they provide runtime dependencies).

      Be aware that the note about quality and bug-reporting
      above applies here too, Fedora Project doesn't control the
      content. Please review the list:

       1. [coprdep:localhost:testuser:dep1]
          baseurl=http://repo_base_url/

       2. [coprdep:some-external-repo]
          baseurl=https://repo_base_url/

      These repositories have been enabled automatically.
      """
 When I execute dnf with args "copr disable testhub/testuser/project-with-deps"
 Then the exit code is 0
  And stdout is
      """
      Repository successfully disabled.
      """
  And stderr is empty
