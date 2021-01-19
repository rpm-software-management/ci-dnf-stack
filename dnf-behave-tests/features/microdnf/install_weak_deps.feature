Feature: Tests --setopt=install_weak_deps=


Background: Prepare environment
 Given I use repository "dnf-ci-fedora"


@not.with_os=rhel__eq__8
Scenario: Install "abcde" without weak dependencies
   When I execute microdnf with args "install --setopt=install_weak_deps=0 abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |


@not.with_os=rhel__eq__8
Scenario: Install "abcde" with weak dependencies
   When I execute microdnf with args "install --setopt=install_weak_deps=1 abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
