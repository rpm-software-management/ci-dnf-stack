@dnf5
Feature: Reset modules


Background:
Given I use repository "dnf-ci-fedora-modular"


# rely on merging bz1677640 fix
Scenario: I can reset a disabled default stream back to its default state
 When I execute dnf with args "module disable nodejs"
  And I execute dnf with args "module list nodejs"
 Then stdout contains "nodejs\s+8\s+\[d\]\[x\]\s+de"
 Then stdout contains "nodejs\s+10\s+\[x\]\s+de"
 Then stdout contains "nodejs\s+11\s+\[x\]\s+de"
  And I execute dnf with args "module reset nodejs"
 Then stdout contains "Resetting modules:"
  And stdout contains "nodejs"
  And I execute dnf with args "module list nodejs"
 Then stdout contains "nodejs\s+8\s+\[d\]\s+de"
 Then stdout contains "nodejs\s+10\s+de"
 Then stdout contains "nodejs\s+11\s+de"


# rely on merging bz1677640 fix
Scenario: I can reset a disabled non-default stream back to a non-default state
 When I execute dnf with args "module disable dwm"
  And I execute dnf with args "module list" 
 Then stdout contains "dwm\s+6.0\s+\[x\]\s+de"
 Then I execute dnf with args "module reset dwm"
 Then stdout contains "Resetting modules:"
  And stdout contains "dwm"
  And I execute dnf with args "module list" 
 Then stdout contains "dwm\s+6.0\s+de"


Scenario: Resetting of a default stream does nothing
 When I execute dnf with args "module list nodejs"
 Then stdout contains "nodejs\s+8\s+\[d\]\s+de"
 Then stdout contains "nodejs\s+10\s+de"
 Then stdout contains "nodejs\s+11\s+de"
  And I execute dnf with args "module reset nodejs"
 Then stdout contains "Nothing to do"
 When I execute dnf with args "module list nodejs"
 Then stdout contains "nodejs\s+8\s+\[d\]\s+de"
 Then stdout contains "nodejs\s+10\s+de"
 Then stdout contains "nodejs\s+11\s+de"


Scenario: Resetting of a non-default non-enabled stream does nothing
 When I execute dnf with args "module list dwm" 
 Then stdout contains "dwm\s+6.0\s+de"
 Then I execute dnf with args "module reset dwm"
 Then stdout contains "Nothing to do"
 When I execute dnf with args "module list dwm" 
 Then stdout contains "dwm\s+6.0\s+de"
 

@bz1677640
# scenario different from the one in the relevant requirement!
Scenario: I can reset an enabled default stream back to its non-enabled default state
 When I execute dnf with args "module enable nodejs:8" 
 Then I execute dnf with args "module list nodejs" 
 Then stdout contains "nodejs\s+8\s+\[d\]\[e\]\s+de"
 Then stdout contains "nodejs\s+10\s+de"
 Then stdout contains "nodejs\s+11\s+de"
  And I execute dnf with args "module reset nodejs"
 Then stdout contains "Resetting modules:"
 Then stdout contains "nodejs"
 Then I execute dnf with args "module list nodejs" 
 Then stdout contains "nodejs\s+8\s+\[d\]\s+de"
 Then stdout contains "nodejs\s+10\s+de"
 Then stdout contains "nodejs\s+11\s+de"


# rely on merging bz1677640 fix
# scenario different from the one in the relevant requirement!
Scenario: I can reset an enabled non-default stream back to a non-enabled state
 When I execute dnf with args "module enable dwm:6.0/default" 
 Then I execute dnf with args "module list dwm" 
 Then stdout contains "dwm\s+6.0\s+\[e\]\s+de"
 Then I execute dnf with args "module reset dwm"
 Then stdout contains "Resetting modules:"
 Then stdout contains "dwm"
 When I execute dnf with args "module list dwm" 
 Then stdout contains "dwm\s+6.0\s+de"
