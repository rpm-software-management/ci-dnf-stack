Feature: Handling of --disablerepo and --enablerepo
  strict=false --disablerepo -> warning
  strict=false --enablerepo  -> warning
  strict=true  --disablerepo -> warning
  strict=true  --enablerepo  -> error

  Scenario: Handling of --disablerepo and --enablerepo with no repo
       When I run "dnf repolist --enablerepo=* --setopt=strict=true"
       Then the command should fail
        And the command stderr should contain exactly "Error: Unknown repo:"

       When I successfully run "dnf repolist --disablerepo=* --setopt=strict=true" with "success"
       Then the command stderr should contain exactly "No repository match:"

       When I successfully run "dnf repolist --enablerepo=* --setopt=strict=false" with "success"
       Then the command stderr should contain exactly "No repository match:"

       When I successfully run "dnf repolist --disablerepo=* --setopt=strict=false" with "success"
       Then the command stderr should contain exactly "No repository match:"
