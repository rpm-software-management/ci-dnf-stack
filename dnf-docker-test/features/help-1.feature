Feature: DNF/Behave test (argument parser help)

Scenario: General help
  Given I use the repository "test-1"
  When I execute "dnf" command "--help" with "success"
  Then line from "stdout" should "start" with "List of Main Commands"
  When I execute "dnf" command "--unknown-opt" with "success"
  Then line from "stdout" should "start" with "List of Main Commands"
  When I execute "dnf" command "unknown-command" with "fail"
  Then line from "stderr" should "start" with "No such command"
  Then line from "stderr" should "start" with "It could be a DNF plugin command"
  When I execute "dnf" command "help" with "success"
  Then line from "stdout" should "start" with "List of Main Commands"

Scenario: Command help
  Given I use the repository "test-1"
  When I execute "dnf" command "help install" with "success"
  Then line from "stdout" should "start" with "install a package or packages on your system"
  When I execute "dnf" command "install --help" with "success"
  Then line from "stdout" should "start" with "install a package or packages on your system"
  When I execute "dnf" command "update --unknown-opt" with "fail"
  Then line from "stderr" should "start" with "dnf upgrade: error: unrecognized arguments: --unknown-opt"
