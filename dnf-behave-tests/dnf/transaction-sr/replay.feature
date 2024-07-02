Feature: Transaction replay tests

Background:
Given I set working directory to "{context.dnf.tempdir}"
Given I use repository "transaction-sr"
  And I successfully execute dnf with args "install top-a-1.0"


Scenario: Replay an install transaction
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-d-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | install-dep | bottom-a1-2.0-1.noarch   |
      | install     | top-d-1.0-1.x86_64       |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
      | Install       | top-d-1.0-1.x86_64      |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |
      | top-d-1.0-1.x86_64     | User            |


Scenario: Replay an install transaction from a non-existent repository
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "User",
                  "repo_id": "nonexistent"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | install     | bottom-a1-2.0-1.noarch   |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | User            |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |


Scenario: Replay an upgrade transaction
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | install-dep | bottom-a1-2.0-1.noarch   |
      | upgrade     | top-a-1:2.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |


Scenario: Replay a reinstall transaction
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reinstall",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | reinstall   | top-a-1:1.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Reinstall     | top-a-1:1.0-1.x86_64    |
      | Reinstalled   | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |



Scenario: Replay a downgrade transaction
Given I successfully execute dnf with args "upgrade top-a"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Downgrade",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Downgraded",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | downgrade   | top-a-1:1.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Downgrade     | top-a-1:1.0-1.x86_64    |
      | Downgraded    | top-a-1:2.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |


Scenario: Replay a remove transaction
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | remove      | top-a-1:1.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Removed       | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |


Scenario: Replay a reason change transaction
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Reason Change | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | Dependency      |


Scenario: Replay a reason change transaction on a not-installed package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Reason Change | top-b-1.0-1.x86_64      |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |


Scenario: Replay a reason change transaction on a package being installed
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Reason Change | top-b-1.0-1.x86_64      |
      | Install       | top-b-1.0-1.x86_64      |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |
      | top-b-1.0-1.x86_64     | Group           |


Scenario: Replay a reason change transaction on a package being removed
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Removed",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Reason Change | top-a-1:1.0-1.x86_64    |
      | Removed       | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |


