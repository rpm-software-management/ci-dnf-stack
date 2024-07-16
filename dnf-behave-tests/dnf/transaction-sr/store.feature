Feature: Transaction store tests

Background:
Given I set working directory to "{context.dnf.tempdir}"
Given I use repository "transaction-sr"
  And I successfully execute dnf with args "install top-a-1.0"


Scenario: Store a transaction
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a2-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "bottom-a3-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a1-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "weak-dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with an invalid transaction ID
 When I execute dnf with args "history store 2"
 Then the exit code is 1
  And stderr is
      """
      Error: Transaction ID "2" not found.
      """


Scenario: Store an upgrade transaction
Given I successfully execute dnf with args "upgrade top-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-2.0-1.noarch",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a reinstall transaction
Given I successfully execute dnf with args "reinstall top-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Reinstall",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a downgrade transaction
Given I successfully execute dnf with args "upgrade top-a"
Given I successfully execute dnf with args "downgrade top-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Downgrade",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Downgraded",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a remove transaction
Given I successfully execute dnf with args "remove top-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "bottom-a2-1.0-1.x86_64",
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "bottom-a3-1.0-1.x86_64",
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "mid-a1-1.0-1.x86_64",
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a reason change transaction
Given I successfully execute dnf with args "mark remove top-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Reason Change",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with a group install
Given I successfully execute dnf with args "install @test-group"
 When I execute dnf with args "history store 2"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with a group remove
Given I successfully execute dnf with args "install @test-group"
  And I successfully execute dnf with args "remove @test-group"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with a group upgrade
Given I successfully execute dnf with args "install @test-group"
Given I successfully execute dnf with args "install top-a-1.0"
Given I successfully execute dnf with args "upgrade @test-group"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with an enviroment group install
Given I successfully execute dnf with args "install @test-env"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "mid-a2-2.0-1.x86_64",
                  "reason": "weak-dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "weak-dependency",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with an environment group remove
Given I successfully execute dnf with args "install @test-env"
  And I successfully execute dnf with args "remove @test-env"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "mid-a2-2.0-1.x86_64",
                  "reason": "clean",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "top-c-2.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with an environment group upgrade
Given I successfully execute dnf with args "install @test-env"
  And I successfully execute dnf with args "install top-c-1.0"
  And I successfully execute dnf with args "upgrade @test-env"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "weak-dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "weak-dependency",
                  "repo_id": "@System"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-c-2.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-c-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction installing multiple installonly package versions
Given I successfully execute dnf with args "install installonly-1.0 installonly-2.0"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction removing multiple installonly package versions
Given I successfully execute dnf with args "install installonly-1.0 installonly-2.0"
  And I successfully execute dnf with args "remove installonly-1.0 installonly-2.0"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              },
              {
                  "action": "Removed",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction installing and removing an installonly package
Given I successfully execute dnf with args "install installonly-1.0"
  And I open dnf shell session
  And I execute in dnf shell "install installonly-2.0"
  And I execute in dnf shell "remove installonly-1.0"
  And I execute in dnf shell "run"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Removed",
                  "nevra": "installonly-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction upgrading an installonly package
Given I successfully execute dnf with args "install installonly-1.0"
  And I successfully execute dnf with args "upgrade installonly"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "installonly-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction obsoleting a package
Given I successfully execute dnf with args "install obsoleted-a-1.0"
  And I successfully execute dnf with args "upgrade obsoleted-a"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "obsoleting-x-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-a-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction obsoleting multiple packages
Given I successfully execute dnf with args "install obsoleted-a-1.0 obsoleted-b-1.0"
  And I successfully execute dnf with args "upgrade obsoleted-a obsoleted-b"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "obsoleting-x-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-a-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              },
              {
                  "action": "Obsoleted",
                  "nevra": "obsoleted-b-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              },
              {
                  "action": "Install",
                  "nevra": "obsoleting-y-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with an arch change
Given I successfully execute dnf with args "install archchange-1.0"
  And I successfully execute dnf with args "upgrade archchange"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with multiple actions per NEVRA (removing a group and reinstalling its package while another package depends on it)
Given I successfully execute dnf with args "install @test-group supertop-b"
  And I open dnf shell session
  And I execute in dnf shell "remove @test-group"
  And I execute in dnf shell "reinstall top-b-1.0-1.x86_64"
  And I execute in dnf shell "run"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstall",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with removing a group and reinstalling its package (unlike the scenario above, the reason of the package stays unchanged)
Given I successfully execute dnf with args "install @test-group"
  And I open dnf shell session
  And I execute in dnf shell "remove @test-group"
  And I execute in dnf shell "reinstall top-b-1.0-1.x86_64"
  And I execute in dnf shell "run"
 When I execute dnf with args "history store last"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """
  And file "/{context.dnf.tempdir}/transaction.json" contents is
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
                  "action": "Reinstall",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Reinstalled",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "group",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction with specifying the output file
 When I execute dnf with args "history store last -o {context.dnf.tempdir}/out.json"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to {context.dnf.tempdir}/out.json.
      """
  And file "/{context.dnf.tempdir}/out.json" contents is
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a2-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "bottom-a3-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a1-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "mid-a2-1.0-1.x86_64",
                  "reason": "weak-dependency",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Install",
                  "nevra": "top-a-1:1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """


Scenario: Store a transaction to a file that already exists and --assumeyes
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      STUFF
      """
 When I execute dnf with args "history store last -y"
 Then the exit code is 0
  And stdout is
      """
      Transaction saved to transaction.json.
      """


Scenario: Store a transaction to a file that already exists and --assumeno
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      STUFF
      """
 When I execute dnf with args "history store last --assumeno"
 Then the exit code is 0
  And stdout is
      """
      Not overwriting transaction.json, exiting.
      """
