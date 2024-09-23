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


Scenario: makecache with skip_if_unavailable=0 repo doesn't succeed
Given I configure a new repository "non-existent" with
      | key                 | value                               |
      | baseurl             | https://www.not-available-repo.com/ |
      | enabled             | 1                                   |
      | skip_if_unavailable | 0                                   |
 When I execute microdnf with args "makecache"
 Then the exit code is 1
  # stdout doesn't contain "Metadata cache created."
  And stdout is
      """
      Downloading metadata...
      """
  And stderr is
      """
      error: cannot update repo 'non-existent': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried; Last error: Curl error (6): Could not resolve hostname for https://www.not-available-repo.com/repodata/repomd.xml [Could not resolve host: www.not-available-repo.com]
      """
