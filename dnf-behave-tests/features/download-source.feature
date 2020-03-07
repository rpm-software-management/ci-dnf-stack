Feature: Tests for picking the appropriate download source


@not.with_os=rhel__eq__8
@bz1775184
Scenario: baseurl is used if all mirrors from mirrorlist fail
Given I create directory "/baseurlrepo"
  And I execute "createrepo_c {context.dnf.installroot}/baseurlrepo"
  And I create file "/tmp/mirrorlist" with
      """
      file:///nonexistent.repo
      http://127.0.0.1:5000/nonexistent
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/baseurlrepo    |
      | mirrorlist | {context.dnf.installroot}/tmp/mirrorlist |
 When I execute dnf with args "makecache"
 Then the exit code is 0
  And stderr is empty


@not.with_os=rhel__eq__8
@bz1775184
Scenario: baseurl is used if mirrorlist file cannot be found
Given I create directory "/baseurlrepo"
  And I execute "createrepo_c {context.dnf.installroot}/baseurlrepo"
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/baseurlrepo    |
      | mirrorlist | {context.dnf.installroot}/tmp/mirrorlist |
 When I execute dnf with args "makecache"
 Then the exit code is 0
  And stderr is empty


@not.with_os=rhel__eq__8
@bz1775184
Scenario: baseurl is used if mirrorlist file is empty
Given I create directory "/baseurlrepo"
  And I execute "createrepo_c {context.dnf.installroot}/baseurlrepo"
  And I create file "/tmp/mirrorlist" with
      """
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/baseurlrepo    |
      | mirrorlist | {context.dnf.installroot}/tmp/mirrorlist |
 When I execute dnf with args "makecache"
 Then the exit code is 0
  And stderr is empty


Scenario: no working donwload source result in an error
Given I create directory "/baseurlrepo"
  And I execute "createrepo_c {context.dnf.installroot}/baseurlrepo"
  And I create file "/tmp/mirrorlist" with
      """
      file:///nonexistent.repo
      http://127.0.0.1:5000/nonexistent
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/I_dont_exist   |
      | mirrorlist | {context.dnf.installroot}/tmp/mirrorlist |
 When I execute dnf with args "makecache"
 Then the exit code is 1
  And stderr contains "Errors during downloading metadata for repository 'testrepo':"
  And stderr contains "- Curl error \(37\): Couldn't read a file:// file for file:///nonexistent.repo/repodata/repomd.xml \[Couldn't open file /nonexistent.repo/repodata/repomd.xml\]"
  And stderr contains "- Curl error \(7\): Couldn't connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml \[Failed to connect to 127.0.0.1 port 5000: Connection refused\]"
  And stderr contains "- Curl error \(37\): Couldn't read a file:// file for file:///tmp/dnf_ci_installroot_.*/I_dont_exist/repodata/repomd.xml \[Couldn't open file /tmp/dnf_ci_installroot_.*/I_dont_exist/repodata/repomd.xml\]"
  And stderr contains "Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried"


Scenario: mirrorlist is prefered over baseurl
Given I create directory "/baseurlrepo"
  And I execute "createrepo_c {context.dnf.installroot}/baseurlrepo"
  And I create directory "/mirrorlistrepo"
  And I copy file "{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm" to "/mirrorlistrepo/setup-2.12.1-1.fc29.noarch.rpm"
  And I execute "createrepo_c {context.dnf.installroot}/mirrorlistrepo"
  And I create and substitute file "/tmp/mirrorlist" with
      """
      file://{context.dnf.installroot}/mirrorlistrepo
      """
  And I configure a new repository "testrepo" with
      | key        | value                                    |
      | baseurl    | {context.dnf.installroot}/baseurlrepo    |
      | mirrorlist | {context.dnf.installroot}/tmp/mirrorlist |
 When I execute dnf with args "install setup"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | setup-0:2.12.1-1.fc29.noarch |
