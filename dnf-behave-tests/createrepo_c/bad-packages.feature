Feature: createrepo_c on repository with bad packages


Scenario: create regular consistent repository with some bad packages
Given I create directory "/temp-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"
  And I create file "/temp-repo/afilethatlookslike.rpm" with
      """
      foobar
      """
  And I create file "/temp-repo/emptyfilethatlookslike.rpm" with
      """
      """
 When I execute createrepo_c with args "--workers 1 ." in "/temp-repo"
 Then the exit code is 2
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst         | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst       | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst           | sha256        | zstd             |
  And primary in "/temp-repo/repodata" has only packages
      | Name      | Epoch | Version | Release | Architecture |
      | package   | 0     | 0.2.1   | 1.fc29  | x86_64       |
  And stderr is
      """
      C_CREATEREPOLIB: Warning: read_header: rpmReadPackageFile() error
      C_CREATEREPOLIB: Warning: Cannot read package: ./afilethatlookslike.rpm: rpmReadPackageFile() error
      C_CREATEREPOLIB: Warning: read_header: rpmReadPackageFile() error
      C_CREATEREPOLIB: Warning: Cannot read package: ./emptyfilethatlookslike.rpm: rpmReadPackageFile() error
      """


Scenario: Don't re-escape ampersand when running with --update
Given I create symlink "/createrepo_c-ci-packages" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages"
  And I execute createrepo_c with args "." in "/"
 When I execute createrepo_c with args "--update ." in "/"
 Then the exit code is 0
  And repodata "/repodata" are consistent
  And I execute "dnf --repofrompath=test,{context.scenario.default_tmp_dir}/ --installroot={context.scenario.default_tmp_dir} --disableplugin='*' --repo test repoquery --provides ampersand-provide-package"
  And stdout is
  """
  <REPOSYNC>
  ampersand-provide-package = 0.2.1-1.fc29
  ampersand-provide-package(x86-64) = 0.2.1-1.fc29
  font(bpgalgetigpl&gnu)
  """
