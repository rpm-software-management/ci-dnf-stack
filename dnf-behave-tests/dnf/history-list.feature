Feature: history list

Background:
Given I use repository "dnf-ci-fedora"
  # create some history to start with
  And I successfully execute dnf with args "install abcde basesystem"
  And I successfully execute dnf with args "remove abcde"
  And I successfully execute dnf with args "install nodejs"


@dnf5
Scenario: history list
 When I execute dnf with args "history list"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |
      | 2  |         |         | 3       |
      | 1  |         |         | 6       |

@dnf5
Scenario: history without sub-command
 When I execute dnf with args "history"
 Then the exit code is 2
  And stdout is empty
  And stderr is
  """
  Missing command. Add "--help" for more information about the arguments.
  """


@dnf5
# single item tests
Scenario: history list 2
 When I execute dnf with args "history list 2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         |         | 3       |

@dnf5
Scenario: history list last
 When I execute dnf with args "history list last"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |

@dnf5
Scenario: history last without subcommand
 When I execute dnf with args "history last"
 Then the exit code is 2
  And stdout is empty
  And stderr is
  """
  Unknown argument "last" for command "history". Add "--help" for more information about the arguments.
  """

@dnf5
Scenario: history list last-1
 When I execute dnf with args "history list last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         |         | 3       |

@dnf5
# range tests
Scenario: history list 1..last-1
 When I execute dnf with args "history list 1..last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         |         | 3       |
      | 1  |         |         | 6       |

@dnf5
Scenario: history list 1..last-2
 When I execute dnf with args "history list 1..last-2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         |         | 6       |

Scenario: history list 1..-1
 When I execute dnf with args "history 1..-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |
      | 1  |         | Install | 6       |

Scenario: history list 1..-2
 When I execute dnf with args "history 1..-2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         | Install | 6       |

@dnf5
Scenario: history list 2..3
 When I execute dnf with args "history list 2..3"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |
      | 2  |         |         | 3       |

@dnf5
Scenario: history list 10..11
 When I execute dnf with args "history list 10..11"
 Then the exit code is 0
  And stdout is empty

@dnf5
Scenario: history list last..11
 When I execute dnf with args "history list last..11"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |


@dnf5
# "invalid" range tests
Scenario: history list 3..2
 When I execute dnf with args "history list 3..2"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |
      | 2  |         |         | 3       |

@dnf5
Scenario: history list last-1..1
 When I execute dnf with args "history list last-1..1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         |         | 3       |
      | 1  |         |         | 6       |

@dnf5
Scenario: history list 11..last-1
 When I execute dnf with args "history list 11..last-1"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 3  |         |         | 5       |
      | 2  |         |         | 3       |

@dnf5
Scenario: history list last-1..aaa
 When I execute dnf with args "history list last-1..aaa"
 Then the exit code is 1
  And stdout is empty
  And stderr is
      """
      Invalid transaction ID range "last-1..aaa", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
      """

@dnf5
Scenario: history list 12a..bc
 When I execute dnf with args "history list 12a..bc"
 Then the exit code is 1
  And stdout is empty
  And stderr is
      """
      Invalid transaction ID range "12a..bc", "ID" or "ID..ID" expected, where ID is "NUMBER", "last" or "last-NUMBER".
      """


# package name tests
Scenario: history abcde
 When I execute dnf with args "history abcde"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         | Removed | 3       |
      | 1  |         | Install | 6       |

Scenario: history filesystem
 When I execute dnf with args "history filesystem"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         | Install | 6       |

Scenario: history lame (no transaction with such package)
 When I execute dnf with args "history lame"
 Then the exit code is 0
  And stdout is
      """
      No transaction which manipulates package 'lame' was found.
      """

@bz1786335
@bz1786316
@bz1852577
@bz1906970
# TODO change this to actually verify stdout
Scenario: history longer than 80 charactersi gets cut when there is no terminal
 When I execute dnf with args "history | head -1 | wc -c"
 Then the exit code is 0
  And stdout is
  """
  80
  """

@bz1786335
@bz1786316
Scenario: history length is 80 chars when missing rows are queried
 When I execute dnf with args "history 10 | head -1 | wc -c"
 Then the exit code is 0
  And stdout is
  """
  80
  """

@dnf5
@bz1846692
Scenario: history list --reverse
 When I execute dnf with args "history list --reverse"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 1  |         |         | 6       |
      | 2  |         |         | 3       |
      | 3  |         |         | 5       |


@dnf5
@bz1846692
Scenario: history 2..3 --reverse
 When I execute dnf with args "history list 2..3 --reverse"
 Then the exit code is 0
  And stdout is history list
      | Id | Command | Action  | Altered |
      | 2  |         |         | 3       |
      | 3  |         |         | 5       |
