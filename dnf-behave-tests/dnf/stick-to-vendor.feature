Feature: DNF allow_vendor_change option in dnf.conf
Background:
  Given I use repository "dnf-ci-vendor-1"
   And I create and substitute file "/etc/dnf/dnf.conf" with
   """
   [main]
   allow_vendor_change=False
   """
   And I successfully execute dnf with args "install vendor"
   Then the exit code is 0
   And transaction is following
       | Action  | Package             |
       | install | vendor-1.0-1.x86_64 |

  Given I successfully execute rpm with args "-qi vendor"
   Then the exit code is 0
   And stdout contains "Vendor      : First Vendor"

@dnf5
@bz1788371
Scenario: Upgrade sticks to vendor
  Given I use repository "dnf-ci-vendor-1-updates"
  Given I use repository "dnf-ci-vendor-2-updates"
   When I execute dnf with args "upgrade vendor"
   Then the exit code is 0
   And transaction is following
       | Action  | Package             |
       | upgrade | vendor-1.1-1.x86_64 |
  Given I successfully execute rpm with args "-qi vendor"
   Then the exit code is 0
   And stdout contains "Vendor      : First Vendor"

@dnf5
@bz1788371
Scenario: No upgrade if same vendor not found
  Given I use repository "dnf-ci-vendor-2-updates"
   When I execute dnf with args "upgrade vendor"
   Then the exit code is 0
   And transaction is empty
  Given I successfully execute rpm with args "-qi vendor"
   Then the exit code is 0
   And stdout contains "Vendor      : First Vendor"

# @dnf5
# TODO(nsella) different exit code
@bz1788371
Scenario: Downgrade is unable to resolve transaction
  Given I use repository "dnf-ci-vendor-1-updates"
   When I execute dnf with args "upgrade vendor"
  Given I drop repository "dnf-ci-vendor-1"
  Given I use repository "dnf-ci-vendor-2"
   When I execute dnf with args "downgrade vendor"
   Then the exit code is 1
   And transaction is empty
   And stdout is
       """
       (try to add '--allowerasing' to command line to replace conflicting packages or '--skip-broken' to skip uninstallable packages)
       """
   And stderr is
       """
       <REPOSYNC>
       allow_vendor_change is disabled. This option is currently not supported for downgrade and distro-sync commands
       Error: 
        Problem: problem with installed package vendor-1.1-1.x86_64
         - cannot install both vendor-1.0-1.x86_64 and vendor-1.1-1.x86_64
         - conflicting requests
       """
