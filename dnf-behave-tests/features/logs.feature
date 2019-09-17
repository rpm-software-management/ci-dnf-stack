Feature: Logs


@not.with_os=rhel__eq__8
@bz1739457
Scenario: dnf.rpm.log doesn't contain duplicate entries ()
  Given I use the repository "dnf-ci-fedora-updates"
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
