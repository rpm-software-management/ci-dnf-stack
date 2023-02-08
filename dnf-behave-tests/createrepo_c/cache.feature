Feature: Tests createrepo_c --cache option


Scenario: create and use cache files
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create symlink "/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"
  And I create directory "/cache"
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type          | File                                | Checksum Type | Compression Type |
      | primary       | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists     | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other         | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type          | File                                | Checksum Type | Compression Type |
      | primary       | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists     | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other         | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
  And file "/cache/package-devel-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists
  And file "/cache/package-libs-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists
  And file "/cache/package-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists


@bz1686812
Scenario: created cache files respect umask setting
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I set umask to "0022"
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And file "/cache/package-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[0-9]*-[0-9]*" has mode "0644"


@bz1686812
Scenario: created cache files respect umask setting
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I set umask to "0066"
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And file "/cache/package-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[0-9]*-[0-9]*" has mode "0600"


@bz1686812
Scenario: created cache files respect umask setting
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I set umask to "0000"
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And file "/cache/package-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[0-9]*-[0-9]*" has mode "0666"
