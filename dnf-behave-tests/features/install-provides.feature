Feature: Install RPMs by provides


Scenario: Install an RPM by provide that equals to e:v-r
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install 'filesystem = 0:3.9-2.fc29'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by provide that is greater than e:vr
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install 'filesystem > 0:3.9-2'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by provide that is greater or equal to e:vr
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install 'filesystem >= 0:3.9-2'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by provide that is lower than e:vr
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install 'glibc < 0:2.28-26.fc29'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-9.fc29.x86_64            |
        | install       | glibc-common-0:2.28-9.fc29.x86_64     |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64      |
        | install       | basesystem-0:11-6.fc29.noarch         |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by provide that is lower or equal to e:vr
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install 'glibc <= 0:2.28-26.fc29'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-26.fc29.x86_64           |
        | install       | glibc-common-0:2.28-26.fc29.x86_64    |
        | install       | glibc-all-langpacks-0:2.28-26.fc29.x86_64     |
        | install       | basesystem-0:11-6.fc29.noarch         |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
