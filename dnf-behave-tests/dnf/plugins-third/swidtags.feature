# the swidtags plugin is available only in Fedora
@use.with_os=fedora__ge__30
Feature: Smoke test for swidtags dnf plugin


@bz1689178
Scenario: Run swidtags without command prints usage
   When I execute dnf with args "swidtags"
   Then the exit code is 2
    And stderr is
    """
    usage: dnf swidtags [-c [config file]] [-q] [-v] [--version]
                        [--installroot [path]] [--nodocs] [--noplugins]
                        [--enableplugin [plugin]] [--disableplugin [plugin]]
                        [--releasever RELEASEVER] [--setopt SETOPTS]
                        [--skip-broken] [-h] [--allowerasing] [-b | --nobest] [-C]
                        [-R [minutes]] [-d [debug level]] [--debugsolver]
                        [--showduplicates] [-e ERRORLEVEL] [--obsoletes]
                        [--rpmverbosity [debug level name]] [-y] [--assumeno]
                        [--enablerepo [repo]] [--disablerepo [repo] | --repo
                        [repo]] [--enable | --disable] [-x [package]]
                        [--disableexcludes [repo]] [--repofrompath [repo,path]]
                        [--noautoremove] [--nogpgcheck] [--color COLOR]
                        [--refresh] [-4] [-6] [--destdir DESTDIR] [--downloadonly]
                        [--comment COMMENT] [--bugfix] [--enhancement]
                        [--newpackage] [--security] [--advisory ADVISORY]
                        [--bz BUGZILLA] [--cve CVES]
                        [--sec-severity {{Critical,Important,Moderate,Low}}]
                        [--forcearch ARCH]
                        {{sync,regen,purge}}
    dnf swidtags: error: the following arguments are required: swidtagscmd
    """


@bz1689178
Scenario: SWID tags are locally generated
  Given I use repository "dnf-ci-fedora"
    # enable locally generated SWID tags
  Given I configure dnf with
        | key            | value                                         |
        | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins     |
    And I create and substitute file "/etc/dnf/plugins/swidtags.conf" with
      """
      [main]
      enabled = 1
      rpm2swidtag_command = /usr/bin/rpm2swidtag
      """
    # make sure there are no swid tags
    And I delete directory "/var/lib/swidtag"
    # passive part of swidtags plugin generates tags after transaction
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And file "/var/lib/swidtag/rpm2swidtag-generated/*.setup-2.12.1-1.fc29.noarch-*.swidtag" exists
  Given I delete directory "/var/lib/swidtag"
    # swidtags regen regenerates the tags
   When I execute dnf with args "swidtags regen"
   Then the exit code is 0
    And file "/var/lib/swidtag/rpm2swidtag-generated/*.setup-2.12.1-1.fc29.noarch-*.swidtag" exists
