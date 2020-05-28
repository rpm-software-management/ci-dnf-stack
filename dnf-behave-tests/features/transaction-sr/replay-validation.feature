Feature: Transaction replay invalid json tests

Background:
Given I set working directory to "{context.dnf.tempdir}"
Given I use repository "transaction-sr"


Scenario: Replay a non-existant file
 When I execute dnf with args "history replay nonexistent.json"
 Then the exit code is 1
  And stderr is
      """
      [Errno 2] No such file or directory: '{context.dnf.tempdir}/nonexistent.json'
      """


Scenario: Replay a broken json
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "version": "0.0"
          "missing_comma": 1
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Expecting ',' delimiter: line 3 column 5 (char 27).
      """


Scenario: Replay a json missing version
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": []
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing key "version".
      """


Scenario: Replay a json wrong version type
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "version": 1
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "version", string expected.
      """


Scenario: Replay a json invalid major version characters
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "version": "a.1"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Invalid major version "a", number expected.
      """


Scenario: Replay a json invalid minor version characters
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "version": "1.a"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Invalid minor version "a", number expected.
      """


Scenario: Replay a json incompatible major version
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "version": "5.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Incompatible major version "5", supported major version is "0".
      """


Scenario: Replay a json wrong packages type
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": "hi",
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "rpms", array expected.
      """


Scenario: Replay a json with missing action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "action" in an rpm.
      """


Scenario: Replay a json with missing nevra
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "reason": "user"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "nevra" in an rpm.
      """


Scenario: Replay a json with missing reason
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "top-a-1:1.0-1.x86_64"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "reason" in an rpm.
      """


Scenario: Replay a json with invalid action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Fixxit",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected value of package action "Fixxit" for rpm nevra "top-a-1:1.0-1.x86_64".
      """


Scenario: Replay a json unparseable package nevra (the code cannot distinguish invalid nevra atm.)
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "wakaka",
                  "reason": "user"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Cannot parse NEVRA for package "wakaka".
      """


Scenario: Replay a json with invalid reason
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "dumb"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected value of package reason "dumb" for rpm nevra "top-a-1:1.0-1.x86_64".
      """


Scenario: Replay a json wrong groups type
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": "hi",
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "groups", array expected.
      """


Scenario: Replay a json with missing group id
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Invalid"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "id" in a group.
      """


Scenario: Replay a json with missing group action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "id": "dummy",
                  "package_types": "mandatory",
                  "packages": []
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "action" in a group.
      """


Scenario: Replay a json with invalid group action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Invalid",
                  "id": "dummy",
                  "package_types": "mandatory",
                  "packages": []
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected value of group action "Invalid" for group "dummy".
      """


Scenario: Replay a json with invalid group package_types
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "dummy",
                  "package_types": "aaa, default",
                  "packages": []
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Invalid comps package type "aaa".
      """


Scenario: Replay a json with missing group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "dummy",
                  "package_types": "mandatory"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "packages" in a group.
      """


Scenario: Replay a json with missing name in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "installed": false,
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "name" in groups.packages.
      """


Scenario: Replay a json with missing installed in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "name": "foo",
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "installed" in groups.packages.
      """


Scenario: Replay a json with missing package_type in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "name": "foo",
                          "installed": false
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "package_type" in groups.packages.
      """


Scenario: Replay a json with invalid name type in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "name": 1,
                          "installed": false,
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "groups.packages.name", string expected.
      """


Scenario: Replay a json with invalid installed type in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "name": "foo",
                          "installed": "hi",
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "groups.packages.installed", boolean expected.
      """


Scenario: Replay a json with invalid package_type type in group packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "mandatory",
                  "packages": [
                      {
                          "name": "foo",
                          "installed": false,
                          "package_type": true
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "groups.packages.package_type", string expected.
      """


Scenario: Replay a json wrong environments type
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": "hi",
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "environments", array expected.
      """


Scenario: Replay a json with missing environment id
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Invalid"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "id" in an environment.
      """


Scenario: Replay a json with missing environment action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "id": "dummy"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "action" in an environment.
      """


Scenario: Replay a json with invalid environment action
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Invalid",
                  "id": "dummy",
                  "package_types": "mandatory"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected value of environment action "Invalid" for environment "dummy".
      """


Scenario: Replay a json with invalid environment package_types
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "dummy",
                  "package_types": "aaa, default"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Invalid comps package type "aaa".
      """


Scenario: Replay a json with missing environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "dummy",
                  "package_types": "mandatory"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "groups" in an environment.
      """


Scenario: Replay a json with missing id in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "installed": false,
                          "group_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "id" in environments.groups.
      """


Scenario: Replay a json with missing installed in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "id": "foo",
                          "group_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "installed" in environments.groups.
      """


Scenario: Replay a json with missing group_type in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "id": "foo",
                          "installed": false
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Missing object key "group_type" in environments.groups.
      """


Scenario: Replay a json with invalid id type in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "id": 1,
                          "installed": false,
                          "group_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "environments.groups.id", string expected.
      """


Scenario: Replay a json with invalid installed type in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "id": "foo",
                          "installed": "hi",
                          "group_type": "mandatory"
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "environments.groups.installed", boolean expected.
      """


Scenario: Replay a json with invalid group_type type in environment groups
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "id": "test-env",
                  "package_types": "mandatory",
                  "groups": [
                      {
                          "id": "foo",
                          "installed": false,
                          "group_type": true
                      }
                  ]
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: Error in "{context.dnf.tempdir}/transaction.json": Unexpected type of "environments.groups.group_type", string expected.
      """
