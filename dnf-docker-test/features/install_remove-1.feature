Feature: DNF/Behave test (install remove test)

Scenario: Install Remove TestA from repository "test-1" that requires TestB
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | absent       | TestC         |
 When I execute "dnf" command "-y install TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | present      | TestA, TestB  |
 When I execute "dnf" command "-y remove TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestB  |
   | absent       | TestC         |

Scenario: Install Remove TestD from repository "test-1" that requires TestE = 1.0.0-1
 Given I use the repository "test-1"
 When I execute "dnf" command "-y install TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestE  |
 When I execute "dnf" command "-y remove TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestD, TestE  |

Scenario: Install Remove TestF from repository "test-1" that requires TestG >= 1.0.0-1, TestH = 1.0.0-1
 Given I use the repository "test-1"
 When I execute "dnf" command "-y install TestF" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestF, TestG, TestH  |
 When I execute "dnf" command "-y remove TestF" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | removed      | TestF, TestG, TestH  |

Scenario: Install TestI from repository "test-1" that requires TestJ >= 1.0.0-2 and requirements cannot be installed
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y TestI" with "fail"
 Then transaction changes are as follows
   | State        | Packages      |
   | absent       | TestI, TestJ  |

Scenario: Install Remove multiple packages TestK, TestL from repository "test-1" that both require TestM
 Given I use the repository "test-1"
 When I execute "dnf" command "-y install TestK TestL" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestK, TestL, TestM  |
 When I execute "dnf" command "-y remove TestK" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestK         |
   | present      | TestL, TestM  |
 When I execute "dnf" command "-y remove TestL" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestL, TestM  |

Scenario: Install Remove provide from repository "test-1" that is provided by TestO that require TestC
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y ProvideA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestO, TestC  |
 When I execute "dnf" command "remove -y ProvideA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestO, TestC  |

Scenario: Install package from URL
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y http://127.0.0.1/repo/test-1/TestB-1.0.0-1.noarch.rpm" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestB      |
 When I execute "dnf" command "remove -y TestB" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestB      |

Scenario: Install TestB-1.0.0-1.noarch.rpm from local path
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y /var/www/html/repo/test-1/TestB-1.0.0-1.noarch.rpm" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestB      |
 When I execute "dnf" command "remove -y TestB" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestB      |

Scenario: Install *.rpm from local path
 Given I use the repository "test-1"
 When I execute "bash" command "mkdir /test" with "success"
 When I execute "bash" command "cp /var/www/html/repo/test-1/Test{A,B,C}-1*.rpm /test" with "success"
 When I execute "dnf" command "install -y /test/*.rpm" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestC  |
 When I execute "dnf" command "remove -y TestA TestB TestC" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | removed      | TestA, TestB, TestC  |

Scenario: Group Install Remove
 Given I use the repository "test-1"
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "install -y @Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestC  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "start" with "Installed groups:"
 And line from "stdout" should "not start" with "Available groups:"
 When I execute "dnf" command "install -y TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestE  |
 When I execute "dnf" command "group remove -y Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | removed      | TestA, TestB, TestC  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "remove -y TestD, TestE" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestD, TestE  |

Scenario: Group Install Remove List with with-optional option
 Given I use the repository "test-1"
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "group install -y with-optional Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages                           |
   | installed    | TestA, TestB, TestC, TestD, TestE  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "start" with "Installed groups:"
 And line from "stdout" should "not start" with "Available groups:"
 When I execute "dnf" command "remove -y @Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages                           |
   | removed      | TestA, TestB, TestC, TestD, TestE  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"

Scenario: Group Install Remove List if package with dependency is installed before group install
 Given I use the repository "test-1"
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "install -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "install -y @Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestC         |
   | present      | TestA, TestB  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "start" with "Installed groups:"
 And line from "stdout" should "not start" with "Available groups:"
 When I execute "dnf" command "group remove -y Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestC         |
   | present      | TestA, TestB  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "remove -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestB  |

Scenario: Group Install Remove List if package is installed before group install
 Given I use the repository "test-1"
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "install -y TestC" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestC      |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "install -y @Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | present      | TestC         |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "start" with "Installed groups:"
 And line from "stdout" should "not start" with "Available groups:"
 When I execute "dnf" command "group remove -y Testgroup" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestB  |
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "remove -y TestC" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestC      |
