Feature: Logs


@bz1739457
Scenario: dnf.rpm.log doesn't contain duplicate entries ()
  Given I use repository "dnf-ci-fedora-updates"
    And I execute dnf with args "install flac"
    And I execute dnf with args "reinstall flac"
    And I execute dnf with args "downgrade flac"
    And I execute dnf with args "upgrade flac"
    And I execute dnf with args "remove flac"
   When I execute "cat {context.dnf.installroot}/var/log/dnf.rpm.log"
   Then stdout matches line by line
        """
        .* INFO --- logging initialized ---
        .* SUBDEBUG Installed: flac-1.3.3-3.fc29.x86_64
        .* INFO --- logging initialized ---
        .* SUBDEBUG Reinstall: flac-1.3.3-3.fc29.x86_64
        .* SUBDEBUG Reinstalled: flac-1.3.3-3.fc29.x86_64
        .* INFO --- logging initialized ---
        .* SUBDEBUG Downgrade: flac-1.3.3-2.fc29.x86_64
        .* SUBDEBUG Downgraded: flac-1.3.3-3.fc29.x86_64
        .* INFO --- logging initialized ---
        .* SUBDEBUG Upgrade: flac-1.3.3-3.fc29.x86_64
        .* SUBDEBUG Upgraded: flac-1.3.3-2.fc29.x86_64
        .* INFO --- logging initialized ---
        .* SUBDEBUG Erase: flac-1.3.3-3.fc29.x86_64
        """


@bz1802074
Scenario Outline: logfilelevel <level> controls verbosity of dnf.log
Given I use repository "dnf-ci-fedora-updates"
 When I configure dnf with
      | key          | value   |
      | logfilelevel | <level> |
  And I execute dnf with args "install flac"
  And I execute dnf with args "remove flac"
 Then file "/var/log/dnf.log" contains lines
      """
      <info_lines>
      <debug_lines>
      <ddebug_lines>
      """
  And file "/var/log/dnf.log" does not contain lines
      """
      <not_present>
      """

Examples:
      | level | info_lines | debug_lines | ddebug_lines | not_present   |
      | 0     |            |             |              | .* INFO .*    |
      | 1     | .* INFO .* |             |              | .* DEBUG .*   |
      | 3     | .* INFO .* | .* DEBUG .* |              | .* DDEBUG .*  |
      | 7     | .* INFO .* | .* DEBUG .* | .* DDEBUG .* | .* WARNING .* |


@bz1802074
Scenario Outline: logfilelevel <level> controls verbosity of dnf.librepo.log and hawkey.log
Given I use repository "dnf-ci-fedora-updates"
 When I configure dnf with
      | key          | value   |
      | logfilelevel | <level> |
  And I execute dnf with args "install flac"
  And I execute dnf with args "remove flac"
 Then file "/var/log/dnf.librepo.log" contains lines
      """
      .* <info_line>
      .* <debug_line>
      """
 Then file "/var/log/hawkey.log" contains lines
      """
      <info_line>
      <debug_line>
      """
 Then file "/var/log/dnf.librepo.log" does not contain lines
      """
      <not_present>
      """
 Then file "/var/log/hawkey.log" does not contain lines
      """
      <not_present>
      """

Examples:
      | level | info_line | debug_line | not_present |
      | 1     | INFO .*   |            | DEBUG .*    |
      | 10    | INFO .*   | DEBUG .*   | WARNING .*  |


@bz1910084
Scenario: Logfiles are created with 644 permissions by default
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "install flac"
 Then the exit code is 0
  And file "/var/log/dnf.log" has mode "644"
  And file "/var/log/dnf.librepo.log" has mode "644"
  And file "/var/log/dnf.rpm.log" has mode "644"
  And file "/var/log/hawkey.log" has mode "644"


@bz1910084
Scenario: Created logfiles respect umask setting
Given I use repository "dnf-ci-fedora-updates"
 When I set umask to "0066"
  And I execute dnf with args "install flac"
 Then the exit code is 0
  And file "/var/log/dnf.log" has mode "600"
  And file "/var/log/dnf.librepo.log" has mode "600"
  And file "/var/log/dnf.rpm.log" has mode "600"
  And file "/var/log/hawkey.log" has mode "600"
Given I set umask to "0022"
