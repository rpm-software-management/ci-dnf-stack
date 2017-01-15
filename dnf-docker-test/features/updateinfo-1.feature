Feature: Listing available updates using the dnf updateinfo command

  @setup
  Scenario: setup
    Given repository "base" with packages
         | Package | Tag     | Value |
         | TestA   |         |       |
         | TestB   |         |       |
         | TestC   |         |       |
      And repository "updates" with packages
         | Package | Tag     | Value |
         | TestA   | Version | 2     |
         | TestB   | Version | 2     |
         | TestC   | Version | 2     |
      And updateinfo defined in repository "updates"
         | Id             | Tag          | Value                                   |
         | RHSA-2016:007  | Title        | TestA and TestB security update         |
         |                | Type         | security                                |
         |                | Description  | James Bond rocks                        |
         |                | Solution     | Live and let die                        |
         |                | Summary      | SPECTRE infiltrated the organization    |
         |                | Severity     | Important                               |
         |                | Rights       | License to kill                         |
         |                | Issued       | 2016-09-07 00:00:00                     |
         |                | Updated      | 2016-12-20 22:26:32                     |
         |                | Reference    | CVE-2016-0001                           |
         |                | Reference    | CVE-2016-0002                           |
         |                | Package      | TestA-2                                 |
         |                | Package      | TestB-2                                 |
         | RHBA-2016:101  | Title        | TestC bugfix update                     |
         |                | Type         | bugfix                                  |
         |                | Description  | Miss Moneypenny's nails needs polishing |
         |                | Solution     | Apply the red fingernail polish         |
         |                | Summary      | Miss Moneypenny's nails should be red   |
         |                | Severity     | Low                                     |
         |                | Rights       | Beauty salon license                    |
         |                | Issued       | 2016-10-07 00:00:00                     |
         |                | Updated      | 2016-11-20 22:26:32                     |
         |                | Reference    | BZ12345                                 |
         |                | Package      | TestC-2                                 |
     When I enable repository "base"
      And I successfully run "dnf -y install TestA TestB TestC"

  Scenario: Listing available updates
     When I enable repository "updates"
      And I run "dnf updateinfo list"
     Then the command stdout should match regexp "RHSA-2016:007 security TestA-2"
      And the command stdout should match regexp "RHSA-2016:007 security TestB-2"
      And the command stdout should match regexp "RHBA-2016:101 bugfix   TestC-2"
