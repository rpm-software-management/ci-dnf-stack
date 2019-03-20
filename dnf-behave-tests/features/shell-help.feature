Feature: Shell help


Scenario: Using dnf shell, list available commands
   When I open dnf shell session
    And I execute in dnf shell "help"
   Then stdout contains "usage: .+ \[options\] COMMAND"
    And stdout contains "List of Main Commands:"
    And stdout contains "Optional arguments:"
    And stdout contains "Shell specific arguments:"
      # "List of Plugin Commands:" depends on enabled plugins
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
