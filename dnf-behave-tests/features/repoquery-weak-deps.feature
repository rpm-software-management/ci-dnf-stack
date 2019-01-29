Feature: Test for repoquery weak deps related functionality,
  options --recommends, --supplements, --suggests, --enhances, 
  --whatrecommends, --whatsupplements, --whatsuggests, --whatenhances, --repo


Scenario: repoquery --recommends (when there is no such capability)
 When I execute dnf with args "repoquery --recommends flac"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --recommends (when there is such capability in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --recommends abcde --repo dnf-ci-fedora"
 Then the exit code is 0
 Then stdout contains "flac"
 Then stdout does not contain "glibc"
 Then stdout does not contain "filesystem"


Scenario: repoquery --recommends (when there is such capability)
Given I use the repository "dnf-ci-fedora"
  And I execute dnf with args "repoquery --recommends abcde"
 Then the exit code is 0
 Then stdout contains "flac"
 Then stdout does not contain "glibc"
 Then stdout does not contain "filesystem"


Scenario: repoquery --supplements (when there is no such capability)
 When I execute dnf with args "repoquery --supplements flacbetterencoder"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --supplements (when there is such capability in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --supplements flacbetterencoder --repo dnf-ci-thirdparty"
 Then the exit code is 0
 Then stdout contains "flac"
 Then stdout does not contain "\*system\*"
    
      
Scenario: repoquery --supplements (when there is such capability)
Given I use the repository "dnf-ci-thirdparty"
  And I execute dnf with args "repoquery --supplements flacbetterencoder"
 Then the exit code is 0
 Then stdout contains "flac"


Scenario: repoquery --suggests (when there is no such capability)
 When I execute dnf with args "repoquery --suggests abcde"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --suggests (when there is such capability in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --suggests abcde --repo dnf-ci-fedora"
 Then the exit code is 0
 Then stdout contains "lame"
       

Scenario: repoquery --suggests (when there is such capability)
Given I use the repository "dnf-ci-fedora"
  And I execute dnf with args "repoquery --suggests abcde"
 Then the exit code is 0
 Then stdout contains "lame"


Scenario: repoquery --enhances (when there is no such capability)
 When I execute dnf with args "repoquery --enhances abcde"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --enhances (when there is such capability in listed repo)
Given I do not disable all repos
 When I execute dnf with args "repoquery --enhances CQRlib-extension --repo dnf-ci-thirdparty"
 Then the exit code is 0
 Then stdout contains "CQRlib-devel"


Scenario: repoquery --enhances (when there is such capability)
Given I use the repository "dnf-ci-thirdparty"
 When I execute dnf with args "repoquery --enhances CQRlib-extension"
 Then the exit code is 0
 Then stdout contains "CQRlib-devel"


Scenario: repoquery --whatrecommends (when there is no such pkg)
 When I execute dnf with args "repoquery --whatrecommends flac"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --whatrecommends (when there is such pkg in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --whatrecommends flac --repo dnf-ci-fedora"
 Then the exit code is 0
 Then stdout contains "abcde-0:2.9.2-1.fc29.noarch"


Scenario: repoquery --whatsupplements (when there is no such pkg)
 When I execute dnf with args "repoquery --whatsupplements flac"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --whatrecommends (when there is such pkg)
Given I use the repository "dnf-ci-fedora"
  And I execute dnf with args "repoquery --whatrecommends flac"
 Then the exit code is 0
 Then stdout contains "abcde-0:2.9.2-1.fc29.noarch"


Scenario: repoquery --whatsupplements (when there is such pkg in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --whatsupplements flac --repo dnf-ci-thirdparty"
 Then the exit code is 0
 Then stdout contains "FlacBetterEncoder-0:1.0-1.x86_64"


Scenario: repoquery --whatsupplements (when there is such pkg)
Given I use the repository "dnf-ci-thirdparty"
  And I execute dnf with args "repoquery --whatsupplements flac"
 Then the exit code is 0
 Then stdout contains "FlacBetterEncoder-0:1.0-1.x86_64"


Scenario: repoquery --whatsuggests (when there is no such pkg)
 When I execute dnf with args "repoquery --whatsuggests lame"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --whatsuggests (when there is such pkg in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --whatsuggests lame --repo dnf-ci-fedora"
 Then the exit code is 0
 Then stdout contains "abcde-0:2.9.2-1.fc29.noarch"


Scenario: repoquery --whatsuggests (when there is such pkg)
Given I use the repository "dnf-ci-fedora"
  And I execute dnf with args "repoquery --whatsuggests lame"
 Then the exit code is 0
 Then stdout contains "abcde-0:2.9.2-1.fc29.noarch"


Scenario: repoquery --whatenhances (when there is no such pkg)
 When I execute dnf with args "repoquery --whatenhances i-dont-exist"
 Then the exit code is 0
 Then stdout is empty


Scenario: repoquery --whatenhances (when there is such pkg in listed repo)
Given I do not disable all repos
  And I execute dnf with args "repoquery --whatenhances CQRlib-devel --repo dnf-ci-thirdparty"
 Then the exit code is 0
 Then stdout contains "CQRlib-extension-0:1.5-2.x86_64"
 

Scenario: repoquery --whatenhances (when there is such pkg)
Given I use the repository "dnf-ci-thirdparty"
  And I execute dnf with args "repoquery --whatenhances CQRlib-devel"
 Then the exit code is 0
 Then stdout contains "CQRlib-extension-0:1.5-2.x86_64"
