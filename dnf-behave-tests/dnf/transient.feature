Feature: Persistence option and --transient


Scenario: Try installing a package using --transient on a non-bootc system
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --transient"
   Then the exit code is 1
    And stderr is
    """
    Transient transactions are only supported on bootc systems.
    """

Scenario: Try installing a package with persistence=transient on a non-bootc system
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=persistence=transient"
   Then the exit code is 1
    And stderr is
    """
    Transient transactions are only supported on bootc systems.
    """

Scenario: Install a package with persistence=auto on a non-bootc system
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=persistence=auto"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |

Scenario: Install a package with persistence=persist on a non-bootc system
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=persistence=persist"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
