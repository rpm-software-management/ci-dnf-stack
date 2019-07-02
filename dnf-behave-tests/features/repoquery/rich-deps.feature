Feature: Tests for rich (boolean) dependencies:
 and - requires all operands to be fulfilled for the term to be True.
 or - requires one of the operands to be fulfilled
 if - requires the first operand to be fulfilled if the second is (reverse implication)
 if else - same as above but requires the third operand to be fulfilled if the second is not
 with - requires all operands to be fulfilled by the same package for the term to be True.
 without - requires a single package that satisfies the first operand but not the second (set subtraction)
 unless - requires the first operand to be fulfilled if the second is not (reverse negative implication)
 unless else - same as above but requires the third operand to be fulfilled if the second is

Background:
Given I use the repository "repoquery-rich-deps"


Scenario: repoquery --recommends NAME
 When I execute dnf with args "repoquery --recommends c1"
 Then the exit code is 0
  And stdout is
      """
      (b1 and a1)
      """


# c1-1.0: Requires: (a1-prov1 if b1)
Scenario: repoquery --whatrequires for "(a1-prov1 if b1)"
 When I execute dnf with args "repoquery --whatrequires a1"
 Then the exit code is 0
  And stdout is
      """
      c1-0:1.0-1.x86_64
      c1-0:2.0-1.x86_64
      """


# a1-1.0: Conflicts: ((b1 and x1) or c1)
Scenario: repoquery --whatconflicts for "((b1 and x1) or c1)"
 When I execute dnf with args "repoquery --whatconflicts b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatconflicts c1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatconflicts x1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
Given I successfully execute dnf with args "install x1"
 When I execute dnf with args "repoquery --whatconflicts b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatconflicts c1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatconflicts x1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """


# a1-1.0: Recommends: (b1 < 2.0 if x1 >= 2.0 else c1)
Scenario: repoquery --whatrecommends for "(b1 < 2.0 if x1 >= 2.0 else c1)"
 When I execute dnf with args "repoquery --whatrecommends b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      c1-0:1.0-1.x86_64
      c1-0:2.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatrecommends 'b1 > 2.0'"
 Then the exit code is 0
  And stdout is
      """
      c1-0:1.0-1.x86_64
      c1-0:2.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatrecommends x1"
 Then the exit code is 0
  And stdout is empty
 When I execute dnf with args "repoquery --whatrecommends c1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """


# a1-1.0: Suggests: ((b1 with b1-prov2 > 1.7) or (c1 <= 1.0 without c1-prov1 > 0.5))
Scenario: repoquery --whatsuggests for "((b1 with b1-prov2 > 1.7) or (c1 <= 1.0 without c1-prov1 > 0.5))"
 When I execute dnf with args "repoquery --whatsuggests b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatsuggests c1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """


# a1-1.0: Supplements: ((b1 < 2.0 with b1-prov2 > 1.7) or (c1 > 1.0 without c1-prov1 > 0.5))
Scenario: repoquery --whatsupplements for "((b1 < 2.0 with b1-prov2 > 1.7) or (c1 > 1.0 without c1-prov1 > 0.5))"
 When I execute dnf with args "repoquery --whatsupplements b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatsupplements 'c1 < 1.0'"
 Then the exit code is 0
  And stdout is empty


# a1-1.0: Enhances: (b1 unless x1)
Scenario: repoquery --whatenhances for "(b1 unless x1)"
 When I execute dnf with args "repoquery --whatenhances b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """
Given I successfully execute dnf with args "install x1"
 When I execute dnf with args "repoquery --whatenhances b1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      """


# b1-1.0: Enhances: (a1 unless x1 else c1)
Scenario: repoquery --whatenhances for "(a1 unless x1 else c1)"
 When I execute dnf with args "repoquery --whatenhances a1"
 Then the exit code is 0
  And stdout is
      """
      b1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatenhances c1"
 Then the exit code is 0
  And stdout is
      """
      b1-0:1.0-1.x86_64
      """
Given I successfully execute dnf with args "install x1"
 When I execute dnf with args "repoquery --whatenhances c1"
 Then the exit code is 0
  And stdout is
      """
      b1-0:1.0-1.x86_64
      """
 When I execute dnf with args "repoquery --whatenhances a1"
 Then the exit code is 0
  And stdout is
      """
      b1-0:1.0-1.x86_64
      """


# --whatdepends
Scenario: repoquery --whatdepends NAME
 When I execute dnf with args "repoquery --whatdepends c1"
 Then the exit code is 0
  And stdout is
      """
      a1-0:1.0-1.x86_64
      b1-0:1.0-1.x86_64
      """
