Feature: Shell help


@not.with_os=rhel__eq__8
@bz1659328
Scenario: Using dnf shell, list available commands
   When I open dnf shell session
    And I execute in dnf shell "help"
   Then stdout contains "usage: .+ \[options\] COMMAND"
    And stdout contains "List of Main Commands:"
    And stdout contains "alias\s+List or create command aliases"
    And stdout contains "General DNF options:"
    And stdout contains "-q, --quiet\s+quiet operation"
    And stdout contains "Shell specific arguments:"
    And stdout contains "repository \(or repo\)\s+enable, disable or list repositories"
      # "List of Plugin Commands:" depends on enabled plugins
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
