Feature: --setopt option


Background: Use repos setopt-1 and setopt-2
  Given I use the repository "setopt-1"
    And I use the repository "setopt-2"


# setopt-1 repo contains: wget
# setopt-2 repo contains: flac, wget


Scenario: Without --setopt option, packages wget and flac are available
   When I execute dnf with args "repoquery"
   Then the exit code is 0
    And stdout is
        """
        flac-0:1.0-1.fc29.src
        flac-0:1.0-1.fc29.x86_64
        flac-libs-0:1.0-1.fc29.x86_64
        wget-0:1.0-1.fc29.src
        wget-0:1.0-1.fc29.x86_64
        """

Scenario: --setopt option can be used to set config for specific repo
   When I execute dnf with args "repoquery --setopt=setopt-2.excludepkgs=*"
   Then the exit code is 0
    And stdout is
        """
        wget-0:1.0-1.fc29.src
        wget-0:1.0-1.fc29.x86_64
        """


Scenario: --setopt option can be used with globs to set config for multiple repos
   When I execute dnf with args "repoquery --setopt=setopt-*.excludepkgs=wget"
   Then the exit code is 0
    And stdout is
        """
        flac-0:1.0-1.fc29.src
        flac-0:1.0-1.fc29.x86_64
        flac-libs-0:1.0-1.fc29.x86_64
        """
