Feature: Download commands with options --resolve --alldeps

Background:
  Given I use repository "dnf-ci-fedora"

@not.with_dnf=4
@dnf5
Scenario: Download a single rpm
  Given I set working directory to "{context.dnf.tempdir}"
   When I execute dnf with args "download abcde"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.src.rpm" exists
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.noarch.rpm" exists


@not.with_dnf=4
@dnf5
Scenario: Download with resolve option when no package is installed
  Given I set working directory to "{context.dnf.tempdir}"
   When I execute dnf with args "download abcde --resolve"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.src.rpm" exists
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.noarch.rpm" exists
    And file "/{context.dnf.tempdir}/flac-1.3.2-8.fc29.x86_64.rpm" exists
    And file "/{context.dnf.tempdir}/wget-1.19.5-5.fc29.x86_64.rpm" exists


@not.with_dnf=4
@dnf5
Scenario: Download with resolve option when a dependency is installed
  Given I set working directory to "{context.dnf.tempdir}"
    And I successfully execute dnf with args "install wget"
   When I execute dnf with args "download abcde --resolve"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.src.rpm" exists
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.noarch.rpm" exists
    And file "/{context.dnf.tempdir}/flac-1.3.2-8.fc29.x86_64.rpm" exists
    And file "/{context.dnf.tempdir}/wget-1.19.5-5.fc29.x86_64.rpm" does not exist


@not.with_dnf=4
@dnf5
Scenario: Download with resolve and alldeps options
  Given I set working directory to "{context.dnf.tempdir}"
    And I successfully execute dnf with args "install wget"
   When I execute dnf with args "download abcde --resolve --alldeps"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.src.rpm" exists
    And file "/{context.dnf.tempdir}/abcde-2.9.2-1.fc29.noarch.rpm" exists
    And file "/{context.dnf.tempdir}/flac-1.3.2-8.fc29.x86_64.rpm" exists
    And file "/{context.dnf.tempdir}/wget-1.19.5-5.fc29.x86_64.rpm" exists

@not.with_dnf=4
@dnf5
Scenario: Download with alldeps options
  Given I set working directory to "{context.dnf.tempdir}"
   When I execute dnf with args "download abcde --alldeps"
   Then stderr contains "Option \"--alldeps\" should be used with \"--resolve\""
    And the exit code is 2

@not.with_dnf=4
@dnf5
Scenario: Download when package is available from multiple repositories
  Given I use repository "dnf-ci-fedora-updates"
  Given I set working directory to "{context.dnf.tempdir}"
   When I execute dnf with args "download abcde --resolve"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/abcde-2.9.3-1.fc29.src.rpm" exists
    And file "/{context.dnf.tempdir}/abcde-2.9.3-1.fc29.noarch.rpm" exists
    And file "/{context.dnf.tempdir}/flac-1.3.3-3.fc29.x86_64.rpm" exists
    And file "/{context.dnf.tempdir}/wget-1.19.6-5.fc29.x86_64.rpm" exists
