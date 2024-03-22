Feature: Test encoding


@dnf5
Scenario: UTF-8 characters in .repo filename
  Given I configure dnf with
        | key      | value      |
        | reposdir | /testrepos |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/ř.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repo list"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo test repository"
    And stderr is empty


@dnf5
# dnf5 is OK with that in comparison with dnf4
@bz1803038
Scenario: non-UTF-8 characters in .repo filename
  Given I configure dnf with
        | key      | value      |
        | reposdir | /testrepos |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/{context.invalid_utf8_char}.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repo list"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo test repository"
    And stderr is empty


# @dnf5
# TODO(nsella) different stdout
Scenario: non-UTF-8 character in pkgspec
  Given I use repository "miscellaneous"
   When I execute dnf with args "install {context.invalid_utf8_char}ummy"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '\udcfdummy': 'utf-8' codec can't encode character '\udcfd' in position 0: surrogates not allowed
        """


# @dnf5
# TODO(nsella) Unknown argument "--repofrompath=testrepo," for command "install"
Scenario: non-UTF-8 character in baseurl
  Given I use repository "miscellaneous"
   When I execute dnf with args "install dummy --repofrompath=testrepo,{context.invalid_utf8_char}"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '--repofrompath=testrepo,\udcfd': 'utf-8' codec can't encode character '\udcfd' in position 24: surrogates not allowed
        """


# @dnf5
# TODO(nsella) different stdout
Scenario: non-UTF-8 character in an option
  Given I use repository "miscellaneous"
   When I execute dnf with args "install dummy --config={context.invalid_utf8_char}"
   Then the exit code is 1
    And stdout is empty
    And stderr is 
        """
        Error: Cannot encode argument '--config=\udcfd': 'utf-8' codec can't encode character '\udcfd' in position 9: surrogates not allowed
        """


@dnf5
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


@dnf5
@not.with_os=rhel__eq__9
@bz1893176
Scenario: non-UTF-8 character in filename in an installed package
  Given I use repository "miscellaneous"
    And I successfully execute dnf with args "install non_utf_filenames"
   When I execute dnf with args "repoquery --list --installed non_utf_filenames"
   Then the exit code is 0
   When I execute dnf with args "remove non_utf_filenames"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | non_utf_filenames-0:1.0-1.noarch  |
