Feature: Installing attemps fail

# @dnf5
# TODO(nsella) different stderr
@bz1568965
Scenario: Report all missing dependencies
  Given I use repository "dnf-ci-thirdparty"
    When I execute dnf with args "install SuperRipper anitras-dance"
    Then stderr contains "nothing provides abcde needed by SuperRipper-1.0-1.x86_64"
    Then stderr contains "nothing provides nodejs needed by anitras-dance-1.0-1.x86_64"

@bz1599774
Scenario: Report error when installing empty file
   Given I execute "touch empty.rpm" in "{context.dnf.installroot}/"
    When I execute dnf with args "install empty.rpm"
    Then the exit code is 1
     And stderr is
     """
     Can not load RPM file: empty.rpm.
     Could not open: empty.rpm
     """

@bz1616321
Scenario: Report error when installing text file
   Given I create file "invalid.rpm" with
         """
         this is not rpm
         """
    When I execute dnf with args "install invalid.rpm"
    Then the exit code is 1
     And stderr is
     """
     Can not load RPM file: invalid.rpm.
     Could not open: invalid.rpm
     """

# @dnf5
# TODO(nsella) different stdout
@bz1599774
Scenario: Report error when installing non-existing RPM file
    When I execute dnf with args "install no_such_file.rpm"
    Then the exit code is 1
     And stderr is
     """
     Can not load RPM file: no_such_file.rpm.
     Could not open: no_such_file.rpm
     """
