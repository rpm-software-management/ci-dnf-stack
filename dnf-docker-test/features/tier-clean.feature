Feature: Tier tests for cleaning dnf cache

  @setup
  Scenario: Feature setup
      Given http repository "base" with packages
         | Package       | Tag       | Value  |
         | TestA         | Version   | 1      |
      Given http repository "ext" with packages
         | Package       | Tag       | Value  |
         | TestA         | Version   | 2      |
         | TestB         | Version   | 1      |
      Given repository "local" with packages
         | Package       | Tag       | Value  |
         | TestC         | Version   | 1      |
         | TestD         | Version   | 1      |
         | TestE         | Version   | 1      |
      When I enable repository "base"
       And I enable repository "local"
       And I successfully run "dnf makecache"
       And I successfully run "dnf -y --setopt=keepcache=1 install TestA TestC"
      Then a file "/var/cache/dnf/base.solv" exists 
       And a file "/var/cache/dnf/local.solv" exists 
       And a file "/var/cache/dnf/base-filenames.solvx" exists 
       And a file "/var/cache/dnf/local-filenames.solvx" exists 
      When I successfully run "find /var/cache/dnf/ -name Test*"
      Then the command stdout should match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
       # only packages from non-local repos are cached
       And the command stdout should not match regexp "local-.*/packages/TestC-1-1.noarch.rpm" 
      When I successfully run "find /var/cache/dnf/ -name *.xml"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "local-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name *.xml.gz"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "local-.*/repodata" 

  Scenario: Cleanup of the whole cache (dnf clean all)
  # CACHE-CLEAN-1
      When I successfully run "dnf clean all"
      Then a file "/var/cache/dnf/base.solv" does not exist 
       And a file "/var/cache/dnf/local.solv" does not exist 
       And a file "/var/cache/dnf/base-filenames.solvx" does not exist
       And a file "/var/cache/dnf/local-filenames.solvx" does not exist
      When I successfully run "find /var/cache/dnf/ -name Test*"
      Then the command stdout should not match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
      When I successfully run "find /var/cache/dnf/ -name *.xml"
      Then the command stdout should not match regexp "base-.*/repodata" 
       And the command stdout should not match regexp "local-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name *.xml.gz"
      Then the command stdout should not match regexp "base-.*/repodata" 
       And the command stdout should not match regexp "local-.*/repodata" 
      # cleanup  
      When I successfully run "dnf -y remove TestA TestC"

  Scenario: Cached metadata cleanup (dnf clean metadata)
  # CACHE-CLEAN-2
      When I successfully run "dnf -y --setopt=keepcache=1 install TestA TestC"
       And I successfully run "dnf clean metadata"
      Then a file "/var/cache/dnf/base.solv" does not exist 
       And a file "/var/cache/dnf/local.solv" does not exist 
       And a file "/var/cache/dnf/base-filenames.solvx" does not exist
       And a file "/var/cache/dnf/local-filenames.solvx" does not exist
      When I successfully run "find /var/cache/dnf/ -name *.xml"
      Then the command stdout should not match regexp "base-.*/repodata" 
       And the command stdout should not match regexp "local-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name *.xml.gz"
      Then the command stdout should not match regexp "base-.*/repodata" 
       And the command stdout should not match regexp "local-.*/repodata" 
      # cached packages are not removed
      When I successfully run "find /var/cache/dnf/ -name Test*"
      Then the command stdout should match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
      # cleanup  
      When I successfully run "dnf -y remove TestA TestC"

  Scenario: Cached packages cleanup (dnf clean packages)
  # CACHE-CLEAN-4
      When I successfully run "dnf -y --setopt=keepcache=1 install TestA"
      Then I successfully run "find /var/cache/dnf/ -name Test*"
       And the command stdout should match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
      When I enable repository "ext"
      Then I successfully run "dnf -y --setopt=keepcache=1 install TestB"
       And I successfully run "dnf -y --setopt=keepcache=1 upgrade TestA"
       And I successfully run "find /var/cache/dnf/ -name Test*"
       And the command stdout should match regexp "ext-.*/packages/TestB-1-1.noarch.rpm" 
       And the command stdout should match regexp "ext-.*/packages/TestA-2-1.noarch.rpm" 
      When I successfully run "dnf clean packages"
      Then I successfully run "find /var/cache/dnf/ -name Test*"
       And the command stdout should not match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
       And the command stdout should not match regexp "ext-.*/packages/TestB-1-1.noarch.rpm" 
       And the command stdout should not match regexp "ext-.*/packages/TestA-2-1.noarch.rpm" 
       # metadata are not removed
       And a file "/var/cache/dnf/base.solv" exists 
       And a file "/var/cache/dnf/ext.solv" exists 
       And a file "/var/cache/dnf/base-filenames.solvx" exists 
       And a file "/var/cache/dnf/ext-filenames.solvx" exists 
      When I successfully run "find /var/cache/dnf/ -name *.xml"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "ext-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name *.xml.gz"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "ext-.*/repodata" 
      # cleanup  
      When I successfully run "dnf -y remove TestA TestB"

  Scenario: Database cache cleanup (dnf clean dbcache)
  # CACHE-CLEAN-6
      When I disable repository "ext"
       And I successfully run "dnf -y --setopt=keepcache=1 install TestA TestC"
       And I successfully run "dnf clean dbcache"
      Then a file "/var/cache/dnf/base.solv" does not exist 
       And a file "/var/cache/dnf/local.solv" does not exist 
       And a file "/var/cache/dnf/base-filenames.solvx" does not exist
       And a file "/var/cache/dnf/local-filenames.solvx" does not exist
      When I successfully run "find /var/cache/dnf/ -name *.xml"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "local-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name *.xml.gz"
      Then the command stdout should match regexp "base-.*/repodata" 
       And the command stdout should match regexp "local-.*/repodata" 
      When I successfully run "find /var/cache/dnf/ -name Test*"
      Then the command stdout should match regexp "base-.*/packages/TestA-1-1.noarch.rpm" 
      # cleanup  
      When I successfully run "dnf -y remove TestA TestC"

