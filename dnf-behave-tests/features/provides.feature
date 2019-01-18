Feature: Test for dnf provides


Background: use dnf-ci-fedora repository
  Given I use the repository "dnf-ci-fedora"


Scenario: dnf provides webclient - installed package wget provides webclient
   When I execute dnf with args "install wget glibc"
   Then the exit code is 0
  Given I disable the repository "dnf-ci-fedora"
   When I execute dnf with args "provides webclient"
   Then stdout contains "wget-1.19.5-5.fc29[^R]+Repo[ \t]+: @System"
    And stdout does not contain "(glibc)|(setup)"


Scenario: dnf provides webclient - installed and in repo package wget provides webclient
   When I execute dnf with args "install wget glibc"
   Then the exit code is 0
   When I execute dnf with args "provides webclient"
   Then stdout contains "wget-1.19.5-5.fc29[^R]+Repo[ \t]+: @System"
   Then stdout contains "wget-1.19.5-5.fc29[^R]+Repo[ \t]+: dnf-ci-fedora"
    And stdout does not contain "(glibc)|(setup)"


Scenario: dnf provides webclient - installed and in repos package wget provides webclient
   When I execute dnf with args "install wget glibc"
   Then the exit code is 0
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "provides webclient"
   Then stdout contains "wget-1.19.5-5.fc29[^R]+Repo[ \t]+: @System"
   Then stdout contains "wget-1.19.5-5.fc29[^R]+Repo[ \t]+: dnf-ci-fedora"
   Then stdout contains "wget-1.19.6-5.fc29[^R]+Repo[ \t]+: dnf-ci-fedora-updates"
    And stdout does not contain "(glibc)|(setup)"


Scenario: dnf provides nonexistentprovide
   When I execute dnf with args "provides nonexistentprovde"
   Then the exit code is 1
    And stderr contains "No Matches found"
