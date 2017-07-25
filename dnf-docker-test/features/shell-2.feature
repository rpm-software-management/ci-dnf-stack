Feature: Running dnf shell commands in a batch

  @setup
  Scenario: Preparing the test repository
    Given repository "TestRepoA" with packages
         | Package | Tag       | Value |
         | TestA   |           |       |

  Scenario: Passing shell commands stored in a file
    Given a file "/tmp/dnf_shell_transaction" with
          """
          config assumeyes 1
          repo enable TestRepoA
          install TestA
          run
          """
     When I save rpmdb
      And _deprecated I execute "dnf" command "shell /tmp/dnf_shell_transaction" with "success"
     Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |

  Scenario: Passing shell commands through stdin redirection
    Given a file "/tmp/dnf_shell_transaction" with
          """
          config assumeyes 1
          remove TestA
          run
          """
     When I save rpmdb
      And _deprecated I execute "dnf" command "shell < /tmp/dnf_shell_transaction" with "success"
     Then rpmdb changes are
         | State   | Packages |
         | removed | TestA    |

