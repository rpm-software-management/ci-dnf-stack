Feature: Test dnf list --recent


Background: prepare repository with buildtimes set
  Given I copy repository "simple-base" for modification
    # rebuild all packages in simple-base repo with buildtime 10 days ago
    And I execute "SOURCE_DATE_EPOCH=$(date --date='-10 day' +%s) rpmbuild -rb --define "_rpmdir ." --define "use_source_date_epoch_as_buildtime 1" /{context.dnf.repos[simple-base].path}/src/*.src.rpm" in "{context.dnf.repos[simple-base].path}"
    # rebuild labirinto package with current buildtime
    And I execute "SOURCE_DATE_EPOCH=$(date +%s) rpmbuild -rb --define "_rpmdir ." --define "use_source_date_epoch_as_buildtime 1" /{context.dnf.repos[simple-base].path}/src/labirinto*.src.rpm" in "{context.dnf.repos[simple-base].path}"
    # remove source rpms not to interfere with list outputs
    And I execute "rm -rf src" in "{context.dnf.repos[simple-base].path}"
    # rebuild repodata
    And I execute "createrepo_c --simple-md-filenames --no-database /{context.dnf.repos[simple-base].path}"
    And I use repository "simple-base"


Scenario Outline: dnf list <option>
   When I execute dnf with args "list <option>"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    Recently Added Packages
    labirinto\.x86_64\s+1\.0-1\.fc29\s+simple-base
    """

Examples:
    | option    |
    | recent    |
    | --recent  |


Scenario: dnf list package that is not recently added
   # make sure that vagare package is present
   When I execute dnf with args "list vagare"
   Then the exit code is 0
   # but was not recently added
   When I execute dnf with args "list --recent vagare"
   Then the exit code is 1
    And stdout is
    """
    <REPOSYNC>
    """
    And stderr is
    """
    Error: No matching Packages to list
    """
