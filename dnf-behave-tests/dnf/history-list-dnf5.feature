# This tests are somehow redundat for dnf4. the features
# are tested for history command in dnf4 with feature
# history-list.feature.
#
# The reason for the change is: dnf5 requires list as
# an argument while dnf4 does not.
#
# Example:
# in dnf4
# dnf history list last-1 is the same as dnf history last-1
# in df5
# dnf history last-1 is not valid
#
# This feature file can be merged with history-list.feature
# in the future if the behavior of history command will change
@dnf5
Feature: history list list

Background:
Given I use repository "dnf-ci-fedora"
  # create some history to start with
  And I successfully execute dnf with args "install abcde basesystem"
  And I successfully execute dnf with args "remove abcde"
  And I successfully execute dnf with args "install nodejs"


Scenario: history list last-1
 When I execute dnf with args "history list last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |


# range tests
Scenario: history list 1..last-1
 When I execute dnf with args "history list 1..last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |
      | 1  |         | Install | 6       |

Scenario: history list 1..last-2
 When I execute dnf with args "history list 1..last-2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         | Install | 6       |

Scenario: history list 1..last-2
 When I execute dnf with args "history list 1..last-2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         | Install | 6       |

Scenario: history list list 1..-1
 When I execute dnf with args "history list 1..-1"
 Then dnf4 exit code is 0
  And dnf4 stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |
      | 1  |         | Install | 6       |
  And dnf5 exit code is 1
  And dnf5 stderr is
  """
  Invalid transaction ID range "1..-1", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
  """

Scenario: history list list 1..-2
 When I execute dnf with args "history list 1..-2"
 Then dnf4 exit code is 0
  And dnf4 stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         | Install | 6       |
  And dnf5 exit code is 1
  And dnf5 stderr is
  """
  Invalid transaction ID range "1..-2", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
  """

Scenario: history list 2..3
 When I execute dnf with args "history list 2..3"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         | Install | 5       |
      | 2  |         | Removed | 3       |

Scenario: history list 10..11
 When I execute dnf with args "history list 10..11"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |

Scenario: history list last..11
 When I execute dnf with args "history list last..11"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         | Install | 5       |


# "invalid" range tests
Scenario: history list 3..2
 When I execute dnf with args "history list 3..2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         | Install | 5       |
      | 2  |         | Removed | 3       |

Scenario: history list last-1..1
 When I execute dnf with args "history list last-1..1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |
      | 1  |         | Install | 6       |

Scenario: history list 11..last-1
 When I execute dnf with args "history list 11..last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         | Install | 5       |
      | 2  |         | Removed | 3       |

Scenario: history list last-1..aaa
 When I execute dnf with args "history list last-1..aaa"
 Then the exit code is 1
  And dnf4 stderr is
      """
      Can't convert 'aaa' to transaction ID.
      Use '<number>', 'last', 'last-<number>'.
      """
 And dnf5 stderr is
      """
      Invalid transaction ID range "last-1..aaa", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
      """

Scenario: history list 12a..bc
 When I execute dnf with args "history list 12a..bc"
 Then the exit code is 1
  And dnf4 stderr is
      """
      Can't convert '12a' to transaction ID.
      Use '<number>', 'last', 'last-<number>'.
      """
  And dnf5 stderr is
      """
      Invalid transaction ID range "12a..bc", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
      """
