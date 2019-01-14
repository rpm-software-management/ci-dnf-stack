Feature: Test for repoquery dependencies functionality


Background:
  Given I use the repository "dnf-ci-fedora"
  When I execute dnf with args "makecache"
  Then the exit code is 0


Scenario: Repoquery with --requires option
  When I execute dnf with args "-q repoquery --requires filesystem"
  Then the exit code is 0
  Then stdout contains "setup"


Scenario: Repoquery with --provides option
  When I execute dnf with args "-q repoquery --provides setup"
  Then stdout contains "config\(setup\) = 2.12.1-1.fc29"
  Then stdout contains "setup = 2.12.1-1.fc29"


Scenario: Repoquery with --conflicts option
  When I execute dnf with args "-q repoquery --conflicts setup"
  Then the exit code is 0
  Then stdout contains "bash <= 2.0.4-21"
  Then stdout contains "filesystem < 3"
  Then stdout contains "initscripts < 4.26"


Scenario: Repoquery with --obsoletes option
  When I execute dnf with args "-q repoquery --obsoletes glibc"
  Then the exit code is 0
  Then stdout contains "glibc-profile < 2.4"


Scenario: Repoquery with --whatrequires option
  When I execute dnf with args "-q repoquery --whatrequires setup"
  Then stdout contains "basesystem-0:11-6.fc29.noarch"
  Then stdout contains "filesystem-0:3.9-2.fc29.x86_64"


Scenario: Repoquery with --whatprovides option
  When I execute dnf with args "-q repoquery --whatprovides setup"
  Then stdout contains "setup-0:2.12.1-1.fc29.noarch"


Scenario: Repoquery with --whatconflicts option
  When I execute dnf with args "-q repoquery --whatconflicts filesystem"
  Then stdout contains "setup-0:2.12.1-1.fc29.noarch"


Scenario: Repoquery with --whatobsoletes option
  When I execute dnf with args "-q repoquery --whatobsoletes glibc-profile"
  Then stdout contains "glibc-0:2.28-9.fc29.x86_64"
