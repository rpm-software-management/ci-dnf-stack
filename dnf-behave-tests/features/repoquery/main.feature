Feature: The common repoquery tests, core functionality, odds and ends.

Background:
 Given I use the repository "repoquery-main"


# simple nevra matching tests
Scenario: repoquery (no arguments, i.e. list all packages)
 When I execute dnf with args "repoquery"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      bottom-a2-1:1.0-1.src
      bottom-a2-1:1.0-1.x86_64
      bottom-a3-1:1.0-1.src
      bottom-a3-1:1.0-1.x86_64
      bottom-a3-1:2.0-1.src
      bottom-a3-1:2.0-1.x86_64
      broken-deps-1:1.0-1.src
      broken-deps-1:1.0-1.x86_64
      mid-a1-1:1.0-1.src
      mid-a1-1:1.0-1.x86_64
      mid-a2-1:1.0-1.src
      mid-a2-1:1.0-1.x86_64
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME (nonexisting package)
 When I execute dnf with args "repoquery dummy"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery NAME
 When I execute dnf with args "repoquery top-a"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION
 When I execute dnf with args "repoquery top-a-2.0"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION-RELEASE
 When I execute dnf with args "repoquery top-a-2.0-2"
 Then the exit code is 0
  And stdout is
      """
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-EPOCH:VERSION-RELEASE
 When I execute dnf with args "repoquery top-a-2:2.0-2"
 Then the exit code is 0
  And stdout is
      """
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-EPOCH:VERSION-RELEASE old epoch
 When I execute dnf with args "repoquery top-a-1:2.0-2"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery NAME NAME-EPOCH:VERSION-RELEASE
 When I execute dnf with args "repoquery bottom-a1 top-a-2:2.0-2"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: repoquery NAME-VERSION NAME-EPOCH:VERSION_GLOB-RELEASE
 When I execute dnf with args "repoquery bottom-a1-1.0 top-a-1:[12].0-1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      """

@xfail
@bz1735687
Scenario: repoquery NAME-VERSION NAME-EPOCH:VERSION_GLOB2-RELEASE
 When I execute dnf with args "repoquery bottom-a1-1.0 top-a-1:[1-2].0-1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      """


# --all: compatibility option, basically does nothing
Scenario: dnf repoquery --all
 When I execute dnf with args "repoquery"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      bottom-a2-1:1.0-1.src
      bottom-a2-1:1.0-1.x86_64
      bottom-a3-1:1.0-1.src
      bottom-a3-1:1.0-1.x86_64
      bottom-a3-1:2.0-1.src
      bottom-a3-1:2.0-1.x86_64
      broken-deps-1:1.0-1.src
      broken-deps-1:1.0-1.x86_64
      mid-a1-1:1.0-1.src
      mid-a1-1:1.0-1.x86_64
      mid-a2-1:1.0-1.src
      mid-a2-1:1.0-1.x86_64
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """

Scenario: dnf repoquery --all NAME (illogical combination, --all is a compatibility noop)
 When I execute dnf with args "repoquery --all top-a"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:1.0-1.src
      top-a-1:1.0-1.x86_64
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """


# --available is the default, scenarios above should cover it
Scenario: dnf repoquery --available NAME
 When I execute dnf with args "repoquery --available top-a-2.0"
 Then the exit code is 0
  And stdout is
      """
      top-a-1:2.0-1.src
      top-a-1:2.0-1.x86_64
      top-a-2:2.0-2.src
      top-a-2:2.0-2.x86_64
      """


