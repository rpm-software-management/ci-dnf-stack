# The test relies on librepo ability to set extended file attributes on
# downloaded files. Although xattrs are supported on tmpfs which is usual /tmp
# filesystem where the installroots live, the user attributes are not permitted
# (see tmpfs(5), xattr(7)). That said the packages have to be downloaded out of
# the /tmp.
@no_installroot
Feature: Reposync does not re-download the package


Background: Enable reposync plugin
Given I enable plugin "reposync"


@bz1931904
Scenario: Different checksum type does not cause package re-download
Given I copy repository "simple-base" for modification
  # original with SHA256 checksum
  And I copy directory "{context.dnf.tempdir}/repos/simple-base" to "/repos/simple-base-sha256"
  And I configure a new repository "simple-base-sha256" with
        | key             | value                               |
        | baseurl         | file:///repos/simple-base-sha256    |
  # the copy with sha-1 regenerated repodata
  And I generate repodata for repository "simple-base" with extra arguments "--checksum sha512"
  And I use repository "simple-base" as http
 When I execute dnf with args "reposync --repoid=simple-base-sha256 --norepopath --download-path=/synced"
 Then the exit code is 0
 When I execute dnf with args "reposync --repoid=simple-base --norepopath --download-path=/synced"
 Then the exit code is 0
  # the package was not re-downloaded
  And stdout contains "\[SKIPPED\] labirinto-1\.0-1\.fc29\.x86_64\.rpm: Already downloaded"
  # timestamp and checksums of both types are stored in xattr
 When I execute "getfattr --dump /synced/x86_64/labirinto-1.0-1.fc29.x86_64.rpm"
 Then stdout matches line by line
      """
      # file: synced/x86_64/labirinto-1\.0-1\.fc29\.x86_64\.rpm
      user\.[lL]ibrepo\.checksum\.mtime="[0-9]+"
      user\.[lL]ibrepo\.checksum\.sha256="[0-9a-f]{64}"
      user\.[lL]ibrepo\.checksum\.sha512="[0-9a-f]{128}"
      """


@bz1931904
Scenario: reposync --remote-time stores correct timestamp in xattr
Given I use repository "simple-base" as http
 When I execute dnf with args "reposync --repoid=simple-base --norepopath --download-path=/synced --remote-time"
 Then the exit code is 0
 # the timestamp stored in user.Librepo.checksum.mtime xattr is the same as mtime of the file in nanoseconds
 When I execute "[ `getfattr --absolute-names --only-values -m 'user\.[lL]ibrepo\.checksum\.mtime' /synced/x86_64/labirinto-1.0-1.fc29.x86_64.rpm` == `date +%s%N -r /synced/x86_64/labirinto-1.0-1.fc29.x86_64.rpm` ]"
 Then the exit code is 0
