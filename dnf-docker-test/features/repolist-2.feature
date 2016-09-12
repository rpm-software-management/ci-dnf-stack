Feature: Handling of --disablerepo and --enablerepo
  strict=false --disablerepo -> warning
  strict=false --enablerepo  -> warning
  strict=true  --disablerepo -> warning
  strict=true  --enablerepo  -> error

  @setup
  Scenario: Feature Setup
      Given empty repository "test-1"

  Scenario: Handling of --disablerepo and --enablerepo with one repo
       When I run "dnf repolist --enablerepo=test* --setopt=strict=true" with "success"
       Then the command should fail
        And the command stderr should "not start" with "Error: Unknown repo:"

       When I successfully run "dnf repolist --disablerepo=test* --setopt=strict=true"
       Then the command stderr should "not start" with "No repository match:"

       When I successfully run "dnf repolist --enablerepo=test* --setopt=strict=false"
       Then the command stderr should "not start" with "No repository match:"

       When I successfully run "dnf repolist --disablerepo=test* --setopt=strict=false"
       Then the command stderr should "not start" with "No repository match:"
