Feature: Glob tests for expanding all the various glob patterns.

Background:
 Given I use repository "repoquery-globs"


# <name> globs
Scenario: repoquery '*' (lists all available packages)
 When I execute microdnf with args "repoquery '*'"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.0-1.src
      desktop-utils-1:1.0-1.x86_64
      desktop-utils-1:1.23.9-1.src
      desktop-utils-1:1.23.9-1.x86_64
      htop-1:1.0-1.src
      htop-1:1.0-1.x86_64
      top-1:1.0-1.src
      top-1:1.0-1.x86_64
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      topgit-1:1.0-1.src
      topgit-1:1.0-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      toppler-1:1.0-1.src
      toppler-1:1.0-1.x86_64
      """

Scenario: repoquery top*
 When I execute microdnf with args "repoquery top*"
 Then the exit code is 0
  And stdout is
      """
      top-1:1.0-1.src
      top-1:1.0-1.x86_64
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      topgit-1:1.0-1.src
      topgit-1:1.0-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      toppler-1:1.0-1.src
      toppler-1:1.0-1.x86_64
      """

Scenario: repoquery top?d
 When I execute microdnf with args "repoquery top?d"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      """

Scenario: repoquery top?{d,it}
 When I execute microdnf with args "repoquery top?{{d,it}}"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      topgit-1:1.0-1.src
      topgit-1:1.0-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      """

Scenario: repoquery top[a-f]d
 When I execute microdnf with args "repoquery top[a-f]d"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      """

Scenario: repoquery top[a-fg]*
 When I execute microdnf with args "repoquery top[a-fg]*"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      topgit-1:1.0-1.src
      topgit-1:1.0-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      """

Scenario: repoquery top[^a-g]*
 When I execute microdnf with args "repoquery top[^a-g]*"
 Then the exit code is 0
  And stdout is
      """
      toppler-1:1.0-1.src
      toppler-1:1.0-1.x86_64
      """

Scenario: repoquery top{ed,pler}
 When I execute microdnf with args "repoquery top{{ed,pler}}"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      toppler-1:1.0-1.src
      toppler-1:1.0-1.x86_64
      """

Scenario: repoquery top[!n-z]{d,aaa,it}
 When I execute microdnf with args "repoquery top[!n-z]{{d,aaa,it}}"
 Then the exit code is 0
  And stdout is
      """
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      topgit-1:1.0-1.src
      topgit-1:1.0-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      """

Scenario: repoquery *top[-a-f]*
 When I execute microdnf with args "repoquery *top[-a-f]*"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.0-1.src
      desktop-utils-1:1.0-1.x86_64
      desktop-utils-1:1.23.9-1.src
      desktop-utils-1:1.23.9-1.x86_64
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      """


# <name-version> globs
Scenario: repoquery *top[-a-f]*-1.0
 When I execute microdnf with args "repoquery *top[-a-f]*-1.0"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.0-1.src
      desktop-utils-1:1.0-1.x86_64
      toped-1:1.0-1.src
      toped-1:1.0-1.x86_64
      """

Scenario: repoquery *top[-a-f]*-1.[1-4]*
 When I execute microdnf with args "repoquery *top[-a-f]*-1.[1-4]*"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.23.9-1.src
      desktop-utils-1:1.23.9-1.x86_64
      """

Scenario: repoquery *top[-a-f]*-1.[!1-4]*.x86_64
 When I execute microdnf with args "repoquery *top[-a-f]*-1.[!1-4]*.x86_64"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.0-1.x86_64
      toped-1:1.0-1.x86_64
      """

Scenario: repoquery *top*-1.{17,23,99}*
 When I execute microdnf with args "repoquery *top*-1.{{17,23,99}}*"
 Then the exit code is 0
  And stdout is
      """
      desktop-utils-1:1.23.9-1.src
      desktop-utils-1:1.23.9-1.x86_64
      topgit-1:1.17.6-1.src
      topgit-1:1.17.6-1.x86_64
      """
