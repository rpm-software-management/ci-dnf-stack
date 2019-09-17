Feature: Upgrade packages with the same NEVRA but different build times

@bz1728252
Scenario Outline: Upgrade does not reinstall package with the same NEVRA and different build time
   # get build time of package from the repository and build local rpm
   # with build time set <offset> secs later
   When I execute "SOURCE_DATE_EPOCH=$(($(rpm -q --queryformat "%{{BUILDTIME}}" {context.dnf.repos_location}/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm) + <offset>)) rpmbuild -rb --define "_rpmdir ." {context.dnf.repos_location}/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm" in "{context.dnf.tempdir}"
   Then the exit code is 0
   # make sure that build times of local and repository packages are really different
   When I execute "[[ $(rpm -q --queryformat "%{{BUILDTIME}}" {context.dnf.repos_location}/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm) -ne $(rpm -q --queryformat "%{{BUILDTIME}}" noarch/setup-2.12.1-1.fc29.noarch.rpm) ]]" in "{context.dnf.tempdir}"
   Then the exit code is 0
   # install local package
   When I execute dnf with args "install {context.dnf.tempdir}/noarch/setup-2.12.1-1.fc29.noarch.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
   # try to update from repository rpm file
   When I execute dnf with args "upgrade {context.dnf.repos_location}/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm"
   Then the exit code is 0
    And Transaction is empty
   # try to update from remote repository
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is empty

Examples:
    | offset    |
    | 3600      |
    | -3600     |

