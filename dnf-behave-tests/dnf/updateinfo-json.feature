@dnf5
Feature: dnf updateinfo command with --json


Background:
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install glibc flac"


Scenario: Listing available updates in json format
   When I use repository "dnf-ci-fedora-updates"
    And I execute dnf with args "updateinfo list --json"
   Then the exit code is 0
    And stdout json matches
    """
    [
      {
        "name":"FEDORA-2999:002-02",
        "type":"enhancement",
        "severity":"Moderate",
        "nevra":"flac-1.3.3-8.fc29.x86_64",
        "buildtime":"2019-01-17 00:00:00"
      },
      {
        "name":"FEDORA-2018-318f184000",
        "type":"bugfix",
        "severity":"none",
        "nevra":"glibc-2.28-26.fc29.x86_64",
        "buildtime":"2019-01-17 00:00:00"
      }
    ]
    """


Scenario: Listing available updates referencing bugizilla in json format
   When I use repository "dnf-ci-fedora-updates"
    And I execute dnf with args "updateinfo list --with-bz --json"
   Then the exit code is 0
    And stdout json matches
    """
    [
      {
        "advisory_name":"FEDORA-2018-318f184000",
        "advisory_type":"bugfix",
        "advisory_severity":"bugfix",
        "advisory_buildtime":"2019-01-17 00:00:00",
        "nevra":"glibc-2.28-26.fc29.x86_64",
        "references":[
          {
            "reference_id":"222",
            "reference_type":"bugzilla"
          }
        ]
      }
    ]
    """


Scenario: Listing updates in json format (when there's nothing to report)
   When I execute dnf with args "updateinfo list --json"
   Then the exit code is 0
    And stdout is
    """
    []
    """


Scenario: Listing updates in json format with custom type and severity
  Given I use repository "advisories-base"
    And I execute dnf with args "install labirinto"
    And I use repository "advisories-updates"
   When I execute dnf with args "updateinfo list --json"
   Then the exit code is 0
    And stdout json matches
    """
    [
      {
        "name":"FEDORA-2019-57b5902ed1",
        "type":"security",
        "severity":"Critical",
        "nevra":"labirinto-1.56.2-6.fc30.x86_64",
        "buildtime":"2019-09-15 01:34:29"
      },
      {
        "name":"FEDORA-2022-2222222222",
        "type":"custom_type",
        "severity":"custom_severity",
        "nevra":"labirinto-1.56.2-6.fc30.x86_64",
        "buildtime":"2019-09-15 01:34:29"
      },
      {
        "name":"FEDORA-2022-2222222223",
        "type":"security",
        "severity":"custom_severity",
        "nevra":"labirinto-1.56.2-6.fc30.x86_64",
        "buildtime":"2019-09-15 01:34:29"
      },
      {
        "name":"FEDORA-2022-2222222224",
        "type":"custom_type",
        "severity":"Critical",
        "nevra":"labirinto-1.56.2-6.fc30.x86_64",
        "buildtime":"2019-09-15 01:34:29"
      },
      {
        "name":"FEDORA-2019-f4eb34cf4c",
        "type":"security",
        "severity":"Moderate",
        "nevra":"labirinto-1.56.2-1.fc30.x86_64",
        "buildtime":"2019-05-12 01:21:43"
      }
    ]
    """
