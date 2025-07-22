@jiraRHELPLAN-6083
Feature: platform pseudo-module based on /etc/os-release


Background: allow repo
Given I use repository "dnf-ci-pseudo-platform-modular"
Given I create file "/etc/os-release" with
    """
    NAME=PsedoDistro
    VERSION="6 (dwm-team)"
    ID=pseudo
    VERSION_ID=6
    PLATFORM_ID="pseudoplatform:6.0"
    PRETTY_NAME="PseudoDistro 6 (dwm-team)"
    """
 And I do not set default module platformid


@not.with_os=rhel__eq__8
Scenario: I can't enable module requiring different platform pseudo module
Given I delete file "/etc/os-release"
 When I execute dnf with args "module enable dwm:6.0"
 Then the exit code is 1
  And stderr contains "nothing provides module\(pseudoplatform:6.0\) needed by module dwm:6.0:20180813144159:.x86_64"


Scenario: I can't see pseudo-module in module listing
 When I execute dnf with args "module enable dwm:6.0"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | dwm       | enabled   | 6.0       |           |
 When I execute dnf with args "module list --enabled"
 Then stdout does not contain "pseudoplatform"
 When I execute dnf with args "module list --installed"
 Then stdout does not contain "pseudoplatform"


Scenario: I can't list info for the pseudo-module
 When I execute dnf with args "module info pseudoplatform"
 Then the exit code is 1
  And stdout is
   """
   <REPOSYNC>
   Unable to resolve argument pseudoplatform
   """
  And stderr is
   """
   WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
   Error: No matching Modules to list
   """


Scenario: I can't enable pseudo-module
 When I execute dnf with args "module enable pseudoplatform:6.0"
 Then the exit code is 1
  And stderr contains lines
  """
   Error: Problems in request:
   missing groups or modules: pseudoplatform:6.0
  """


  Scenario: I can't install pseudo-module
 When I execute dnf with args "module install pseudoplatform:6.0"
 Then the exit code is 1
  And stderr contains lines
  """
   Error: Problems in request:
   missing groups or modules: pseudoplatform:6.0
  """


Scenario: I can't disable pseudo-module
 When I execute dnf with args "module  disable pseudoplatform:6.0"
 Then the exit code is 1
  And stderr contains lines
  """
   Unable to resolve argument pseudoplatform:6.0
   Error: Problems in request:
   missing groups or modules: pseudoplatform:6.0
  """


Scenario: I can't update pseudo-module
 When I execute dnf with args "module update pseudoplatform:6.0"
 Then the exit code is 1
  And stderr is
  """
  WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
  Error: No such module: pseudoplatform:6.0
  """


Scenario: I can't remove pseudo-module
 When I execute dnf with args "module remove pseudoplatform:6.0"
 Then the exit code is 0
  And stdout matches line by line
  """
  <REPOSYNC>
  ^Dependencies resolved.
  ^Nothing to do.
  ^Complete!
  """
  And stderr contains lines
  """
  Problems in request:
  missing groups or modules: pseudoplatform:6.0
  """
