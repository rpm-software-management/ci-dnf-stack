Feature: Updating module profiles


Background:
Given I use the repository "dnf-ci-fedora-modular"
  And I use the repository "dnf-ci-fedora"
  

Scenario: I can update a module profile to a newer version
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8          |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | install                   | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-install    | nodejs/default                                |
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "module update nodejs/default"
 Then the exit code is 0
  And Transaction is following
      | Action                    | Package                                       |
      | upgrade                   | npm-1:8.14.0-1.module_2030+42747d41.x86_64    |
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |


Scenario: Disabled but installed profile should not be receiving updates
 When I execute dnf with args "module install nodejs:8/default"
 Then the exit code is 0
 When I execute dnf with args "module disable nodejs"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "module update nodejs/default"
 Then the exit code is 0
  And Transaction is empty


Scenario: I try to update a module when no update is available
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8          |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | install                   | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-install    | nodejs/default                                |
 When I execute dnf with args "module update nodejs/default"
 Then the exit code is 0
  And stdout contains "Nothing to do."
  And Transaction is empty
 

# (original comment): Dnf does not remove any packages as of now
# TODO(ales): and does it install them?
@xfail
Scenario: I can update a module profile with package changes
 When I execute dnf with args "module enable nodejs:10"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 10        |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                        |
      | install                   | nodejs-1:10.11.0-1.module_2200+adbac02b.x86_64 |
      | install                   | npm-1:10.11.0-1.module_2200+adbac02b.x86_64    |
      | module-profile-install    | nodejs/default                                 |
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "module update nodejs/default"
 Then the exit code is 0
 And Transaction contains
 | Action                   | Package                                              |
 | upgrade                  | nodejs-1:10.14.1-1.module_2533+7361f245.x86_64       |
 | remove                   | npm-1:10.11.0-1.module_2200+adbac02b.x86_64          |
 | install                  | nodejs-devel-1:10.14.1-1.module_2533+7361f245.x86_64 |
   
    
# https://bugzilla.redhat.com/show_bug.cgi?id=1582546
@xfail
Scenario: default stream is used for new deps during an update
 When I execute dnf with args "module enable nodejs:11"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 11        |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:11.0.0-1.module_2311+8d497411.x86_64 |
      | install                   | npm-1:11.0.0-1.module_2311+8d497411.x86_64    |
      | module-profile-install    | nodejs/default                                |
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "module update nodejs/default"
 Then the exit code is 0
  And Transaction is following
      | Action                    | Package                                         |
      | upgrade                   | npm-1:11.1.0-1.module_2379+8d497405.x86_64      |
      | upgrade                   | nodejs-1:11.1.0-1.module_2379+8d497405.x86_64   |
      | install                   | wget-0:1.19.5-5.fc29.x86_64                     |
      | install                   | CQRlib-0:1.1.1-4.fc29.x86_64                      |
      | install                   | CQRlib-devel-0:1.1.2-16.fc29.x86_64               |
      | install                   | postgresql-0:9.6.11-1.module_2689+ea8f147f.x86_64 |


# bz#1583059
Scenario: Both ursine packages and modules are updated during dnf update
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
Given I use the repository "dnf-ci-thirdparty"
 When I execute dnf with args "install CQRlib CQRlib-extension"
 Then the exit code is 0
  And Transaction is following
      | Action                    | Package                                       |
      | install                   | CQRlib-0:1.1.1-4.fc29.x86_64                  |
      | install                   | CQRlib-extension-0:1.5-2.x86_64               |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | install                   | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-install    | nodejs/default                                |
Given I use the repository "dnf-ci-fedora-modular-updates"
Given I use the repository "dnf-ci-thirdparty-updates"
 When I execute dnf with args "update"
 Then the exit code is 0
   And Transaction is following
       | Action                    | Package                                       |
       | upgrade                   | npm-1:8.14.0-1.module_2030+42747d41.x86_64    |
       | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
       | upgrade                   | CQRlib-extension-0:1.6-2.x86_64               |
       | install                   | SuperRipper-0:1.2-1.x86_64                    |
