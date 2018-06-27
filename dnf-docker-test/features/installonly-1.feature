Feature: Test for installonly packages upgrade
# the following provides are supposed to be installonly
# "kernel", "kernel-PAE", "installonlypkg(kernel)", "installonlypkg(kernel-module)", "installonlypkg(vm)"
# in this test, only kernel and installonlypkg(vm) are tested
 repo base: kernel-dummy-5-1
            kernel-dummy-vm-1-1
 repo ext1: kernel-dummy-5-2
            kernel-dummy-vm-1-2
 repo ext2: kernel-dummy-5-3
            kernel-dummy-vm-1-3
 repo ext3: kernel-dummy-5-4
            kernel-dummy-vm-1-4

  @setup
  Scenario: Setup (install kernel-dummy-5-1 and kernel-dummy-vm-1-1)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | kernel-dummy | Version  | 5         |
         |              | Release  | 1         |
	 |              | Provides | kernel = 5-1 |
         | kernel-dummy-vm | Version  | 1         |
         |              | Release  | 1         |
         |              | Provides | installonlypkg(vm) |
        And repository "ext1" with packages
         | Package      | Tag      | Value     |
         | kernel-dummy | Version  | 5         |
         |              | Release  | 2         |
         |              | Provides | kernel = 5-2 |
         | kernel-dummy-vm | Version  | 1         |
         |              | Release  | 2         |
         |              | Provides | installonlypkg(vm) |
        And repository "ext2" with packages
         | Package      | Tag      | Value     |
         | kernel-dummy | Version  | 5         |
         |              | Release  | 3         |
	 |              | Provides | kernel = 5-3 |
         | kernel-dummy-vm | Version  | 1         |
         |              | Release  | 3         |
         |              | Provides | installonlypkg(vm) |
        And repository "ext3" with packages
         | Package      | Tag      | Value     |
         | kernel-dummy | Version  | 5         |
         |              | Release  | 4         |
	 |              | Provides | kernel = 5-4 |
         | kernel-dummy-vm | Version  | 1         |
         |              | Release  | 4         |
         |              | Provides | installonlypkg(vm) |

       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install kernel-dummy"
        And I successfully run "dnf -y install kernel-dummy-vm"
       Then rpmdb changes are
         | State     | Packages         |
	 | installed | kernel-dummy/5-1,kernel-dummy-vm/1-1 |

  Scenario: run 'dnf upgrade' when there are no installonly upgrades available (installonly_limit not reached)
       When I save rpmdb
        And I successfully run "dnf -y upgrade"
       Then the command stderr should not match regexp "cannot install both kernel-dummy"
        And rpmdb does not change

  Scenario: run 'dnf upgrade' when there are 1st installonly upgrades available
       When I save rpmdb
        And I enable repository "ext1"
        And I successfully run "dnf -y upgrade"
       Then the command stderr should not match regexp "cannot install both kernel-dummy"
        And rpmdb changes are
         | State     | Packages         |
	 | unchanged | kernel-dummy/5-1,kernel-dummy-vm/1-1 |
	 | installed | kernel-dummy/5-2,kernel-dummy-vm/1-2 |

  Scenario: run 'dnf upgrade' when there are 2nd installonly upgrades available
       When I save rpmdb
        And I enable repository "ext2"
        And I successfully run "dnf -y upgrade"
       Then the command stderr should not match regexp "cannot install both kernel-dummy"
        And rpmdb changes are
         | State     | Packages         |
	 | unchanged | kernel-dummy/5-1,kernel-dummy/5-2,kernel-dummy-vm/1-1,kernel-dummy-vm/1-2 |
	 | installed | kernel-dummy/5-3,kernel-dummy-vm/1-3 |

  Scenario: run 'dnf upgrade' when there is 3rd kernel-dummy upgrade available (installonly_limit exceeded)
       When I save rpmdb
        And I enable repository "ext3"
        And I successfully run "dnf -y upgrade"
       Then the command stderr should not match regexp "cannot install both kernel-dummy"
        And rpmdb changes are
         | State     | Packages         |
	 | removed   | kernel-dummy/5-1,kernel-dummy-vm/1-1 |
	 | unchanged | kernel-dummy/5-2,kernel-dummy/5-3,kernel-dummy-vm/1-2,kernel-dummy-vm/1-3 |
	 | installed | kernel-dummy/5-4,kernel-dummy-vm/1-4 |

  Scenario: run 'dnf upgrade' when there are no installonly upgrades available (installonly_limit reached)
       When I save rpmdb
        And I successfully run "dnf -y upgrade"
       Then the command stderr should not match regexp "cannot install both kernel-dummy"
        And rpmdb does not change
