@dnf5daemon
Feature: Remove RPMs by provides


Background: Install glibc
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |


@dnf5
Scenario Outline: Remove an RPM by provide <operator> e:v-r
   When I execute dnf with args "remove 'glibc <operator> <e:v-r>'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | glibc-0:2.28-9.fc29.x86_64                |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch              |
        | remove-unused | filesystem-0:3.9-2.fc29.x86_64            |
        | remove-unused | basesystem-0:11-6.fc29.noarch             |
        | remove-unused | glibc-common-0:2.28-9.fc29.x86_64         |
        | remove-unused | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |

Examples:
        | operator      | e:v-r                |
        | =             | 0:2.28-9.fc29        |
        | >             | 0:2.28-8.fc29        |
        | >=            | 0:2.28-9.fc29        |
        | <             | 0:2.28-26.fc29       |
        | <=            | 0:2.28-9.fc29        |


# @dnf5
# TODO(nsella) different stdout
Scenario Outline: Remove an RPM by <provide type>
   When I execute dnf with args "remove <provide>"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | glibc-0:2.28-9.fc29.x86_64                |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch              |
        | remove-unused | filesystem-0:3.9-2.fc29.x86_64            |
        | remove-unused | basesystem-0:11-6.fc29.noarch             |
        | remove-unused | glibc-common-0:2.28-9.fc29.x86_64         |
        | remove-unused | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |

Examples:
        | provide type                        | provide               |
        | provide                             | 'libm.so.6()(64bit)'  |
        | file provide                        | /etc/ld.so.conf       |
        | file provide that is directory      | /var/db               |
        | file provide containing wildcards   | /etc/ld*.conf         |