# --arch
Scenario: repoquery --arch ARCH
 When I execute dnf with args "repoquery --arch noarch"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.noarch
      bottom-a1-1:2.0-1.noarch
      """

Scenario: repoquery --arch ARCH (nonexisting arch)
 When I execute dnf with args "repoquery --arch yesarch"
 Then the exit code is 0
  And stdout is empty


# --deplist
Scenario: repoquery --deplist NAME
 When I execute dnf with args "repoquery --deplist top-a"
 Then the exit code is 0
  And stdout is
      """
      package: top-a-1:1.0-1.src

      package: top-a-1:1.0-1.x86_64
        dependency: bottom-a1 = 1:1.0-1
         provider: bottom-a1-1:1.0-1.noarch
        dependency: mid-a1 >= 2
         provider: mid-a1-1:1.0-1.x86_64
        dependency: mid-a2 = 1:1.0-1
         provider: mid-a2-1:1.0-1.x86_64

      package: top-a-1:2.0-1.src

      package: top-a-1:2.0-1.x86_64
        dependency: bottom-a1 = 1:1.0-1
         provider: bottom-a1-1:1.0-1.noarch
        dependency: mid-a1 >= 2
         provider: mid-a1-1:1.0-1.x86_64
        dependency: mid-a2 = 1:1.0-1
         provider: mid-a2-1:1.0-1.x86_64

      package: top-a-2:2.0-2.src

      package: top-a-2:2.0-2.x86_64
        dependency: bottom-a1 = 1:1.0-1
         provider: bottom-a1-1:1.0-1.noarch
        dependency: mid-a1 >= 2
         provider: mid-a1-1:1.0-1.x86_64
      """

Scenario: repoquery --deplist NAME (no such package)
 When I execute dnf with args "repoquery --deplist dummy"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery --deplist --latest-limit
 When I execute dnf with args "repoquery --deplist --latest-limit 1 top-a"
 Then the exit code is 0
  And stdout is
      """
      package: top-a-2:2.0-2.src

      package: top-a-2:2.0-2.x86_64
        dependency: bottom-a1 = 1:1.0-1
         provider: bottom-a1-1:1.0-1.noarch
        dependency: mid-a1 >= 2
         provider: mid-a1-1:1.0-1.x86_64
      """

Scenario: deplist --latest-limit (deplist is an alias for repoquery --deplist)
 When I execute dnf with args "deplist --latest-limit 1 top-a"
 Then the exit code is 0
  And stdout is
      """
      package: top-a-2:2.0-2.src

      package: top-a-2:2.0-2.x86_64
        dependency: bottom-a1 = 1:1.0-1
         provider: bottom-a1-1:1.0-1.noarch
        dependency: mid-a1 >= 2
         provider: mid-a1-1:1.0-1.x86_64
      """


# --extras: installed pkgs, not from known repos
Scenario: repoquery --extras
Given I successfully execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/miscellaneous/x86_64/dummy-1.0-1.x86_64.rpm"
 When I execute dnf with args "repoquery --extras"
 Then the exit code is 0
  And stdout is
      """
      dummy-1:1.0-1.x86_64
      """

Scenario: repoquery --extras (no such packages)
 When I execute dnf with args "repoquery --extras"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery --extras NAME (package is installed)
Given I successfully execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/miscellaneous/x86_64/dummy-1.0-1.x86_64.rpm"
Given I successfully execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/miscellaneous/x86_64/weird-1.0-1.x86_64.rpm"
 When I execute dnf with args "repoquery --extras dummy"
 Then the exit code is 0
  And stdout is
      """
      dummy-1:1.0-1.x86_64
      """

Scenario: repoquery --extras NAME (package is not installed)
 When I execute dnf with args "repoquery --extras dummy"
 Then the exit code is 0
  And stdout is empty


# --installed: list only installed packages
Scenario: repoquery --installed
Given I successfully execute dnf with args "install bottom-a1"
 When I execute dnf with args "repoquery --installed"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:2.0-1.noarch
      """

Scenario: repoquery --installed (no such packages)
 When I execute dnf with args "repoquery --installed"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery --installed NAME
