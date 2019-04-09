Feature: Repoquery with cache


Background:
  Given I use the repository "dnf-ci-fedora"


Scenario: Cache only Repoquery without cache of available packages
  When I execute dnf with args "repoquery --available -C --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then the exit code is 1
  Then stdout is empty
  Then stderr contains "Cache-only enabled but no cache for"


Scenario: Quiet cache only Repoquery without cache of available packages
  When I execute dnf with args "repoquery --available -qC --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then the exit code is 1
  Then stdout is empty
  Then stderr contains "Cache-only enabled but no cache for"


Scenario: Quiet cache only Repoquery with cache of available packages
  When I execute dnf with args "makecache"
  Then the exit code is 0
  When I execute dnf with args "repoquery --available -Cq --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then the exit code is 0
  Then stdout contains "filesystem-3.9-2.fc29\n"
  Then stdout contains "setup-2.12.1-1.fc29\n"
  Then stdout contains "basesystem-11-6.fc29\n"
  Then stdout contains "wget-1.19.5-5.fc29\n"
  Then stderr is empty


Scenario: Quiet cache only Repoquery with cache of installed packages
  When I execute dnf with args "makecache"
  Then the exit code is 0
  When I execute dnf with args "repoquery --installed -Cq --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then the exit code is 0
  Then stdout is empty
  Then stderr is empty


Scenario: Cache only Repoquery with cache
  When I execute dnf with args "makecache"
  Then the exit code is 0
  When I execute dnf with args "repoquery -C --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then stdout contains "filesystem-3.9-2.fc29\n"
  Then stdout contains "setup-2.12.1-1.fc29\n"
  Then stdout contains "basesystem-11-6.fc29\n"
  Then stdout contains "wget-1.19.5-5.fc29\n"


Scenario: Cache only Repoquery with cache - installed package is still returned from available
  When I execute dnf with args "makecache"
  Then the exit code is 0
  When I execute dnf with args "install setup"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                                   |
       | install       | setup-0:2.12.1-1.fc29.noarch              |
  When I execute dnf with args "repoquery --available -Cq --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then stdout contains "setup-2.12.1-1.fc29\n"


Scenario: Cache only Repoquery with cache - installed package is returned from installed
  When I execute dnf with args "makecache"
  Then the exit code is 0
  When I execute dnf with args "install setup"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                                   |
       | install       | setup-0:2.12.1-1.fc29.noarch              |
  When I execute dnf with args "repoquery --installed -Cq --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then stdout contains "setup-2.12.1-1.fc29\n"


Scenario: Cache only Repoquery with cache without repository
  When I execute dnf with args "makecache"
  Then the exit code is 0
 Given I disable the repository "dnf-ci-fedora"
  When I execute dnf with args "repoquery --available -Cq --queryformat %{{name}}-%{{version}}-%{{release}}"
  Then stdout is empty

