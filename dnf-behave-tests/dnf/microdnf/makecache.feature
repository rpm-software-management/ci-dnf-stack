Feature: makecache command


Scenario: Create a metadata cache using "makecache" and then test that "repoquery" does not download metadata
  Given I use repository "dnf-ci-fedora" as http
  When I execute microdnf with args "makecache"
  Then the exit code is 0
    # Message "Downloading metadata..." may be repeated
    And stdout contains "Downloading metadata..."
    And stdout contains "Metadata cache created."
  When I execute microdnf with args "repoquery nodejs"
  Then the exit code is 0
   And stdout is
      """
      nodejs-1:5.12.1-1.fc29.src
      nodejs-1:5.12.1-1.fc29.x86_64
      """


Scenario: Tests that "repoquery" downloads metadata (creates a cache) and then "makecache" does not download metadada
  Given I use repository "dnf-ci-fedora" as http
  When I execute microdnf with args "repoquery nodejs"
  Then the exit code is 0
    # Message "Downloading metadata..." may be repeated
    And stdout contains "Downloading metadata..."
    And stdout contains "nodejs-1:5.12.1-1.fc29.src"
    And stdout contains "nodejs-1:5.12.1-1.fc29.x86_64"
  When I execute microdnf with args "makecache"
  Then the exit code is 0
   And stdout is
      """
      Metadata cache created.
      """
