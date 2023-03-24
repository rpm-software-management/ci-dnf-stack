Feature: Transaction replay tests

Background:
Given I set working directory to "{context.dnf.tempdir}"
  And I use repository "transaction-sr"
  And I successfully execute dnf with args "install top-a-1.0"


Scenario: Replay a transaction installing a nonexistent package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "does-not-exist-1.0-1.noarch",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "does-not-exist-1.0-1.noarch".
      """


Scenario: Replay a transaction installing a nonexistent package version
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "top-a-1:3.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "top-a-1:3.0-1.x86_64".
      """


Scenario: Replaying an already installed package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a2-1.0-1.x86_64",
                  "reason": "dependency",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Package "bottom-a2.x86_64" is already installed for action "Install".
      """


Scenario: Replay a transaction upgrading a nonexistent package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "does-not-exist-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "does-not-exist-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "does-not-exist-2.0-1.x86_64".
        Cannot find rpm nevra "does-not-exist-1.0-1.x86_64".
      """


Scenario: Replay a transaction upgrading to a nonexistent package version
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:3.0-1.x86_64",
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
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "top-a-1:3.0-1.x86_64".
      """


Scenario: Replay a transaction upgrading from a not-installed package version
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Upgrade",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-a-1:2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Package nevra "top-a-1:2.0-1.x86_64" not installed for action "Upgraded".
      """


Scenario: Replay a transaction removing a nonexistent package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "does-not-exist-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "does-not-exist-1.0-1.x86_64".
      """


Scenario: Replay a transaction removing a package that is not installed
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Removed",
                  "nevra": "top-c-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Package nevra "top-c-1.0-1.x86_64" not installed for action "Removed".
      """


Scenario: Replay a transaction that pulls in an extra package
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
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
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Package nevra "bottom-a1-2.0-1.noarch", which is not present in the transaction file, was pulled into the transaction.
      """


Scenario: Replay a transaction with a dependency conflict
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "bottom-a1-1.0-1.noarch",
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
              },
              {
                  "action": "Install",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: 
       Problem: package top-a-1:2.0-1.x86_64 from transaction-sr requires bottom-a1 = 2.0-1, but none of the providers can be installed
        - cannot install both bottom-a1-2.0-1.noarch from transaction-sr and bottom-a1-1.0-1.noarch from transaction-sr
        - conflicting requests

      """


Scenario: Replay a transaction with a broken dependency
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "broken-dep-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: 
       Problem: conflicting requests
        - nothing provides nonexistent needed by broken-dep-1.0-1.x86_64 from transaction-sr
      """


Scenario: Replay a transaction installing a nonexistent group
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Install",
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory",
                  "packages": []
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
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Group id 'nonexistent' is not available.
      """


Scenario: Replay a transaction removing a nonexistent group
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Removed",
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory",
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
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Group id 'nonexistent' is not installed.
      """


Scenario: Replay a transaction upgrading a nonexistent group
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Upgrade",
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory",
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
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Group id 'nonexistent' is not installed.
      """


Scenario: Replay a transaction upgrading an installed nonexistent group
Given I successfully execute dnf with args "install @test-group"
  And I drop repository "transaction-sr"
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "groups": [
              {
                  "action": "Upgrade",
                  "id": "test-group",
                  "package_types": "conditional, default, mandatory",
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
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Group id 'test-group' is not available.
      """


Scenario: Replay a transaction installing a nonexistent environment
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "groups": [],
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory"
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
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Environment id 'nonexistent' is not available.
      """


Scenario: Replay a transaction removing a nonexistent environment
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Removed",
                  "groups": [],
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Environment id 'nonexistent' is not installed.
      """


Scenario: Replay a transaction upgrading a nonexistent environment
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Upgrade",
                  "groups": [],
                  "id": "nonexistent",
                  "package_types": "conditional, default, mandatory"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Environment id 'nonexistent' is not installed.
      """


Scenario: Replay a transaction with multiple errors
Given I create file "/{context.dnf.tempdir}/transaction.json" with
      """
      {
          "environments": [
              {
                  "action": "Install",
                  "groups": [],
                  "id": "dummy"
              }
          ],
          "groups": [
              {
                  "action": "Upgrade"
              }
          ],
          "rpms": [
              {
                  "action": "Install",
                  "nevra": "top-a-1:3.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgrade",
                  "nevra": "top-b-2.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "transaction-sr"
              },
              {
                  "action": "Upgraded",
                  "nevra": "top-b-1.0-1.x86_64",
                  "reason": "user",
                  "repo_id": "@System"
              }
          ],
          "version": "0.0"
      }
      """
 When I execute dnf with args "history replay transaction.json"
 Then the exit code is 1
  And stderr is
      """
      Error: The following problems occurred while replaying the transaction from file "{context.dnf.tempdir}/transaction.json":
        Cannot find rpm nevra "top-a-1:3.0-1.x86_64".
        Cannot find rpm nevra "top-b-2.0-1.x86_64".
        Package nevra "top-b-1.0-1.x86_64" not installed for action "Upgraded".
        Missing object key "id" in a group.
        Missing object key "package_types" in an environment.
      """
