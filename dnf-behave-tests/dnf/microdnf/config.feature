Feature: Respect main config options


@not.with_os=rhel__ge__8
Scenario: microdnf downloads zchunk metadata, enabled by default
Given I copy repository "simple-base" for modification
  And I generate repodata for repository "simple-base" with extra arguments "--zck"
  And I use repository "simple-base" as http
  And I start capturing outbound HTTP requests
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And HTTP log contains
      """
      GET /repodata/primary.xml.zck
      """


@bz1851841
@bz1779104
@not.with_os=rhel__ge__8
Scenario: microdnf ignores zchunk metadata if disabled
Given I copy repository "simple-base" for modification
  And I generate repodata for repository "simple-base" with extra arguments "--zck"
  And I use repository "simple-base" as http
  And I start capturing outbound HTTP requests
  And I configure dnf with
      | key    | value |
      | zchunk | False |
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And HTTP log contains
      """
      GET /repodata/primary.xml.zst
      """


@bz1866253
Scenario: microdnf respects --config option
Given I use repository "simple-base"
  And I create file "/test/microdnf.conf" with
      """
      [main]
      exclude=labirinto
      """
 When I execute microdnf with args "--config {context.dnf.installroot}/test/microdnf.conf install labirinto"
 Then the exit code is 1
  And stderr contains "error: No package matches 'labirinto'"
  And stdout is empty
