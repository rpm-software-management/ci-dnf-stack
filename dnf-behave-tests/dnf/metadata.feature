Feature: Testing DNF metadata handling


@bz1644283
Scenario: update expired metadata on first dnf run
Given I create directory "temp-repo"
  And I configure a new repository "testrepo" with
      | key             | value                               |
      | baseurl         | {context.dnf.installroot}/temp-repo |
      | metadata_expire | 0s                                  |
  And I execute "createrepo_c ." in "{context.dnf.installroot}/temp-repo"
  And I execute dnf with args "makecache"
  And I copy file "{context.scenario.repos_location}/simple-base/x86_64/labirinto-1.0-1.fc29.x86_64.rpm" to "/temp-repo/"
  # Ensure metadata are expired
  And I execute "sleep 1s"
  And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repo"
 When I execute dnf with args "repoquery --all"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      labirinto-0:1.0-1.fc29.x86_64
      """


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
        | key      | value                                                             |
        | gpgcheck | 0                                                                 |
        | baseurl  | http://0.0.0.0:{context.dnf.ports[malicious_server]}/b/c/d/e/f/g/ |
 When I execute dnf with args "--refresh install htop"
 Then file "/etc/malicious.file" does not exist


@bz1855296
Scenario: identical repository, we don't have to download repomd.xml since we set If-Modified-Since http header
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  And I start capturing outbound HTTP requests
  And I set config option "logfilelevel" to "10"
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  Then file "/var/log/dnf.librepo.log" contains lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      """


Scenario: touched repomd (new timestamps) is downloaded but checksums match -> no repo redownload
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  And I start capturing outbound HTTP requests
  And I set config option "logfilelevel" to "10"
  And I execute "sleep 1s"
  And I execute "touch {context.dnf.repos[simple-base].path}/repodata/repomd.xml"
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  Then file "/var/log/dnf.librepo.log" does not contain lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      """


Scenario: identical metalink checksums match, no repo redownload needed (If-Modified-Since doesn't work with metalink)
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  And I execute dnf with args "makecache"
  And I start capturing outbound HTTP requests
  And I set config option "logfilelevel" to "10"
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  Then file "/var/log/dnf.librepo.log" does not contain lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  And HTTP log is
      """
      GET simple-base /metalink.xml
      """


Scenario: regenerated metalink checksums match, no repo redownload needed (If-Modified-Since doesn't work with metalink)
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  And I execute dnf with args "makecache"
  # We need to run this step so that we can generate the metalink again
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  And I start capturing outbound HTTP requests
  And I set config option "logfilelevel" to "10"
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  Then file "/var/log/dnf.librepo.log" does not contain lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  And HTTP log is
      """
      GET simple-base /metalink.xml
      """


Scenario: regenerated repomd timestamps cause whole repo redownload
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  # we have to wait 1s otherwise the repomd will be regenerated at the same time its
  # previous version was downloaded and since we use If-Modified-Since it won't be
  # redownloaded
  And I execute "sleep 1s"
  And I generate repodata for repository "simple-base"
  And I start capturing outbound HTTP requests
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  # repomd.xml is downloaded twice, first time to check if we have up to date metadata
  # and second time to download the whole repo (we could also optimize this to download it
  # only once)
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/primary.xml.gz
      GET simple-base /repodata/filelists.xml.gz
      """


Scenario: updated metalink with updated metadata cause the whole repo to redownload
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  And I execute dnf with args "makecache"
  And I generate repodata for repository "simple-base" with extra arguments "--baseurl update-metadata"
  # We need to run this step so that we can regenerate the metalink
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  And I start capturing outbound HTTP requests
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  # metalink.xml is downloaded twice, first to check if we have up to date metadata
  # and because we don't the whole repo is redownloaded.
  # (librepo doesn't support passing in already downloaded metalink.xml)
  And HTTP log is
      """
      GET simple-base /metalink.xml
      GET simple-base /metalink.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/primary.xml.gz
      GET simple-base /repodata/filelists.xml.gz
      """


Scenario: updated repomd with set revision timestamps doesn't cause redownload (because its identical)
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I generate repodata for repository "simple-base" with extra arguments "--revision 1 --set-timestamp-to-revision"
  And I execute dnf with args "makecache"
  # we have to wait 1s otherwise the repomd will be regenerated at the same time its
  # previous version was downloaded and since we use If-Modified-Since it won't be
  # redownloaded
  And I execute "sleep 1s"
  And I generate repodata for repository "simple-base" with extra arguments "--revision 1 --set-timestamp-to-revision"
  And I start capturing outbound HTTP requests
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 0
  And stderr is empty
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      """


@bz1855296
Scenario: identical repository with expired metadata, we do a GET request but no redownload because of If-Modified-Since
Given I copy repository "simple-base" for modification
  And I configure repository "simple-base" with
      | key             | value     |
      | metadata_expire | 0s        |
  And I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  And I start capturing outbound HTTP requests
  And I execute "sleep 1s"
  And I set config option "logfilelevel" to "10"
 When I execute dnf with args "repoquery"
 Then the exit code is 0
  Then file "/var/log/dnf.librepo.log" contains lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      """


Scenario: updated repository with expired metadata, repo is redownloaded
Given I copy repository "simple-base" for modification
  And I configure repository "simple-base" with
      | key             | value                                          |
      | metadata_expire | 0s                                             |
  And I use repository "simple-base" as http
  And I execute dnf with args "makecache"
  And I execute "sleep 1s"
  And I generate repodata for repository "simple-base"
  And I start capturing outbound HTTP requests
 When I execute dnf with args "repoquery"
 Then the exit code is 0
  Then file "/var/log/dnf.librepo.log" does not contain lines
      """
      lr_yum_download_repomd: repomd.xml on the server was not modified since.*
      """
  # repomd.xml is downloaded twice, first time to check if we have up to date metadata
  # and second time to download the whole repo (we could also optimize this to download it
  # only once)
  And HTTP log is
      """
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/primary.xml.gz
      GET simple-base /repodata/filelists.xml.gz
      """


Scenario: checksum from metalink is verified agains downloaded repomd.xml checksum, fail if they don't match
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I set up metalink for repository "simple-base"
  # Change repomd.xml from simple-base repo so that it doesn't match with metalink checksum
  And I generate repodata for repository "simple-base" with extra arguments "--baseurl update-metadata"
  And I start capturing outbound HTTP requests
 When I execute dnf with args "makecache --refresh"
 Then the exit code is 1
  And stderr matches line by line
  """
  Errors during downloading metadata for repository 'simple-base':
    - Downloading successful, but checksum doesn't match. Calculated: .*
  Error: Failed to download metadata for repo 'simple-base': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
  """
  And HTTP log is
      """
      GET simple-base /metalink.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/repomd.xml
      GET simple-base /repodata/repomd.xml
      """
