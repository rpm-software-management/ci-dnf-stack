Feature: Test for successful and failing rpm scriptlets

  @setup
  Scenario: Setup phase: prepare packages
      Given repository "base" with packages
         | Package       | Tag       | Value            |
         | Test-pre-ok   | %pre      | echo stdout-pre  |
         | Test-pre-fail | %pre      | exit 1           |
         | Test-pretrans-ok   | %pretrans      | echo stdout-pretrans  |
         | Test-pretrans-fail | %pretrans      | exit 1                |
         | Test-post-ok   | %post      | echo stdout-post  |
         | Test-post-fail | %post      | exit 1            |
         | Test-posttrans-ok   | %posttrans      | echo stdout-posttrans  |
         | Test-posttrans-fail | %posttrans      | exit 1                 |
         | Test-preun-ok   | %preun      | echo stdout-preun  |
         | Test-preun-fail | %preun      | exit 1             |
         | Test-postun-ok   | %postun      | echo stdout-postun  |
         | Test-postun-fail | %postun      | exit 1              |
       When I enable repository "base"

  Scenario: Install a pkg with a successful %pre scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-pre-ok"
       Then rpmdb changes are
         | State     | Packages       |
         | installed | Test-pre-ok    |
        And the command stdout should match regexp "stdout-pre"

  Scenario: Install a pkg with a successful %pretrans scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-pretrans-ok"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | Test-pretrans-ok |
        And the command stdout should match regexp "stdout-pretrans"

  Scenario: Install a pkg with a successful %post scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-post-ok"
       Then rpmdb changes are
         | State     | Packages       |
         | installed | Test-post-ok   |
        And the command stdout should match regexp "stdout-post"

  Scenario: Install a pkg with a successful %posttrans scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-posttrans-ok"
       Then rpmdb changes are
         | State     | Packages          |
         | installed | Test-posttrans-ok |
        And the command stdout should match regexp "stdout-posttrans"

  Scenario: Install a pkg with a failing %pre scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-pre-fail"
       Then rpmdb does not change
        And the command stderr should match regexp "Error in PREIN scriptlet in rpm package Test-pre-fail"
        And the command stderr should match regexp "Error: Transaction failed"

  Scenario: Install a pkg with a failing %pretrans scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-pretrans-fail"
       Then rpmdb does not change
        And the command stderr should match regexp "Error in PRETRANS scriptlet in rpm package Test-pretrans-fail"
        And the command stderr should match regexp "Error: Transaction failed"

  Scenario: Install a pkg with a failing %post scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-post-fail"
       Then rpmdb changes are
         | State     | Packages       |
         | installed | Test-post-fail |
        And the command stderr should match regexp "Non-fatal POSTIN scriptlet failure in rpm package Test-post-fail"

  Scenario: Install a pkg with a failing %posttrans scriptlet
       When I save rpmdb
        And I run "dnf -y install Test-posttrans-fail"
       Then rpmdb changes are
         | State     | Packages            |
         | installed | Test-posttrans-fail |
        And the command stderr should match regexp "Non-fatal POSTTRANS scriptlet failure in rpm package Test-posttrans-fail"

  Scenario: Remove a pkg with a successful %preun scriptlet
       When I run "dnf -y install Test-preun-ok"
        And I save rpmdb
        And I run "dnf -y remove Test-preun-ok"
       Then rpmdb changes are
         | State     | Packages         |
         | removed   | Test-preun-ok    |
        And the command stdout should match regexp "stdout-preun"

  Scenario: Remove a pkg with a successful %postun scriptlet
       When I run "dnf -y install Test-postun-ok"
        And I save rpmdb
        And I run "dnf -y remove Test-postun-ok"
       Then rpmdb changes are
         | State     | Packages          |
         | removed   | Test-postun-ok    |
        And the command stdout should match regexp "stdout-postun"

  Scenario: Remove a pkg with a failing %preun scriptlet
       When I run "dnf -y install Test-preun-fail"
       When I save rpmdb
        And I run "dnf -y remove Test-preun-fail"
       Then rpmdb does not change
        And the command stderr should match regexp "Error in PREUN scriptlet in rpm package Test-preun-fail"
        And the command stderr should match regexp "Error: Transaction failed"
       When I save rpmdb
        And I run "dnf -y --setopt=tsflags=noscripts remove Test-preun-fail"
       Then rpmdb changes are
         | State     | Packages        |
         | removed   | Test-preun-fail |

  Scenario: Remove a pkg with a failing %postun scriptlet
       When I run "dnf -y install Test-postun-fail"
       When I save rpmdb
        And I run "dnf -y remove Test-postun-fail"
       Then rpmdb changes are
         | State     | Packages       |
         | removed   | Test-postun-fail |
        And the command stderr should match regexp "Non-fatal POSTUN scriptlet failure in rpm package Test-postun-fail"
