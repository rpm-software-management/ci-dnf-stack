Feature: Execute more commands in one transaction in dnf shell


Scenario: Using dnf shell, install and remove RPMs in one transaction
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "install flac"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
    And I execute in dnf shell "install filesystem"
    And I execute in dnf shell "remove flac"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | flac-0:1.3.2-8.fc29.x86_64                |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"


Scenario: Using dnf shell, switch conflicting RPMs using install and remove
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-thirdparty dnf-ci-fedora-updates"
    And I execute in dnf shell "install CQRlib CQRlib-extension SuperRipper"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-extension-0:1.5-2.x86_64           |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install       | abcde-0:2.9.3-1.fc29.noarch               |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
        | install       | wget-0:1.19.6-5.fc29.x86_64               |
        | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
   When I execute in dnf shell "remove CQRlib-extension"
    And I execute in dnf shell "install SuperRipper-extension"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | install       | SuperRipper-extension-0:1.1-1.x86_64      |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
