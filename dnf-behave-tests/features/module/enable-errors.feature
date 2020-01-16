Feature: Enabling module streams - error handling


Background:
  Given I use repository "dnf-ci-fedora-modular-updates"


Scenario: Fail to enable a different stream of an already enabled module
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module enable nodejs:10"
   Then the exit code is 1
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
    And stderr is
        """
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module.
        It is recommended to remove all installed content from the module, and reset the module using '{context.dnf.prog_name} module reset <module_name>' command. After you reset the module, you can install the other stream.
        """

Scenario: Fail to install a different stream of an already enabled module
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module install nodejs:10/minimal --skip-broken"
   Then the exit code is 1
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
    And stderr is
        """
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module.
        It is recommended to remove all installed content from the module, and reset the module using '{context.dnf.prog_name} module reset <module_name>' command. After you reset the module, you can install the other stream.
        """


@bz1706215
Scenario: Fail to install a different stream of an already enabled module using @module:stream syntax
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "install @nodejs:10/minimal --skip-broken"
   Then the exit code is 1
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
    And stderr is
        """
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module.
        It is recommended to remove all installed content from the module, and reset the module using '{context.dnf.prog_name} module reset <module_name>' command. After you reset the module, you can install the other stream.
        """


Scenario: Fail to enable a module stream when specifying only module
   When I execute dnf with args "module enable nodejs"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr contains "Cannot enable more streams from module 'nodejs' at the same time"
    And stderr contains "Unable to resolve argument nodejs"
    And stderr contains "Error: Problems in request:"
    And stderr contains "broken groups or modules: nodejs"


@bz1629655
Scenario: Fail to enable a module stream when specifying wrong version
   When I execute dnf with args "module enable nodejs:8:99"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr contains "Error: Problems in request:"
    And stderr contains "missing groups or modules: nodejs:8:99"


@bz1629655
Scenario: Fail to enable a non-existent module stream
   When I execute dnf with args "module enable nodejs:1"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr contains "Error: Problems in request:"
    And stderr contains "missing groups or modules: nodejs:1"


Scenario: Fail to enable a module stream when not specifying anything
   When I execute dnf with args "module enable"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Error: {context.dnf.prog_name} module enable: too few arguments
        """


@bz1581267
Scenario: Fail to enable a module stream when specifying more streams of the same module
   When I execute dnf with args "module enable nodejs:8 nodejs:10"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr contains "Cannot enable multiple streams for module 'nodejs'"
    And stderr contains "Unable to resolve argument nodejs:10"
    And stderr contains "Error: Problems in request:"
    And stderr contains "broken groups or modules: nodejs:10"


Scenario: Enabling a stream depending on other than enabled stream should fail
  Given I use repository "dnf-ci-thirdparty-modular"
    And I create file "/etc/dnf/modules.defaults.d/defaults.yaml" with
        """
        ---
        document: modulemd-defaults
        version: 1
        data:
            module: beverage
            stream: soda
            profiles:
                default: [default]
        ...
        ---
        document: modulemd-defaults
        version: 1
        data:
            module: fluid
            stream: oil
            profiles:
                default: [default]
        ...
        """
   When I execute dnf with args "module enable fluid"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-stream-enable     | fluid:oil              |
   When I execute dnf with args "module enable beverage:soda"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module beverage:soda:1:-0.x86_64 requires module\(fluid:water\), but none of the providers can be installed"


Scenario: Enabling a stream depending on a disabled stream should fail
  Given I use repository "dnf-ci-thirdparty-modular"
    And I create file "/etc/dnf/modules.defaults.d/defaults.yaml" with
        """
        ---
        document: modulemd-defaults
        version: 1
        data:
            module: beverage
            stream: soda
            profiles:
                default: [default]
        ...
        ---
        document: modulemd-defaults
        version: 1
        data:
            module: fluid
            stream: water
            profiles:
                default: [default]
        ...
        """
   When I execute dnf with args "module disable fluid"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-disable           | fluid                  |
   When I execute dnf with args "module enable beverage:soda"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module beverage:soda:1:-0.x86_64 requires module\(fluid:water\), but none of the providers can be installed"
    And stderr contains "module fluid:water:1:-0.x86_64 is disabled"


# side-dish:chip requires fluid:oil
# beverage:beer requires fluid:water
Scenario: Enabling two modules both requiring different streams of another module
  Given I use repository "dnf-ci-thirdparty-modular"
   When I execute dnf with args "module enable side-dish:chips beverage:beer"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module side-dish:chips:1:-0.x86_64 requires module\(fluid:oil\), but none of the providers can be installed"
    And stderr contains "module beverage:beer:1:-0.x86_64 requires module\(fluid:water\), but none of the providers can be installed"


# beverage:beer requires fluid:water
@bz1651280
Scenario: Enabling module stream and another module requiring another stream
  Given I use repository "dnf-ci-thirdparty-modular"
   When I execute dnf with args "module enable fluid:oil beverage:beer"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module beverage:beer:1:-0.x86_64 requires module\(fluid:water\), but none of the providers can be installed"