"""    
  # currently commented out, the desired behaviour is not clear
  Scenario: Expire dnf cache (dnf clean expire-cache) and install previously cached package
  # CACHE-CLEAN-3
  # it is checked that install reflect expire-cache
      When I successfully run "dnf makecache"
       And I successfully run "dnf -y --setopt=keepcache=1 install TestA"
       # pkg TestA is already cached
      Then the command stdout should match regexp ".SKIPPED. TestA-1-1.noarch.rpm: Already downloaded"
      When I successfully run "dnf -y remove TestA"
       And I successfully run "dnf clean expire-cache"
       And I successfully run "dnf -y install TestA"
       # pkg TestA is cached but the cache is marked as expired
      Then the command stdout should not match regexp ".SKIPPED. TestA-1-1.noarch.rpm: Already downloaded"
       And the command stdout should match regexp "TestA-1-1.noarch.rpm"
      # cleanup  
      When I successfully run "dnf -y remove TestA"
"""

"""
  # currently commented out
  # note: dnf info still does not reflect expire-cache, see bug 1552576
  Scenario: Expire dnf cache and run info for a package that has been removed meanwhile
  # CACHE-CLEAN-3
  # it is checked that info reflects expire-cache
      When I successfully run "dnf makecache"
       # remove TestE from repo "local", it will be only in dnf cache
       And I successfully run "sh -c 'rm -f TestE*'" in repository "local"
       And I successfully run "sh -c 'createrepo_c --update .'" in repository "local"
       And I successfully run "dnf info TestE"
      Then the command stdout should match regexp "Name.*:.*TestE"
      When I successfully run "dnf clean expire-cache"
       And I run "dnf info TestE"
      Then the command should fail
      Then the command stderr should match regexp "Error: No matching Packages"
"""
