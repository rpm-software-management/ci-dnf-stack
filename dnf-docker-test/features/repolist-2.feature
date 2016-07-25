Feature: Handling of --disablerepo and --enablerepo

Scenario: Handling of --disablerepo and --enablerepo with one repo
  Given I use the repository "test-1"
  When I execute "dnf" command "repolist --enablerepo=test* --setopt=strict=true" with "success"
  Then line from "stderr" should "not start" with "Error: Unknown repo:"
  When I execute "dnf" command "repolist --disablerepo=test* --setopt=strict=true" with "success"
  Then line from "stderr" should "not start" with "No repository match:"
  When I execute "dnf" command "repolist --enablerepo=test* --setopt=strict=false" with "success"
  Then line from "stderr" should "not start" with "No repository match:"
  When I execute "dnf" command "repolist --disablerepo=test* --setopt=strict=false" with "success"
  Then line from "stderr" should "not start" with "No repository match:"
