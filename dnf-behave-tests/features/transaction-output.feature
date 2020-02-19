Feature: Test transasction output


@bz1794856
Scenario: Check whitespace between columns with long values in transaction table
Given I use repository "dnf-ci-thirdparty"
 When I execute dnf with args "clean all"
 # Piping to grep is forcing DNF to print into non standard terminal which is by default limited to 80 columns.
  And I execute "eval dnf -y --releasever={context.dnf.releasever} --installroot={context.dnf.installroot} --config={context.dnf.config} --setopt=module_platform_id={context.dnf.module_platform_id} --disableplugin='*' install forTestingPurposesWeEvenHaveReallyLongVersions | grep -v xxxxxx" in "{context.dnf.installroot}"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                                                                    |
      | install       | forTestingPurposesWeEvenHaveReallyLongVersions-0:1435347658326856238756823658aaaa-1.x86_64 |
  And stdout contains "forTestingPurposesWeEvenHaveReallyLongVersions\s+x86_64\s+1435347658326856238756823658aaaa-1\s+dnf-ci-thirdparty\s+.*"
