@dnf5
@not.with_dnf=4
Feature: api: query packages


Scenario: Construct query and filter labirinto package
Given I use repository "simple-base"
 When I execute python libdnf5 api script with setup
      """
      query = libdnf5.rpm.PackageQuery(base)
      query.filter_name(["labirinto"])
      for pkg in query:
          print(pkg.get_nevra())
      """
 Then the exit code is 0
  And stdout is
      """
      labirinto-1.0-1.fc29.src
      labirinto-1.0-1.fc29.x86_64
      """


Scenario: Construct query and filter fails due to bad argument type
Given I use repository "simple-base"
 When I execute python libdnf5 api script with setup
      """
      query = libdnf5.rpm.PackageQuery(base)
      query.filter_name(99)
      for pkg in query:
          print(pkg.get_nevra())
      """
 Then the exit code is 1
  And stdout is empty
  And stderr contains "TypeError: Wrong number or type of arguments for overloaded function 'PackageQuery_filter_name'."
