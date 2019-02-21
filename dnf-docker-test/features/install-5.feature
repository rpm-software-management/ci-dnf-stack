Feature: Report error when installing invalid RPM file

  @bz1599774
  Scenario: Report error when installing empty file
      Given I successfully run "touch empty.rpm"
       When I run "dnf -y install empty.rpm"
       Then the command exit code is 1
        And the command stderr should match line by line regexp
        """
        Can not load RPM file: empty.rpm
        Could not open: empty.rpm
        """

  @bz1616321
  Scenario: Report error when installing text file
      Given a file "./invalid.rpm" with
        """
        this is not RPM file
        """
       When I run "dnf -y install invalid.rpm"
       Then the command exit code is 1
        And the command stderr should match line by line regexp
        """
        Can not load RPM file: invalid.rpm.
        Could not open: invalid.rpm
        """

  @bz1599774
  Scenario: Report error when installing non-existing RPM file
       When I run "dnf -y install no_such_file.rpm"
       Then the command exit code is 1
        And the command stderr should match line by line regexp
        """
        Can not load RPM file: no_such_file.rpm.
        Could not open: no_such_file.rpm
        """
