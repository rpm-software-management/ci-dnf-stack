Feature: Show packages not needed by any package


Scenario: Use dnf leaves command and show-leaves plugin to list packages not needed by any package
  Given I use repository "dnf-ci-fedora"
    And I enable plugin "leaves"
    And I enable plugin "show-leaves"
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | abcde-0:2.9.2-1.fc29.noarch       |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64       |
        | install-weak  | flac-1.3.2-8.fc29.x86_64          |
   Then stdout section "New leaves:" contains "abcde.noarch"
   Then stdout section "New leaves:" contains "flac.x86_64"
   When I execute dnf with args "leaves"
   Then the exit code is 0
   Then stdout is
    """
    - abcde-2.9.2-1.fc29.noarch
    - flac-1.3.2-8.fc29.x86_64
    """
   When I execute dnf with args "remove flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | flac-1.3.2-8.fc29.x86_64          |
   When I execute dnf with args "leaves"
   Then the exit code is 0
   Then stdout is
    """
    - abcde-2.9.2-1.fc29.noarch
    """
   When I execute dnf with args "remove abcde --noautoremove"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | abcde-0:2.9.2-1.fc29.noarch       |
   When I execute dnf with args "leaves"
   Then the exit code is 0
   Then stdout is
    """
    - wget-1.19.5-5.fc29.x86_64
    """

