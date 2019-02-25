Feature: Testing metadata 

@bz1644283
Scenario: update expired metadata on first dnf update
    Given repository "base" with packages
        | Package | Tag     | Value |
        | foo     | Version | 1     |
      And a repo file of repository "base" modified with
        | Key             | Value |
        | metadata_expire | 1s    |
     When I enable repository "base"
     Then I successfully run "dnf update"
      And I successfully run "dnf list all foo\*"
     Then the command stdout should match regexp "foo.noarch\s+1-1"
     When I update repository "base" with packages
        | Package | Tag     | Value |
        | foo     | Version | 2     |
     #Ensure metadata are expired
      And I successfully run "sleep 1s" 
      And I successfully run "dnf update"
      And I successfully run "dnf list all foo\*"
     Then the command stdout should match regexp "foo.noarch\s+2-1"
