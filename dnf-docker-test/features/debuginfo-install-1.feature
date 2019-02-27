Feature: debuginfo-install reports an error when debuginfo is not found

  @bz1585137
  Scenario:
       When I run "dnf debuginfo-install -y non-existent-package"
       Then the command exit code is 1
        And the command stdout should match regexp "No match for argument: non-existent-package"
        And the command stdout should match regexp "No debuginfo packages available to install"
        And the command stderr should match regexp "Error: Unable to find a match"
