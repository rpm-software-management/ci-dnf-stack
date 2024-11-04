Feature: Tests for the manifest plugin


Background:
  Given I enable plugin "manifest"
  And I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install basesystem glibc flac"
  And I set working directory to "{context.dnf.tempdir}"


Scenario: Generate new manifest using specs
   When I execute dnf with args "manifest new abcde http-parser"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/packages.manifest.yaml" matches line by line
    """
    document: rpm-package-manifest
    version: *
    data:
      repositories:
        - id: dnf-ci-fedora
          baseurl: file:///root/dbox/ci-dnf-stack/dnf-behave-tests/fixtures/repos/dnf-ci-fedora/
      packages:
        noarch:
          - name: abcde
            repo_id: dnf-ci-fedora
            location: noarch/abcde-2.9.2-1.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6446
            evr: 2.9.2-1.fc29
        x86_64:
          - name: wget
            repo_id: dnf-ci-fedora
            location: x86_64/wget-1.19.5-5.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: 6710
            evr: 1.19.5-5.fc29
          - name: flac
            repo_id: dnf-ci-fedora
            location: x86_64/flac-1.3.2-8.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: 6658
            evr: 1.3.2-8.fc29
          - name: http-parser
            repo_id: dnf-ci-fedora
            location: x86_64/http-parser-2.4.0-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6254
            evr: 2.4.0-1.fc29
    """

Scenario: Generate new manifest using specs and system repo
   When I execute dnf with args "manifest new abcde http-parser --use-system"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/packages.manifest.yaml" matches line by line
    """
    document: rpm-package-manifest
    version: *
    data:
      repositories:
        - id: dnf-ci-fedora
          baseurl: file:///root/dbox/ci-dnf-stack/dnf-behave-tests/fixtures/repos/dnf-ci-fedora/
      packages:
        noarch:
          - name: abcde
            repo_id: dnf-ci-fedora
            location: noarch/abcde-2.9.2-1.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6446
            evr: 2.9.2-1.fc29
        x86_64:
          - name: http-parser
            repo_id: dnf-ci-fedora
            location: x86_64/http-parser-2.4.0-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6254
            evr: 2.4.0-1.fc29
          - name: wget
            repo_id: dnf-ci-fedora
            location: x86_64/wget-1.19.5-5.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: 6710
            evr: 1.19.5-5.fc29
    """

Scenario: Generate new manifest using prototype input file
  Given I copy file "{context.dnf.fixturesdir}/data/manifest/rpms.in.yaml" to "/{context.dnf.tempdir}"
   When I execute dnf with args "manifest new"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/packages.manifest.yaml" matches line by line
    """
    document: rpm-package-manifest
    version: *
    data:
      repositories:
        - id: dnf-ci-fedora
          baseurl: file:///root/dbox/ci-dnf-stack/dnf-behave-tests/fixtures/repos/dnf-ci-fedora/
      packages:
        noarch:
          - name: basesystem
            repo_id: dnf-ci-fedora
            location: noarch/basesystem-11-6.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6454
            evr: 11-6.fc29
          - name: setup
            repo_id: dnf-ci-fedora
            location: noarch/setup-2.12.1-1.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6470
            evr: 2.12.1-1.fc29
        x86_64:
          - name: wget
            repo_id: dnf-ci-fedora
            location: x86_64/wget-1.19.5-5.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: 6710
            evr: 1.19.5-5.fc29
          - name: nodejs
            repo_id: dnf-ci-fedora
            location: x86_64/nodejs-5.12.1-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6934
            evr: 1:5.12.1-1.fc29
          - name: npm
            repo_id: dnf-ci-fedora
            location: x86_64/npm-5.12.1-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6550
            evr: 1:5.12.1-1.fc29
          - name: dwm
            repo_id: dnf-ci-fedora
            location: x86_64/dwm-6.1-1.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6590
            evr: 6.1-1
          - name: filesystem
            repo_id: dnf-ci-fedora
            location: x86_64/filesystem-3.9-2.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6522
            evr: 3.9-2.fc29
          - name: glibc
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-2.28-9.fc29.x86_64.rpm
            checksum: sha256:3145fd316b27f704b8d105cffe22f6d81f219b980b9d8e797a648810535501ee
            size: 10963
            evr: 2.28-9.fc29
          - name: glibc-all-langpacks
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-all-langpacks-2.28-9.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6570
            evr: 2.28-9.fc29
          - name: glibc-common
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-common-2.28-9.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6666
            evr: 2.28-9.fc29
    """

