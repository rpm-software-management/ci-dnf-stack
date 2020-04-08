Feature: Test encoding


Scenario: UTF-8 characters in .repo filename
  Given I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
        """
        [main]
        reposdir=/testrepos
        """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/ř.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo test repository"
    And stderr is empty


@not.with_os=rhel__eq__8
@bz1803038
Scenario: non-UTF-8 characters in .repo filename
  Given I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
        """
        [main]
        reposdir=/testrepos
        """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/{context.invalid_utf8_char}.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty
    And stderr is
        """
        Warning: failed loading '{context.dnf.installroot}/testrepos/\udcfd.repo', skipping.
        No repositories available
        """


@not.with_os=rhel__eq__8
Scenario: non-UTF-8 character in pkgspec
  Given I use repository "miscellaneous"
   When I execute dnf with args "install {context.invalid_utf8_char}ummy"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '\udcfdummy': 'utf-8' codec can't encode character '\udcfd' in position 0: surrogates not allowed
        """


@not.with_os=rhel__eq__8
Scenario: non-UTF-8 character in baseurl
  Given I use repository "miscellaneous"
   When I execute dnf with args "install dummy --repofrompath=testrepo,{context.invalid_utf8_char}"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '--repofrompath=testrepo,\udcfd': 'utf-8' codec can't encode character '\udcfd' in position 24: surrogates not allowed
        """


@not.with_os=rhel__eq__8
Scenario: non-UTF-8 character in an option
  Given I use repository "miscellaneous"
   When I execute dnf with args "install dummy --config={context.invalid_utf8_char}"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '--config=\udcfd': 'utf-8' codec can't encode character '\udcfd' in position 9: surrogates not allowed
        """


@not.with_os=rhel__eq__8
Scenario: non-UTF-8 character in an option when using corresponding locale
  Given I use repository "miscellaneous"
    And I create file "/{context.invalid_utf8_char}" with
        """
        """
    And I set LC_ALL to "en_US.ISO-8859-1"
   When I execute dnf with args "install dummy --config={context.dnf.installroot}/{context.invalid_utf8_char}"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                    |
        | install       | dummy-1:1.0-1.x86_64       |