Scenario: Replay installing a group
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-a",
                          "package_type": "mandatory"
                      },
                      {
                          "installed": true,
                          "name": "top-b",
                          "package_type": "default"
                      },
                      {
                          "installed": false,
                          "name": "top-c",
                          "package_type": "optional"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | top-a-1:2.0-1.x86_64     |
      | install-group | top-b-1.0-1.x86_64       |
      | install-dep   | bottom-a1-2.0-1.noarch   |
      | group-install | Test Group               |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
      | Install       | top-b-1.0-1.x86_64      |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
      | Install       | @test-group             |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |
      | top-b-1.0-1.x86_64     | Group           |
  And group state is
      | id         | package_types                   | packages | userinstalled |
      | test-group | conditional, default, mandatory | top-b    | True          |


Scenario: Replay installing a group without the `default` package type
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "test-group",
                  "package_types": "conditional, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-a",
                          "package_type": "mandatory"
                      },
                      {
                          "installed": false,
                          "name": "top-b",
                          "package_type": "default"
                      },
                      {
                          "installed": false,
                          "name": "top-c",
                          "package_type": "optional"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | top-a-1:2.0-1.x86_64     |
      | install-dep   | bottom-a1-2.0-1.noarch   |
      | group-install | Test Group               |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
      | Install       | @test-group             |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |
  And group state is
      | id         | package_types          | packages | userinstalled |
      | test-group | conditional, mandatory |          | True          |


Scenario: Replay removing a group
Given I successfully execute dnf with args "install @test-group"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Removed",
                  "id": "test-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-a",
                          "package_type": "mandatory"
                      },
                      {
                          "installed": true,
                          "name": "top-b",
                          "package_type": "default"
                      },
                      {
                          "installed": false,
                          "name": "top-c",
                          "package_type": "optional"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | remove        | top-b-1.0-1.x86_64       |
      | group-remove  | Test Group               |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Removed       | top-b-1.0-1.x86_64      |
      | Removed       | @test-group             |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |
  And group state is
      | id | package_types | packages | userinstalled |


Scenario: Replay upgrading a group
Given I successfully execute dnf with args "install @test-group"
  And I successfully execute dnf with args "install top-a-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Upgrade",
                  "id": "test-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-a",
                          "package_type": "mandatory"
                      },
                      {
                          "installed": true,
                          "name": "top-b",
                          "package_type": "default"
                      },
                      {
                          "installed": false,
                          "name": "top-c",
                          "package_type": "optional"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | top-a-1:2.0-1.x86_64     |
      | group-upgrade | Test Group               |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
      | Upgrade       | @test-group             |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |
      | top-b-1.0-1.x86_64     | Group           |
  And group state is
      | id         | package_types                   | packages | userinstalled |
      | test-group | conditional, default, mandatory | top-b    | True          |


Scenario: Replay installing an environment
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "groups": [
                      {
                          "group_type": "mandatory",
                          "id": "test-env-group",
                          "installed": true
                      },
                      {
                          "group_type": "optional",
                          "id": "test-env-optgroup",
                          "installed": false
                      }
                  ],
                  "id": "test-env",
                  "package_types": "conditional, default, mandatory"
              }
          ],
          "groups": [
              {
                  "action": "Install",
                  "id": "test-env-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-c",
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "top-c-2.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "mid-a2-2.0-1.x86_64",
                  "reason": "Weak Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "Weak Dependency",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | mid-a2-2.0-1.x86_64      |
      | install-group | top-c-2.0-1.x86_64       |
      | env-install   | Test Environment         |
      | group-install | Test Env Group           |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | top-c-2.0-1.x86_64      |
      | Upgrade       | mid-a2-2.0-1.x86_64     |
      | Upgraded      | mid-a2-1.0-1.x86_64     |
      | Install       | @test-env-group         |
      | Install       | @test-env               |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-2.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |
      | top-c-2.0-1.x86_64     | Group           |
  And environment state is
      | id       | groups         |
      | test-env | test-env-group |


Scenario: Replay removing an environment group
Given I successfully execute dnf with args "install @test-env"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Removed",
                  "groups": [
                      {
                          "group_type": "mandatory",
                          "id": "test-env-group",
                          "installed": true
                      },
                      {
                          "group_type": "optional",
                          "id": "test-env-optgroup",
                          "installed": false
                      }
                  ],
                  "id": "test-env",
                  "package_types": "conditional, default, mandatory"
              }
          ],
          "groups": [
              {
                  "action": "Removed",
                  "id": "test-env-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-c",
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "bottom-a3-1.0-1.x86_64",
                  "reason": "Clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "mid-a2-2.0-1.x86_64",
                  "reason": "Clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "top-c-2.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | remove        | top-c-2.0-1.x86_64       |
      | remove-unused | bottom-a3-1.0-1.x86_64   |
      | remove-unused | mid-a2-2.0-1.x86_64      |
      | group-remove  | Test Env Group           |
      | env-remove    | Test Environment         |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Removed       | bottom-a3-1.0-1.x86_64  |
      | Removed       | mid-a2-2.0-1.x86_64     |
      | Removed       | top-c-2.0-1.x86_64      |
      | Removed       | @test-env-group         |
      | Removed       | @test-env               |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | top-a-1:1.0-1.x86_64   | User            |
  And environment state is
      | id       | groups |


Scenario: Replay upgrading an environment group
Given I successfully execute dnf with args "install @test-env"
  And I successfully execute dnf with args "install top-c-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Upgrade",
                  "groups": [
                      {
                          "group_type": "mandatory",
                          "id": "test-env-group",
                          "installed": true
                      },
                      {
                          "group_type": "optional",
                          "id": "test-env-optgroup",
                          "installed": false
                      }
                  ],
                  "id": "test-env",
                  "package_types": "conditional, default, mandatory"
              }
          ],
          "groups": [
              {
                  "action": "Upgrade",
                  "id": "test-env-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-c",
                          "package_type": "mandatory"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "mid-a2-2.0-1.x86_64",
                  "reason": "Weak Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "Weak Dependency",
                  "repo_id": "@System"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-c-2.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-c-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | top-c-2.0-1.x86_64       |
      | upgrade       | mid-a2-2.0-1.x86_64      |
      | group-upgrade | Test Env Group           |
      | env-upgrade   | Test Environment         |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Upgrade       | mid-a2-2.0-1.x86_64     |
      | Upgraded      | mid-a2-1.0-1.x86_64     |
      | Upgrade       | top-c-2.0-1.x86_64      |
      | Upgraded      | top-c-1.0-1.x86_64      |
      | Upgrade       | @test-env-group         |
      | Upgrade       | @test-env               |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-2.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |
      | top-c-2.0-1.x86_64     | Group           |
  And environment state is
      | id       | groups         |
      | test-env | test-env-group |


Scenario: Replay a transaction installing multiple installonly packages
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | install     | installonly-1.0-1.x86_64 |
      | install     | installonly-2.0-1.x86_64 |
  And History info should match
      | Key           | Value                    |
      | Return-Code   | Success                  |
      | Install       | installonly-1.0-1.x86_64 |
      | Install       | installonly-2.0-1.x86_64 |
  And package reasons are
      | Package                  | Reason          |
      | bottom-a2-1.0-1.x86_64   | Dependency      |
      | bottom-a3-1.0-1.x86_64   | Dependency      |
      | installonly-1.0-1.x86_64 | User            |
      | installonly-2.0-1.x86_64 | User            |
      | mid-a1-1.0-1.x86_64      | Dependency      |
      | mid-a2-1.0-1.x86_64      | Weak Dependency |
      | top-a-1:1.0-1.x86_64     | User            |


Scenario: Replay a transaction removing multiple installonly packages
Given I successfully execute dnf with args "install installonly-1.0 installonly-2.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | remove      | installonly-1.0-1.x86_64 |
      | remove      | installonly-2.0-1.x86_64 |
  And History info should match
      | Key           | Value                    |
      | Return-Code   | Success                  |
      | Removed       | installonly-2.0-1.x86_64 |
      | Removed       | installonly-1.0-1.x86_64 |
  And package reasons are
      | Package                | Reason          |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |


Scenario: Replay a transaction installing and removing an installonly package
Given I successfully execute dnf with args "install installonly-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Removed",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | install     | installonly-2.0-1.x86_64 |
      | remove      | installonly-1.0-1.x86_64 |
  And History info should match
      | Key           | Value                    |
      | Return-Code   | Success                  |
      | Install       | installonly-2.0-1.x86_64 |
      | Removed       | installonly-1.0-1.x86_64 |
  And package reasons are
      | Package                  | Reason          |
      | bottom-a2-1.0-1.x86_64   | Dependency      |
      | bottom-a3-1.0-1.x86_64   | Dependency      |
      | installonly-2.0-1.x86_64 | unknown         |
      | mid-a1-1.0-1.x86_64      | Dependency      |
      | mid-a2-1.0-1.x86_64      | Weak Dependency |
      | top-a-1:1.0-1.x86_64     | User            |


Scenario: Replay a transaction obsoleting a package
Given I successfully execute dnf with args "install obsoleted-a-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "obsoleting-x-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-a-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                   |
      | install     | obsoleting-x-2.0-1.x86_64 |
      | obsoleted   | obsoleted-a-1.0-1.x86_64  |
  And History info should match
      | Key           | Value                     |
      | Return-Code   | Success                   |
      | Install       | obsoleting-x-2.0-1.x86_64 |
      | Obsoleted     | obsoleted-a-1.0-1.x86_64  |
  And package reasons are
      | Package                   | Reason          |
      | bottom-a2-1.0-1.x86_64    | Dependency      |
      | bottom-a3-1.0-1.x86_64    | Dependency      |
      | mid-a1-1.0-1.x86_64       | Dependency      |
      | mid-a2-1.0-1.x86_64       | Weak Dependency |
      | obsoleting-x-2.0-1.x86_64 | User            |
      | top-a-1:1.0-1.x86_64      | User            |


Scenario: Replay a transaction obsoleting multiple packages
Given I successfully execute dnf with args "install obsoleted-a-1.0 obsoleted-b-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "obsoleting-x-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-a-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-b-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              },
              {
                  "action": "Install",
                  "nevra": "obsoleting-y-2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                   |
      | install     | obsoleting-x-2.0-1.x86_64 |
      | install     | obsoleting-y-2.0-1.x86_64 |
      | obsoleted   | obsoleted-a-1.0-1.x86_64  |
      | obsoleted   | obsoleted-b-1.0-1.x86_64  |
  And History info should match
      | Key           | Value                     |
      | Return-Code   | Success                   |
      | Install       | obsoleting-x-2.0-1.x86_64 |
      | Obsoleted     | obsoleted-a-1.0-1.x86_64  |
      | Obsoleted     | obsoleted-b-1.0-1.x86_64  |
      | Install       | obsoleting-y-2.0-1.x86_64 |
  And package reasons are
      | Package                   | Reason          |
      | bottom-a2-1.0-1.x86_64    | Dependency      |
      | bottom-a3-1.0-1.x86_64    | Dependency      |
      | mid-a1-1.0-1.x86_64       | Dependency      |
      | mid-a2-1.0-1.x86_64       | Weak Dependency |
      | obsoleting-x-2.0-1.x86_64 | User            |
      | obsoleting-y-2.0-1.x86_64 | User            |
      | top-a-1:1.0-1.x86_64      | User            |


Scenario: Replay an upgrade transaction where a package that is being upgraded has a different reason
Given I successfully execute dnf with args "install bottom-a1-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "bottom-a1-1.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "@System"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                  |
      | upgrade     | bottom-a1-2.0-1.noarch   |
      | upgrade     | top-a-1:2.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Upgrade       | bottom-a1-2.0-1.noarch  |
      | Upgraded      | bottom-a1-1.0-1.noarch  |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | User            |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |


Scenario: Replay a transaction with an arch change
Given I successfully execute dnf with args "install archchange-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "archchange-2.0-1.x86_64",
                  "reason": "unknown",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "archchange-1.0-1.noarch",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And DNF Transaction is following
      | Action      | Package                   |
      | upgrade     | archchange-2.0-1.x86_64   |
  And RPMDB Transaction is following
      | Action      | Package                   |
      | remove      | archchange-1.0-1.noarch   |
      | install     | archchange-2.0-1.x86_64   |
  And History info should match
      | Key           | Value                     |
      | Return-Code   | Success                   |
      | Upgrade       | archchange-2.0-1.x86_64   |
      | Upgraded      | archchange-1.0-1.noarch   |
  And package reasons are
      | Package                 | Reason          |
      | archchange-2.0-1.x86_64 | unknown         |
      | bottom-a2-1.0-1.x86_64  | Dependency      |
      | bottom-a3-1.0-1.x86_64  | Dependency      |
      | mid-a1-1.0-1.x86_64     | Dependency      |
      | mid-a2-1.0-1.x86_64     | Weak Dependency |
      | top-a-1:1.0-1.x86_64    | User            |


Scenario: Replay a transaction with multiple actions per NEVRA
Given I successfully execute dnf with args "install @test-group supertop-b"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Removed",
                  "id": "test-group",
                  "package_types": "conditional, default, mandatory",
                  "packages": [
                      {
                          "installed": true,
                          "name": "top-a",
                          "package_type": "mandatory"
                      },
                      {
                          "installed": true,
                          "name": "top-b",
                          "package_type": "default"
                      },
                      {
                          "installed": false,
                          "name": "top-c",
                          "package_type": "optional"
                      }
                  ]
              }
          ],
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstall",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "Group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 0
  And Transaction is following
      | Action       | Package                   |
      | reinstall    | top-b-1.0-1.x86_64        |
      | group-remove | Test Group                |
  And History info should match
      | Key           | Value                     |
      | Return-Code   | Success                   |
      | Reason Change | top-b-1.0-1.x86_64        |
      | Reinstall     | top-b-1.0-1.x86_64        |
      | Reinstalled   | top-b-1.0-1.x86_64        |
      | Removed       | @test-group               |
  And package reasons are
      | Package                 | Reason          |
      | bottom-a1-2.0-1.noarch  | Dependency      |
      | bottom-a2-1.0-1.x86_64  | Dependency      |
      | bottom-a3-1.0-1.x86_64  | Dependency      |
      | mid-a1-1.0-1.x86_64     | Dependency      |
      | mid-a2-1.0-1.x86_64     | Weak Dependency |
      | supertop-b-1.0-1.x86_64 | User            |
      | top-a-1:2.0-1.x86_64    | User            |
      | top-b-1.0-1.x86_64      | Dependency      |


