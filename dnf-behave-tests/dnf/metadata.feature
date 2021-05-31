Feature: Testing DNF metadata handling


@bz1644283
Scenario: update expired metadata on first dnf run
Given I create directory "temp-repo"
  And I configure a new repository "testrepo" with
      | key             | value                               |
      | baseurl         | {context.dnf.installroot}/temp-repo |
      | metadata_expire | 0s                                  |
  And I execute "createrepo_c ." in "{context.dnf.installroot}/temp-repo"
  And I execute dnf with args "makecache"
  And I copy file "{context.scenario.repos_location}/simple-base/x86_64/labirinto-1.0-1.fc29.x86_64.rpm" to "/temp-repo/"
  # Ensure metadata are expired
  And I execute "sleep 1s"
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repo"
 When I execute dnf with args "repoquery --all"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      labirinto-0:1.0-1.fc29.x86_64
      """


@bz1866505
Scenario: I cannot create/overwrite a file in /etc from local repository
# This directory structure is needed at the repo source so that it can be matched on the system running dnf
# the path where to donwload the file ends up looking something like this:
# /var/cache/dnf/test-622efad968597580/tmpdir.2fwp3B/../../../../../etc/malicious.file -> /etc/malicious.file
Given I create file "/a/etc/malicious.file" with
      """
      my evil config
      """
  And I create file "/a/b/c/d/e/repodata/repomd.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <repomd>
          <data type="primary">
              <location href="../../../../../etc/malicious.file"/>
          </data>
      </repomd>
      """
 When I execute dnf with args "--repofrompath=test,{context.dnf.installroot}/a/b/c/d/e/ --repo test --refresh --nogpgcheck install htop"
 Then file "/etc/malicious.file" does not exist


@bz1866505
Scenario: I cannot create/overwrite a file in /etc from remote repository
Given I create file "/a/etc/malicious.file" with
      """
      my evil config
      """
  And I create file "/a/b/c/d/e/f/g/repodata/repomd.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <repomd>
          <data type="primary">
              <location href="../../../../../etc/malicious.file"/>
          </data>
      </repomd>
      """
  And I start http server "malicious_server" at "{context.dnf.installroot}/a"
  And I configure a new repository "test" with
        | key      | value                                                             |
        | gpgcheck | 0                                                                 |
        | baseurl  | http://0.0.0.0:{context.dnf.ports[malicious_server]}/b/c/d/e/f/g/ |
 When I execute dnf with args "--refresh install htop"
 Then file "/etc/malicious.file" does not exist