Given I successfully execute dnf with args "install bottom-a1 bottom-a2"
 When I execute dnf with args "repoquery --installed bottom-a1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:2.0-1.noarch
      """

Scenario: repoquery --installed NAME (no such packages)
 When I execute dnf with args "repoquery --installed bottom-a1"
 Then the exit code is 0
  And stdout is empty


# --location
@bz1639827
Scenario: repoquery --location NAME
 When I execute dnf with args "repoquery --location top-a-2.0"
 Then the exit code is 0
  And stdout matches line by line
      """
      .+/fixtures/repos/repoquery-main/src/top-a-2.0-1.src.rpm$
      .+/fixtures/repos/repoquery-main/src/top-a-2.0-2.src.rpm$
      .+/fixtures/repos/repoquery-main/x86_64/top-a-2.0-1.x86_64.rpm$
      .+/fixtures/repos/repoquery-main/x86_64/top-a-2.0-2.x86_64.rpm$
      """

@fixture.httpd
Scenario: repoquery --location NAME (in an HTTP repo)
Given I use the https repository based on "repoquery-main"
  And I disable the repository "repoquery-main"
 When I execute dnf with args "repoquery --location top-a-2.0"
 Then the exit code is 0
  And stdout matches line by line
      """
      https://localhost:[0-9]+/repoquery-main/src/top-a-2.0-1.src.rpm$
      https://localhost:[0-9]+/repoquery-main/src/top-a-2.0-2.src.rpm$
      https://localhost:[0-9]+/repoquery-main/x86_64/top-a-2.0-1.x86_64.rpm$
      https://localhost:[0-9]+/repoquery-main/x86_64/top-a-2.0-2.x86_64.rpm$
      """

Scenario: repoquery --location NAME (no such package)
 When I execute dnf with args "repoquery --location dummy"
 Then the exit code is 0
  And stdout is empty


# --srpm
Scenario: repoquery --srpm
 When I execute dnf with args "repoquery --srpm"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.src
      bottom-a2-1:1.0-1.src
      bottom-a3-1:1.0-1.src
      bottom-a3-1:2.0-1.src
      broken-deps-1:1.0-1.src
      mid-a1-1:1.0-1.src
      mid-a2-1:1.0-1.src
      top-a-1:1.0-1.src
      top-a-1:2.0-1.src
      top-a-2:2.0-2.src
      """

Scenario: repoquery --srpm NAME
 When I execute dnf with args "repoquery --srpm bottom-a1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:1.0-1.src
      bottom-a1-1:2.0-1.src
      """


# --unneeded
Scenario: repoquery --unneeded
Given I successfully execute dnf with args "install top-a-1.0"
Given I successfully execute dnf with args "upgrade top-a"
 When I execute dnf with args "repoquery --unneeded"
 Then the exit code is 0
  And stdout is
      """
      bottom-a3-1:1.0-1.x86_64
      mid-a2-1:1.0-1.x86_64
      """


# --unsatisfied
Scenario: repoquery --unsatisfied
Given I successfully execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/repoquery-main/x86_64/broken-deps-1.0-1.x86_64.rpm"
 When I execute dnf with args "repoquery --unsatisfied"
 Then the exit code is 0
  And stdout is
      """
      Problem: problem with installed package broken-deps-1:1.0-1.x86_64
        - nothing provides broken-dep-1 needed by broken-deps-1:1.0-1.x86_64
        - nothing provides broken-dep-2 >= 2.0 needed by broken-deps-1:1.0-1.x86_64
      """


# --upgrades: lists packages that upgrade installed packages
Scenario: repoquery --upgrades
Given I successfully execute dnf with args "install bottom-a1-1.0"
 When I execute dnf with args "repoquery --upgrades"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      """

Scenario: repoquery --upgrades (no such packages)
Given I successfully execute dnf with args "install bottom-a2-1.0"
 When I execute dnf with args "repoquery --upgrades"
 Then the exit code is 0
  And stdout is empty

Scenario: repoquery --upgrades NAME
Given I successfully execute dnf with args "install bottom-a1-1.0 bottom-a3-1.0"
 When I execute dnf with args "repoquery --upgrades bottom-a1"
 Then the exit code is 0
  And stdout is
      """
      bottom-a1-1:2.0-1.noarch
      bottom-a1-1:2.0-1.src
      """

Scenario: repoquery --upgrades NAME (no such packages)
Given I successfully execute dnf with args "install bottom-a1-1.0 bottom-a2-1.0"
 When I execute dnf with args "repoquery --upgrades bottom-a2"
 Then the exit code is 0
  And stdout is empty


# --userinstalled
Scenario: repoquery --userinstalled
Given I successfully execute dnf with args "install top-a"
 When I execute dnf with args "repoquery --userinstalled"
 Then the exit code is 0
  And stdout is
      """
      top-a-2:2.0-2.x86_64
      """

# --querytags
@not.with_os=rhel__eq__8
@bz1744073
Scenario: dnf repoquery --querytags
 When I execute dnf with args "repoquery --querytags"
 Then the exit code is 0
  And stdout is
      """
      Available query-tags: use --queryformat ".. %{tag} .."

      name, arch, epoch, version, release, reponame (repoid), evr,
      debug_name, source_name, source_debug_name,
      installtime, buildtime, size, downloadsize, installsize,
      provides, requires, obsoletes, conflicts, sourcerpm,
      description, summary, license, url, reason
      """