Scenario: ignore-installed: Replay an upgrade transaction where a package that is being installed is already on the system in a lower version
Given I successfully execute dnf with args "install bottom-a1-1.0"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --ignore-installed"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Package "bottom-a1.noarch" is already installed for action "Install".
      """
  And Transaction is following
      | Action      | Package                  |
      | upgrade     | bottom-a1-2.0-1.noarch   |
      | upgrade     | top-a-1:2.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Upgrade       | bottom-a1-2.0-1.noarch  |
      | Upgraded      | bottom-a1-1.0-1.noarch  |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | User            |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |


Scenario: ignore-installed: Replaying an already installed transaction results in noop
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a2-1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "bottom-a3-1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a1-1.0-1.x86_64",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "Weak Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --ignore-installed"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Package "bottom-a2.x86_64" is already installed for action "Install".
        Package "bottom-a3.x86_64" is already installed for action "Install".
        Package "mid-a1.x86_64" is already installed for action "Install".
        Package "mid-a2.x86_64" is already installed for action "Install".
        Package "top-a.x86_64" is already installed for action "Install".
      """
  And Transaction is empty


Scenario: ignore-installed: Replay an upgrade transaction where a package that is being upgraded is not installed on the system
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "bottom-a1-1.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "@System"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --ignore-installed"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Package nevra "bottom-a1-1.0-1.noarch" not installed for action "Upgraded".
      """
  And Transaction is following
      | Action      | Package                  |
      | install-dep | bottom-a1-2.0-1.noarch   |
      | upgrade     | top-a-1:2.0-1.x86_64     |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
      | Upgrade       | top-a-1:2.0-1.x86_64    |
      | Upgraded      | top-a-1:1.0-1.x86_64    |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:2.0-1.x86_64   | User            |


Scenario: ignore-installed: Replay a remove transaction where a package that is being removed is not installed on the system
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --ignore-installed"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Package nevra "bottom-a1-2.0-1.noarch" not installed for action "Removed".
      """
  And Transaction is empty


