Feature: The common repoquery tests, core functionality, odds and ends.

Background:
 Given I use repository "repoquery-main"


# simple nevra matching tests
Scenario: repoquery (no arguments, i.e. list all packages)
 When I execute microdnf with args "repoquery"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      bottom-a2-1:1.0-1.src
      bottom-a2-1:1.0-1.x86_64
      bottom-a3-1:1.0-1.src
      bottom-a3-1:1.0-1.x86_64
      bottom-a3-1:2.0-1.src
      bottom-a3-1:2.0-1.x86_64
      broken-deps-1:1.0-1.src
      broken-deps-1:1.0-1.x86_64
      mid-a1-1:1.0-1.src
      mid-a1-1:1.0-1.x86_64
      mid-a2-1:1.0-1.src
      mid-a2-1:1.0-1.x86_64
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME (nonexisting package)
 When I execute microdnf with args "repoquery dummy"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery NAME
 When I execute microdnf with args "repoquery top-a"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION
 When I execute microdnf with args "repoquery top-a-2.0"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION-RELEASE
 When I execute microdnf with args "repoquery top-a-2.0-2"
 Then the exit code is 0
  And stdout is
      """
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-EPOCH:VERSION-RELEASE
 When I execute microdnf with args "repoquery top-a-2:2.0-2"
 Then the exit code is 0
  And stdout is
      """
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-EPOCH:VERSION-RELEASE old epoch
 When I execute microdnf with args "repoquery top-a-1:2.0-2"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery NAME NAME-EPOCH:VERSION-RELEASE
 When I execute microdnf with args "repoquery bottom-a1 top-a-2:2.0-2"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION NAME-EPOCH:VERSION_GLOB-RELEASE
 When I execute microdnf with args "repoquery bottom-a1-1.0 top-a-1:[12].0-1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      """

@xfail
@bz1735687
Scenario: repoquery NAME-VERSION NAME-EPOCH:VERSION_GLOB2-RELEASE
 When I execute microdnf with args "repoquery bottom-a1-1.0 top-a-1:[1-2].0-1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      """


# --available is the default, scenarios above should cover it
Scenario: dnf repoquery --available NAME
 When I execute microdnf with args "repoquery --available top-a-2.0"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """


Scenario: repoquery --installed NAME (no such packages)
 When I execute microdnf with args "repoquery --installed bottom-a1"
 Then the exit code is 0
  And stdout is empty


Scenario: repoquery --installed NAME
Given I successfully execute microdnf with args "install bottom-a1 bottom-a2"
 When I execute microdnf with args "repoquery --installed bottom-a1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:2.0-1.noarch
      """
