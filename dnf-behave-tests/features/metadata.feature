Feature: Testing DNF metadata handling


@bz1644283
Scenario: update expired metadata on first dnf update
Given I create directory "/temp-repos/temp-repo"
  And I configure a new repository "testrepo" with
      | key             | value                                          |
      | baseurl         | {context.dnf.installroot}/temp-repos/temp-repo |
      | metadata_expire | 1s                                             |
  And I execute "createrepo_c ." in "{context.dnf.installroot}/temp-repos/temp-repo"
  And I execute dnf with args "makecache"
  And I copy directory "{context.scenario.repos_location}/dnf-ci-fedora" to "/temp-repos/temp-repo/dnf-ci-fedora"
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
 #Ensure metadata are expired
  And I execute "sleep 2s"
  And I execute dnf with args "update"
 When I execute dnf with args "list all"
 Then the exit code is 0
  And stdout contains "\s+wget.src\s+1.19.5-5.fc29\s+testrepo"


@bz1866505
Scenario: I cannot create/overwrite a file in /etc from local repository
# This directory structure is needed at the repo source so that it can be matched on the system running dnf
# the path where to donwload the file ends up looking something like this:
# /var/cache/dnf/test-622efad968597580/tmpdir.2fwp3B/../../../../../etc/malicious.file -> /etc/malicious.file
Given I create file "/a/etc/malicious.file" with
      """
      my evil config
      """
  And I create file "/a/b/c/d/e/repodata/repomd.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <repomd>
          <data type="primary">
              <location href="../../../../../etc/malicious.file"/>
          </data>
      </repomd>
      """
 When I execute dnf with args "--repofrompath=test,{context.dnf.installroot}/a/b/c/d/e/ --repo test --refresh --nogpgcheck install htop"
 Then file "/etc/malicious.file" does not exist


@bz1866505
Scenario: I cannot create/overwrite a file in /etc from remote repository
Given I create file "/a/etc/malicious.file" with
      """
      my evil config
      """
  And I create file "/a/b/c/d/e/f/g/repodata/repomd.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <repomd>
          <data type="primary">
              <location href="../../../../../etc/malicious.file"/>
          </data>
      </repomd>
      """
  And I start http server "malicious_server" at "{context.dnf.installroot}/a"
  And I configure a new repository "test" with
        | key      | value                                                                                                                                                               |
        | gpgcheck | 0    |
        | baseurl  | http://0.0.0.0:{context.dnf.ports[malicious_server]}/b/c/d/e/f/g/ |
 When I execute dnf with args "--refresh install htop"
 Then file "/etc/malicious.file" does not exist


@bz1865803
Scenario: If I have up to date solv files and repomd.xml I don't need to download metadata
Given I use repository "simple-base"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base*/repodata/primary.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base*/repodata/filelists.xml.gz" with globs
 When I execute dnf with args "install labirinto -v"
 Then stdout contains "repo: using cache for: simple-base"
  And stdout does not contain "repo: downloading from remote: simple-base"
  And the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


@bz1865803
Scenario: If I have up to date solv file (missing solvx) and repomd.xml I don't need to download metadata if not using filelists
Given I use repository "simple-base"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base*/repodata/primary.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base*/repodata/filelists.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base-filenames.solvx"
 When I execute dnf with args "install labirinto -v"
 Then stdout contains "repo: using cache for: simple-base"
  And stdout does not contain "repo: downloading from remote: simple-base"
  And the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
  And file "/var/cache/dnf/simple-base-filenames.solvx" does not exist


@bz1865803
Scenario: I can use valid solvx with its repomd even if original xml filelists is missing
Given I use repository "dnf-ci-fileconflicts"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/dnf-ci-fileconflicts*/repodata/primary.xml.gz" with globs
  And I delete file "/var/cache/dnf/dnf-ci-fileconflicts*/repodata/filelists.xml.gz" with globs
 When I execute dnf with args "provides /usr/lib/FileConflict.bundled/a_dir/a_file"
 Then stdout is
      """
      <REPOSYNC>
      FileConflict-1.0-1.x86_64 : The made up package to fail on file conflict
      Repo        : dnf-ci-fileconflicts
      Matched from:
      Filename    : /usr/lib/FileConflict.bundled/a_dir/a_file
      """
  And the exit code is 0
  And file "/var/cache/dnf/dnf-ci-fileconflicts*/repodata/filelists.xml.gz" does not exist


