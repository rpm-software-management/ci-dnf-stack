Feature: dnf-automatic configuration files testing

# https://issues.redhat.com/browse/RHEL-46030
Scenario: dnf-automatic fails if non-existing config file is specified
 When I execute dnf-automatic with args "NON_EXISTING_CONFIG_FILE_PATH"
 Then the exit code is 1
  And stderr is
  """
  Error: Configuration file "NON_EXISTING_CONFIG_FILE_PATH" not found.
  """

