Feature: Tests for --showduplicates cmdline option 

  @setup
  Scenario: Feature Setup
      Given local repository "base" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 1                 |
          |             | Release   | 1                 |
       And local repository "ext" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 2                 |
          |             | Release   | 1                 |
       And local repository "ext2" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 3                 |
          |             | Release   | 1                 |
      When I enable repository "base"
       And I successfully run "dnf -y install TestA"
       And I enable repository "ext"
       And I enable repository "ext2"
       And I successfully run "dnf makecache"

  @xfail @bz1671731
  Scenario: Test for list with --showduplicates when the package is installed
       When I run "dnf list --showduplicates TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          Installed Packages
          TestA.noarch +1-1 +@base
          Available Packages
          TestA\.noarch +1-1 +base
          TestA\.noarch +2-1 +ext
          TestA\.noarch +3-1 +ext2
          """

  Scenario: Test for list without --showduplicates when the package is installed
       When I run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          Installed Packages
          TestA.noarch +1-1 +@base
          Available Packages
          TestA\.noarch +3-1 +ext2
          """

  Scenario: Test for list with --showduplicates when the package is not installed
       When I successfully run "dnf -y remove TestA"
        And I run "dnf list --showduplicates TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          Available Packages
          TestA\.noarch +1-1 +base
          TestA\.noarch +2-1 +ext
          TestA\.noarch +3-1 +ext2
          """

  Scenario: Test for list without --showduplicates when the package is not installed
       When I run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          Available Packages
          TestA\.noarch +3-1 +ext2
          """
