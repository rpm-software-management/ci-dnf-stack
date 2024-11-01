@dnf5
Feature: makecache command 


@bz1745170
Scenario: disabled makecache --timer does not invalidate cached metadata
Given I use repository "dnf-ci-fedora" as http
  And I successfully execute dnf with args "makecache"
 When I execute dnf with args "makecache --timer --setopt=metadata_timer_sync=0"
  And I execute dnf with args "install setup"
 Then stderr does not contain "dnf-ci-fedora test repository"
