Feature: Tests for user output suggestions related to filelists metadata


Scenario: Manual loading of filelists metadata is suggested when a file dependency cannot be resolved
  Given I use repository "filedeps"
   When I execute dnf with args "install filedep-package"
   Then the exit code is 1
    And stdout matches line by line
    """
    <REPOSYNC>
    (try to add '--skip-broken' to skip uninstallable packages or '--nobest' to use not only best candidate packages or '--setopt=optional_metadata_types=filelists' to load additional filelists metadata)
    """


Scenario: Manual loading of filelists metadata is not suggested when filelists are already loaded
  Given I use repository "filedeps"
   When I execute dnf with args "install filedep-nonexist --setopt=optional_metadata_types=filelists"
   Then the exit code is 1
    And stdout matches line by line
    """
    <REPOSYNC>
    (try to add '--skip-broken' to skip uninstallable packages or '--nobest' to use not only best candidate packages)
    """
