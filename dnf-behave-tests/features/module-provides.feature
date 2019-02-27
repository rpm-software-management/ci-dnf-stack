Feature: Module provides command


Background:
Given I use the repository "dnf-ci-fedora-modular"
  And I use the repository "dnf-ci-fedora"
  And I execute dnf with args "makecache"


# bz1629667
@xfail @bz1629667
Scenario: I can get list of all modules providing specific package
 When I execute dnf with args "module provides nodejs-devel"
 Then the exit code is 0
 Then stdout matches line by line
   """
   ?Last metadata expiration check
   nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
   Module\s+:\s+nodejs:8
   Profiles\s+:\s+development
   Repo\s+:\s+dnf-ci-fedora-modular
   Summary\s+:\s+Javascript runtime

   nodejs-devel-1:10.11.0-1.module_2200\+adbac02b.x86_64
   Module\s+:\s+nodejs:10
   Profiles\s+:\s+development
   Repo\s+:\s+dnf-ci-fedora-modular
   Summary\s+:\s+Javascript runtime

   nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
   Module\s+:\s+nodejs:11
   Profiles\s+:\s+development
   Repo\s+:\s+dnf-ci-fedora-modular
   Summary\s+:\s+Javascript runtime

   """


# bz1623866
@bz1623866
Scenario: I can get list of enabled modules providing specific package
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
 When I execute dnf with args "module provides nodejs-devel"
 Then the exit code is 0
 Then stdout matches line by line
"""
?Last metadata expiration check
nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
Module\s+:\s+nodejs:8
Profiles\s+:\s+development
Repo\s+:\s+dnf-ci-fedora-modular
Summary\s+:\s+Javascript runtime
"""


Scenario: There is not output when no module provides the package
 When I execute dnf with args "module provides NoSuchPackage"
 Then the exit code is 0
 Then stdout matches line by line
 """
 ?Last metadata expiration check

 """


Scenario: An error is printed when no arguments are provided
 When I execute dnf with args "module provides"
 Then the exit code is 1
  And stderr is
 """
 Error: dnf module provides: too few arguments

 """