Scenario: skip-unavailable: Replay a transaction installing a nonexistent package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "does-not-exist-1.0-1.noarch",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --skip-unavailable"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Cannot find rpm nevra "does-not-exist-1.0-1.noarch".
      """
  And Transaction is following
      | Action      | Package                  |
      | install-dep | bottom-a1-2.0-1.noarch   |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |


Scenario: skip-unavailable: Replay a transaction reinstalling a non-available package
Given I successfully execute dnf with args "install bottom-a1-2.0"
  And I drop repository "transaction-sr"
  And I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Reinstall",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --skip-unavailable"
 Then the exit code is 0
  And stderr is
      """
      Warning, the following problems occurred while running a transaction:
        Package nevra "bottom-a1-2.0-1.noarch" not available in repositories for action "Reinstall".
      """
  And Transaction is empty


Scenario: skip-broken: Replay a transaction with a broken dependency
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "Dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "broken-dep-1.0-1.x86_64",
                  "reason": "User",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json --skip-broken"
 Then the exit code is 0
  And Transaction is following
      | Action      | Package                   |
      | install-dep | bottom-a1-2.0-1.noarch    |
      | broken      | broken-dep-0:1.0-1.x86_64 |
  And History info should match
      | Key           | Value                   |
      | Return-Code   | Success                 |
      | Install       | bottom-a1-2.0-1.noarch  |
  And package reasons are
      | Package                | Reason          |
      | bottom-a1-2.0-1.noarch | Dependency      |
      | bottom-a2-1.0-1.x86_64 | Dependency      |
      | bottom-a3-1.0-1.x86_64 | Dependency      |
      | mid-a1-1.0-1.x86_64    | Dependency      |
      | mid-a2-1.0-1.x86_64    | Weak Dependency |
      | top-a-1:1.0-1.x86_64   | User            |
