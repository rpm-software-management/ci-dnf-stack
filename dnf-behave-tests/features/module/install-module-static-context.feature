Feature: Installing modules from MdDocuments with static_context=True


Background:
  Given I set default module platformid to "platform:f29"


Scenario: Install module, profile from the latest module context without static_context
  Given I use repository "dnf-ci-multicontext-hybrid-multiversion-modular"
   When I execute dnf with args "module enable postgresql:9.6"
   Then the exit code is 0
    And modules state is following
        | Module        | State     | Stream    | Profiles  |
        | postgresql    | enabled   |    9.6    |           |
   When I execute dnf with args "module install nodejs:5/testlatest"
   Then the exit code is 0
    And modules state is following
        | Module   | State     | Stream    | Profiles   |
        | nodejs   |  enabled  |     5     | testlatest |
    And Transaction is following
        | Action                    | Package                                          |
        | module-stream-enable      | nodejs:5                                         |
        | module-profile-install    | nodejs/testlatest                                |
        | install-group             | postgresql-0:9.6.8-1.module_1710+b535a823.x86_64 |

Scenario: Install module, profile from the latest module context with static_context-=true
  Given I use repository "dnf-ci-multicontext-hybrid-multiversion-modular-static-context"
   When I execute dnf with args "module enable postgresql:9.6"
   Then the exit code is 0
    And modules state is following
        | Module        | State     | Stream    | Profiles  |
        | postgresql    | enabled   |    9.6    |           |
   When I execute dnf with args "module install nodejs:5/testlatest"
   Then the exit code is 0
    And modules state is following
        | Module   | State     | Stream    | Profiles   |
        | nodejs   |  enabled  |     5     | testlatest |
    And Transaction is following
        | Action                    | Package                                             |
        | module-stream-enable      | nodejs:5                                            |
        | module-profile-install    | nodejs/testlatest                                   |
        | install-group             | postgresql-0:9.6.8-1.module_1710+b535a823_V3.x86_64 |

Scenario: Install module, profile and the latest package with static_context-=true
  Given I use repository "dnf-ci-multicontext-hybrid-multiversion-modular-static-context"
   When I execute dnf with args "module enable postgresql:9.6"
   Then the exit code is 0
    And modules state is following
        | Module        | State     | Stream    | Profiles  |
        | postgresql    | enabled   |    9.6    |           |
   When I execute dnf with args "module install nodejs:5/minimal"
   Then the exit code is 0
    And modules state is following
        | Module   | State     | Stream    | Profiles   |
        | nodejs   |  enabled  |     5     | minimal |
    And Transaction is following
        | Action                    | Package                                         |
        | module-stream-enable      | nodejs:5                                        |
        | module-profile-install    | nodejs/minimal                                  |
        | install-group             | nodejs-1:5.4.1-2.module_2011+41787af1_V3.x86_64 |
