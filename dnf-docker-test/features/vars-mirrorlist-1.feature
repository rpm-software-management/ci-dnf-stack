Feature: Substitute variables in mirrorlist

  @setup
  Scenario: base repository setup
     Given repository "base" with packages
          | Package  | Tag      | Value  |
          | TestA    | Version  | 1      |
       And I successfully run "sh -c 'mv $PWD /tmp/base-noarch/'" in repository "base"
       And a file "/etc/yum.repos.d/base.repo" with
       """
       [base]
       name=base
       mirrorlist=file:///tmp/mirrorlist.txt
       gpgcheck=0
       enabled=1
       """
       And a file "/tmp/mirrorlist.txt" with
       """
       file:///tmp/base-$basearch/
       """

  @bz1651092
  Scenario: Variables are substituted in mirrorlist URLs
      When I successfully run "dnf --setopt 'basearch=noarch' search TestA"
      Then the command stdout should match regexp "TestA.noarch"
