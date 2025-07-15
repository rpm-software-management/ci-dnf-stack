Feature: Enabling module streams - error handling


Background:
  Given I use repository "dnf-ci-fedora-modular-updates"


Scenario: Fail to enable a different stream of an already enabled module (dnf)
  Given I set dnf command to "dnf"
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
        WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module unless explicitly enabled via configuration option module_stream_switch.
        It is recommended to rather remove all installed content from the module, and reset the module using 'dnf module reset <module_name>' command. After you reset the module, you can install the other stream.
        """

Scenario: Fail to enable a different stream of an already enabled module (yum)
  Given I set dnf command to "yum"
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
        WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module unless explicitly enabled via configuration option module_stream_switch.
        It is recommended to rather remove all installed content from the module, and reset the module using 'yum module reset <module_name>' command. After you reset the module, you can install the other stream.
        """

Scenario: Fail to install a different stream of an already enabled module
  Given I set dnf command to "dnf"
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
        WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
        The operation would result in switching of module 'nodejs' stream '8' to stream '10'
        Error: It is not possible to switch enabled streams of a module unless explicitly enabled via configuration option module_stream_switch.
        It is recommended to rather remove all installed content from the module, and reset the module using 'dnf module reset <module_name>' command. After you reset the module, you can install the other stream.
        """


@bz1706215
Scenario: Fail to install a different stream of an already enabled module using @module:stream syntax
  Given I set dnf command to "dnf"
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
        Error: It is not possible to switch enabled streams of a module unless explicitly enabled via configuration option module_stream_switch.
        It is recommended to rather remove all installed content from the module, and reset the module using 'dnf module reset <module_name>' command. After you reset the module, you can install the other stream.
        """

@bz1814831
Scenario: Fail to enable a module stream when specifying only module
   When I execute dnf with args "module enable nodejs"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
        Argument 'nodejs' matches 4 streams ('8', '10', '11', '12') of module 'nodejs', but none of the streams are enabled or default
        Unable to resolve argument nodejs
        Error: Problems in request:
        broken groups or modules: nodejs
        """


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
  Given I set dnf command to "dnf"
   When I execute dnf with args "module enable"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        WARNING: modularity is deprecated, and functionality will be removed in a future release of DNF5.
        Error: dnf module enable: too few arguments
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


@not.with_os=rhel__eq__8
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
    And stderr contains "module beverage:soda:1:.x86_64 from dnf-ci-thirdparty-modular requires module\(fluid:water\), but none of the providers can be installed"


@not.with_os=rhel__eq__8
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
    And stderr contains "module beverage:soda:1:.x86_64 from dnf-ci-thirdparty-modular requires module\(fluid:water\), but none of the providers can be installed"
    And stderr contains "module fluid:water:1:.x86_64 from dnf-ci-thirdparty-modular is disabled"


# side-dish:chip requires fluid:oil
# beverage:beer requires fluid:water
@not.with_os=rhel__eq__8
Scenario: Enabling two modules both requiring different streams of another module
  Given I use repository "dnf-ci-thirdparty-modular"
   When I execute dnf with args "module enable side-dish:chips beverage:beer"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module side-dish:chips:1:.x86_64 from dnf-ci-thirdparty-modular requires module\(fluid:oil\), but none of the providers can be installed"
    And stderr contains "module beverage:beer:1:.x86_64 from dnf-ci-thirdparty-modular requires module\(fluid:water\), but none of the providers can be installed"


# beverage:beer requires fluid:water
@bz1651280
@not.with_os=rhel__eq__8
Scenario: Enabling module stream and another module requiring another stream
  Given I use repository "dnf-ci-thirdparty-modular"
   When I execute dnf with args "module enable fluid:oil beverage:beer"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module beverage:beer:1:.x86_64 from dnf-ci-thirdparty-modular requires module\(fluid:water\), but none of the providers can be installed"