Scenario: Generate new manifest using prototype input file and system repo
  Given I copy file "{context.dnf.fixturesdir}/data/manifest/rpms.in.yaml" to "/{context.dnf.tempdir}"
   When I execute dnf with args "manifest new --use-system"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/packages.manifest.yaml" matches line by line
    """
    document: rpm-package-manifest
    version: *
    data:
      repositories:
        - id: dnf-ci-fedora
          baseurl: file:///root/dbox/ci-dnf-stack/dnf-behave-tests/fixtures/repos/dnf-ci-fedora/
      packages:
        x86_64:
          - name: dwm
            repo_id: dnf-ci-fedora
            location: x86_64/dwm-6.1-1.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6590
            evr: 6.1-1
          - name: npm
            repo_id: dnf-ci-fedora
            location: x86_64/npm-5.12.1-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6550
            evr: 1:5.12.1-1.fc29
          - name: nodejs
            repo_id: dnf-ci-fedora
            location: x86_64/nodejs-5.12.1-1.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: 6934
            evr: 1:5.12.1-1.fc29
          - name: wget
            repo_id: dnf-ci-fedora
            location: x86_64/wget-1.19.5-5.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: 6710
            evr: 1.19.5-5.fc29
    """

Scenario: Generate new manifest using installed packages
   When I execute dnf with args "manifest new"
   Then the exit code is 0
    And file "/{context.dnf.tempdir}/packages.manifest.yaml" matches line by line
    """
    document: rpm-package-manifest
    version: *
    data:
      repositories:
        - id: dnf-ci-fedora
          baseurl: file:///root/dbox/ci-dnf-stack/dnf-behave-tests/fixtures/repos/dnf-ci-fedora/
      packages:
        noarch:
          - name: basesystem
            repo_id: dnf-ci-fedora
            location: noarch/basesystem-11-6.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: *
            evr: 11-6.fc29
          - name: setup
            repo_id: dnf-ci-fedora
            location: noarch/setup-2.12.1-1.fc29.noarch.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: *
            evr: 2.12.1-1.fc29
        x86_64:
          - name: filesystem
            repo_id: dnf-ci-fedora
            location: x86_64/filesystem-3.9-2.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: *
            evr: 3.9-2.fc29
          - name: flac
            repo_id: dnf-ci-fedora
            location: x86_64/flac-1.3.2-8.fc29.x86_64.rpm
            checksum: sha256:a9be35c299c47550d1a75e6587c2619b68e16465158a2e02bb0cb5a3e216be7b
            size: *
            evr: 1.3.2-8.fc29
          - name: glibc
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-2.28-9.fc29.x86_64.rpm
            checksum: sha256:3145fd316b27f704b8d105cffe22f6d81f219b980b9d8e797a648810535501ee
            size: *
            evr: 2.28-9.fc29
          - name: glibc-all-langpacks
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-all-langpacks-2.28-9.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: *
            evr: 2.28-9.fc29
          - name: glibc-common
            repo_id: dnf-ci-fedora
            location: x86_64/glibc-common-2.28-9.fc29.x86_64.rpm
            checksum: sha256:52784b80f998d0b3a6f0bd42e1e2e78416ff59e5c045b366949248249c222627
            size: *
            evr: 2.28-9.fc29
    """

Scenario: Download packages from the manifest
  Given I successfully execute dnf with args "manifest new abcde http-parser"
   When I execute dnf with args "manifest download"
   Then the exit code is 0
    And file sha256 checksums are following
        | Path                                                                        | sha256                                                                                          |
        | {context.dnf.tempdir}/packages.manifest/abcde-2.9.2-1.fc29.noarch.rpm       | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/abcde-2.9.2-1.fc29.noarch.rpm       |
        | {context.dnf.tempdir}/packages.manifest/flac-1.3.2-8.fc29.x86_64.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/flac-1.3.2-8.fc29.x86_64.rpm        |
        | {context.dnf.tempdir}/packages.manifest/http-parser-2.4.0-1.fc29.x86_64.rpm | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/http-parser-2.4.0-1.fc29.x86_64.rpm |
        | {context.dnf.tempdir}/packages.manifest/wget-1.19.5-5.fc29.x86_64.rpm       | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/wget-1.19.5-5.fc29.x86_64.rpm       |

Scenario: Install packages from the manifest
  Given I successfully execute dnf with args "manifest new abcde http-parser"
   When I execute dnf with args "manifest install"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | abcde-0:2.9.2-1.fc29.noarch       |
        | install       | http-parser-0:2.4.0-1.fc29.x86_64 |
        | install       | wget-0:1.19.5-5.fc29.x86_64       |
