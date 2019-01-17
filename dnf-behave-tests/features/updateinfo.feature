Feature: Listing available updates using the dnf updateinfo command


Scenario: Listing available updates
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
    And Transaction is following
        | Action        | Package                                  |
        | install       | setup-0:2.12.1-1.fc29.noarch             |
        | install       | basesystem-0:11-6.fc29.noarch            |
        | install       | filesystem-0:3.9-2.fc29.x86_64           |
        | install       | glibc-0:2.28-9.fc29.x86_64               |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64 |
        | install       | glibc-common-0:2.28-9.fc29.x86_64        |
        | install       | flac-0:1.3.2-8.fc29.x86_64               |
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "updateinfo list"
   Then the exit code is 0
   Then stdout contains "FEDORA-2999:002-02\s+enhancement\s+flac-1.3.3-8.fc29.x86_64"
   Then stdout contains "FEDORA-2018-318f184000\s+bugfix\s+glibc-2.28-26.fc29.x86_64"


Scenario Outline: updateinfo <summary alias> (when there's nothing to report)
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
   When I execute dnf with args "updateinfo summary"
   Then the exit code is 0
   Then stdout does not contain "Updates Infomation"
   Then stdout does not contain "Summary"
   Then stdout does not contain "1 Bugfix notice"
   Then stdout does not contain "1 Enhancement notice"

Examples: 
        | summary alias |
        | summary       |
        | --summary     |
 

Scenario Outline: updateinfo <summary alias> available (when there is an available update)
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <summary alias> available"
   Then the exit code is 0
   Then stdout contains "Updates Information Summary: available"
   Then stdout contains "1 Bugfix notice"
   Then stdout contains "1 Enhancement notice"

Examples: 
        | summary alias |
        | summary       |
        | --summary     |


Scenario Outline: updateinfo info
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <info alias> available"
   Then the exit code is 0
   Then stdout contains "\s+flac enhacements"
   Then stdout contains "Update ID:\sFEDORA-2999:002-02"
   Then stdout contains "Type:\senhancement"
   Then stdout contains "Description:\sEnhance some stuff"
   Then stdout contains "glibc bug fix"
   Then stdout contains "Update ID:\sFEDORA-2018-318f184000"
   Then stdout contains "Type:\sbugfix"
   Then stdout contains "Severity:\snone"

Examples: 
        | info alias |
        | info       |
        | --info     |
         

Scenario: updateinfo info security (when there's nothing to report)
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info security"
   Then the exit code is 0
   Then stdout does not contain "Update ID"


Scenario Outline: updateinfo <list alias>
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <list alias>"
   Then the exit code is 0
   Then stdout contains "FEDORA-2999:002-02\s+enhancement\s+flac-1.3.3-8.fc29.x86_64"
   Then stdout contains "FEDORA-2018-318f184000\s+bugfix\s+glibc-2.28-26.fc29.x86_64"

Examples:
        | list alias |
        | list       |
        | --list     |


Scenario: updateinfo list all security
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo list all bugfix"
   Then the exit code is 0
   Then stdout contains "FEDORA-2018-318f184000\s+bugfix\s+glibc-2.28-26.fc29.x86_64"
   Then stdout does not contain "FEDORA-2018-318f184001\s+enhancement\s+flac-1.3.3-8.fc29.x86_64"


Scenario: updateinfo list updates
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list updates"
   Then the exit code is 0
   Then stdout contains "FEDORA-2999:002-02\s+enhancement\s+flac-1.3.3-8.fc29.x86_64"
   Then stdout contains "FEDORA-2018-318f184112\s+enhancement\s+flac-1.4.0-1.fc29.x86_64"


Scenario: updateinfo list installed
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list installed"
   Then the exit code is 0
   Then stdout contains "FEDORA-2018-318f184000\sbugfix\sglibc-2.28-26.fc29.x86_64"


Scenario: updateinfo list available enhancement
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
  Given I use the repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list available enhancement"
   Then the exit code is 0
   Then stdout contains "FEDORA-2999:002-02\s+enhancement\s+flac-1.3.3-8.fc29.x86_64"
   Then stdout contains "FEDORA-2018-318f184112\s+enhancement\s+flac-1.4.0-1.fc29.x86_64"


Scenario: updateinfo list all bugfix
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo list all bugfix"
   Then the exit code is 0
   Then stdout contains "FEDORA-2018-318f184000\s+bugfix\s+glibc-2.28-26.fc29.x86_64"


Scenario Outline: updateinfo list updates plus <option>
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "<option> <value> updateinfo list updates"
   Then the exit code is 0
   Then stdout contains "FEDORA-2018-318f184000\s+bugfix\s+glibc-2.28-26.fc29.x86_64"

Examples:
        | option      | value                  |
        | --bz        | 222                    |
        | --cve       | 2999                   |
        | --advisory  | FEDORA-2018-318f184000 |


Scenario: updateinfo info <advisory>
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info FEDORA-2018-318f184000"
   Then stdout contains "Update\s+ID:\s+FEDORA-2018-318f184000"
   Then stdout contains "\s+glibc\s+bug\s+fix"
   Then stdout contains "Type:\s+bugfix"
   Then stdout does not contain "flac"
        

Scenario: updateinfo info <advisory-with-respin-suffix>
  Given I use the repository "dnf-ci-fedora"
   Then I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info FEDORA-2999:002-02"
   Then stdout contains "Update\s+ID:\s+FEDORA-2999:002-02"
   Then stdout contains "Type:\s+enhancement"
   Then stdout does not contain "glibc"
