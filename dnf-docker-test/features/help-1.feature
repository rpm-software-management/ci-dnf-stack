Feature: DNF/Behave test (argument parser help)

Scenario: General help
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "--help" with "success"
  Then _deprecated line from "stdout" should "start" with "List of Main Commands"
  When _deprecated I execute "dnf" command "--unknown-opt" with "success"
  Then _deprecated line from "stdout" should "start" with "List of Main Commands"
  When _deprecated I execute "dnf" command "unknown-command" with "fail"
  Then _deprecated line from "stderr" should "start" with "No such command"
  Then _deprecated line from "stderr" should "start" with "It could be a DNF plugin command"
  When _deprecated I execute "dnf" command "help" with "success"
  Then _deprecated line from "stdout" should "start" with "List of Main Commands"

Scenario: Command help
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "help install" with "success"
  Then _deprecated line from "stdout" should "start" with "install a package or packages on your system"
  When _deprecated I execute "dnf" command "install --help" with "success"
  Then _deprecated line from "stdout" should "start" with "install a package or packages on your system"
  When _deprecated I execute "dnf" command "update --unknown-opt" with "fail"
  Then _deprecated line from "stderr" should "contain" with "upgrade: error: unrecognized arguments: --unknown-opt"
