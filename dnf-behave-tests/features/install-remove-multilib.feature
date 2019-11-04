Feature: Installing and removing multilib packages


Background: Use "install-remove-multilib" repo
  Given I use repository "install-remove-multilib"


@xfail
Scenario: Installing inferior arch with dependencies
 When I execute dnf with args "install packageB.i686"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | packageB-0:1.0-1.i686        |
      | install       | library-0:1.0-1.i686         |


Scenario: Installing inferior arch with dependencies, in two steps
 When I execute dnf with args "install library.i686"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | library-0:1.0-1.i686         |
 When I execute dnf with args "install packageB.i686"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | packageB-0:1.0-1.i686        |


@xfail
@bz1745878
Scenario: Removing package of inferior arch also removes dependencies
 When I execute dnf with args "install packageA.x86_64"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | packageA-0:1.0-1.x86_64      |
      | install       | library-0:1.0-1.x86_64       |
 When I execute dnf with args "install packageB.i686"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | install       | packageB-0:1.0-1.i686        |
      | install       | library-0:1.0-1.i686         |
 When I execute dnf with args "remove packageB"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                      |
      | remove        | packageB-0:1.0-1.i686        |
      | remove        | library-0:1.0-1.i686         |

