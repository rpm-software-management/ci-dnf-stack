Feature: Testing DNF metadata handling

@bz1644283
Scenario: update expired metadata on first dnf update
Given I create directory "/temp-repos/temp-repo"
  And I create and substitute file "/etc/yum.repos.d/test.repo" with
  """
  [testrepo]
  name=testrepo
  baseurl={context.dnf.installroot}/temp-repos/temp-repo
  enabled=1
  gpgcheck=0
  metadata_expire=1s
  """
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
 Then the exit code is 0
 When I execute dnf with args "list all"
 Then the exit code is 0
  And stdout contains "testrepo"
Given I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/temp-repo/dnf-ci-fedora"
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

