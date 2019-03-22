Feature: Subtitute variables in mirrorlist

@bz1651092
Scenario: Variables are substituted in mirrorlist URLs
Given I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-noarch"
  And I create and substitute file "/etc/yum.repos.d/test.repo" with
  """
  [testrepo]
  name=testrepo
  mirrorlist={context.dnf.installroot}/temp-repos/mirrorlist.txt
  enabled=1
  gpgcheck=0
  """
  And I do not set reposdir
  And I use the repository "testrepo"
  And I create and substitute file "/temp-repos/mirrorlist.txt" with
  """
  file:///{context.dnf.installroot}/temp-repos/base-$basearch/
  """
Then I set config option "basearch" to "noarch"
 And I execute dnf with args "install setup"
Then the exit code is 0
 And Transaction is following
     | Action        | Package                       |
     | install       | setup-0:2.12.1-1.fc29.noarch  |
