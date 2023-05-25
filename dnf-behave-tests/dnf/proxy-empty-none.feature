Feature: Tests "proxy=" and "proxy=_none_"
         # "proxy=_none_" has the same meaning as "proxy=". Introduced for compatibility with yum.


Scenario: I can use "proxy=" in main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure dnf with
        | key        | value    |
        | proxy      | ""       |
    And I execute dnf with args "repoquery abcde"
   Then the exit code is 0
    And stdout contains "abcde"


@bz2155713
Scenario: I can use "proxy=_none_" in main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure dnf with
        | key        | value    |
        | proxy      | "_none_" |
    And I execute dnf with args "repoquery abcde"
   Then the exit code is 0
    And stdout contains "abcde"


Scenario: I can use "--setopt=proxy=" and it overrides the proxy setting from the main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure dnf with
        | key        | value               |
        | proxy      | "http://nosuchhost" |
    And I execute dnf with args "repoquery --setopt=proxy= abcde"
   Then the exit code is 0
    And stdout contains "abcde"


Scenario: I can use "--setopt=proxy=_none_" and it overrides the proxy setting from the main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure dnf with
        | key        | value               |
        | proxy      | "http://nosuchhost" |
    And I execute dnf with args "repoquery --setopt=proxy=_none_ abcde"
   Then the exit code is 0
    And stdout contains "abcde"


Scenario: I can use "proxy=" in the repository config and it disables the proxy setting inherited from the main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure repository "dnf-ci-fedora" with
        | key        | value   |
        | proxy      | ""      |
    And I configure dnf with
        | key        | value               |
        | proxy      | "http://nosuchhost" |
    And I execute dnf with args "repoquery abcde"
   Then the exit code is 0
    And stdout contains "abcde"


@bz1680272
Scenario: I can use "proxy=_none_" in the repository config and it disables the proxy setting inherited from the main section
  Given I use repository "dnf-ci-fedora" as http
    And I configure repository "dnf-ci-fedora" with
        | key        | value    |
        | proxy      | "_none_" |
    And I configure dnf with
        | key        | value               |
        | proxy      | "http://nosuchhost" |
    And I execute dnf with args "repoquery abcde"
   Then the exit code is 0
    And stdout contains "abcde"
