Feature: Testing DNF metadata handling

@bz1644283
Scenario: update expired metadata on first dnf update
Given I create directory "/temp-repos/temp-repo"
  And I configure a new repository "testrepo" with
      | key             | value                                          |
      | baseurl         | {context.dnf.installroot}/temp-repos/temp-repo |
      | metadata_expire | 1s                                             |
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
 Then the exit code is 0
 When I execute dnf with args "list all"
 Then the exit code is 0
  And stdout contains "testrepo"
Given I copy directory "{context.scenario.repos_location}/dnf-ci-fedora" to "/temp-repos/temp-repo/dnf-ci-fedora"
 Then the exit code is 0
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
 Then the exit code is 0
 #Ensure metadata are expired
  And I execute "sleep 2s"
 Then I execute dnf with args "update"
 Then the exit code is 0
 Then I execute dnf with args "list all"
 Then the exit code is 0
  And stdout contains "\s+wget.src\s+1.19.5-5.fc29\s+testrepo"


@bz1866504
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


@bz1866504
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
  And I set up a http server for directory "/a"
  And I configure a new repository "test" with
        | key      | value                                                 |
        | gpgcheck | 0                                                     |
        | baseurl  | http://localhost:{context.dnf.ports[/a]}/b/c/d/e/f/g/ |
 When I execute dnf with args "--refresh install htop"
 Then file "/etc/malicious.file" does not exist