@bz1865803
Scenario: If I have just repomd.xml I download rest of the repository
Given I use repository "simple-base"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base*/repodata/primary.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base*/repodata/filelists.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base.solv"
  And I delete file "/var/cache/dnf/simple-base-filenames.solvx"
 When I execute dnf with args "install labirinto -v"
 Then stdout does not contain "repo: using cache for: simple-base"
  And stdout contains "repo: downloading from remote: simple-base"
  And the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


@bz1865803
Scenario: If I have all the xml files I don't redownload if solv files are missing
Given I use repository "simple-base"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base.solv"
  And I delete file "/var/cache/dnf/simple-base-filenames.solvx"
 When I execute dnf with args "install labirinto -v"
 Then stdout contains "repo: using cache for: simple-base"
  And stdout does not contain "repo: downloading from remote: simple-base"
  And the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
  And file "/var/cache/dnf/simple-base.solv" exists
  And file "/var/cache/dnf/simple-base-filenames.solvx" exists


Scenario: --refresh updates changed metadata even if only solv files and repomd are present
Given I create directory "/repo"
  And I execute "createrepo_c --simple-md-filenames ." in "{context.dnf.installroot}/repo"
  And I configure a new repository "testrepo" with
      | key             | value                                          |
      | baseurl         | {context.dnf.installroot}/repo |
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/testrepo*/repodata/filelists.xml.gz" with globs
  And I delete file "/var/cache/dnf/testrepo*/repodata/primary.xml.gz" with globs
  And I copy directory "{context.scenario.repos_location}/simple-base" to "/repo/simple-base"
  And I execute "createrepo_c --update --simple-md-filenames ." in "{context.dnf.installroot}/repo"
 When I execute dnf with args "install labirinto --refresh"
 Then the exit code is 0
  And file "/var/cache/dnf/testrepo*/repodata/primary.xml.gz" exists
  And file "/var/cache/dnf/testrepo*/repodata/filelists.xml.gz" exists
  And file "/var/cache/dnf/testrepo.solv" exists
  And file "/var/cache/dnf/testrepo-filenames.solvx" exists


@bz1865803
Scenario: If I have up to date solv files and repomd.xml --refresh redownloads only repomd
Given I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base*/repodata/primary.xml.gz" with globs
  And I delete file "/var/cache/dnf/simple-base*/repodata/filelists.xml.gz" with globs
  And I start capturing outbound HTTP requests
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And HTTP log is
      """
      GET /repodata/repomd.xml
      """


# The problem here is that we don't know if the filelists will be needed so we don't
# know when to download them. Downloading them on every unssucessfull dependency
# resolution is really bad even though it could help in some cases.
# See for more info: https://bugzilla.redhat.com/show_bug.cgi?id=1619368#c3
@xfail
@bz1865803
Scenario: If I have up to date solv file (missing solvx) and repomd.xml I download metadata if using filelists
Given I use repository "dnf-ci-fileconflicts"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/dnf-ci-fileconflicts*/repodata/filelists.xml.gz" with globs
  And I delete file "/var/cache/dnf/dnf-ci-fileconflicts-filenames.solvx"
 When I execute dnf with args "provides /usr/lib/FileConflict.bundled/a_dir/a_file"
 Then stdout is
      """
      <REPOSYNC>
      FileConflict-1.0-1.x86_64 : The made up package to fail on file conflict
      Repo        : dnf-ci-fileconflicts
      Matched from:
      Filename    : /usr/lib/FileConflict.bundled/a_dir/a_file
      """
  And the exit code is 0
  And file "/var/cache/dnf/dnf-ci-fileconflicts*/repodata/filelists.xml.gz" exists
  And file "/var/cache/dnf/dnf-ci-fileconflicts-filenames.solvx" exists


# If the download repomd checksum wouldn't match with present solv files we would
# have to download the repository again including the repomd (for the second time
# in a row) because librepo doesn't support passing in already local repomd.
# This would require rather big change in librepo.
@xfail
@bz1865803
Scenario: If I have up to date solv files I download just repomd
Given I use repository "simple-base"
  And I execute dnf with args "makecache"
  And I delete file "/var/cache/dnf/simple-base*/repodata/*" with globs
 When I execute dnf with args "install labirinto -v"
 Then the exit code is 0
  And file "/var/cache/dnf/simple-base*/repodata/repomd.xml" exists
  And file "/var/cache/dnf/simple-base*/repodata/primary.xml.gz" does not exist
  And file "/var/cache/dnf/simple-base*/repodata/filelists.xml.gz" does not exist
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
