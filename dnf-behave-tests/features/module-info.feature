Feature: Module info


Background:
Given I use the repository "dnf-ci-fedora"
Given I use the repository "dnf-ci-fedora-modular"
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | install                   | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-install    | nodejs/default                                |
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "module enable postgresql:11"
 Then the exit code is 0
 When I execute dnf with args "module install postgresql/client"
 Then the exit code is 0
  And modules state is following
      | Module        | State     | Stream    | Profiles      |
      | postgresql    | enabled   | 11        | client        |
  And Transaction contains
      | Action                    | Package                                          |
      | install                   | postgresql-0:11.1-2.module_2597+e45c4cc9.x86_64 |
      | module-profile-install    | postgresql/client                                |


Scenario: Get info for a module, only module name specified
 When I execute dnf with args "module info nodejs"
 Then the exit code is 0
 Then stdout matches each line once
  """
    Name\s+:\s+nodejs
    Stream\s+:\s+10
    Version\s+:\s+20180920144631
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default \[d\])
    Default profiles\s+:\s+default
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+nodejs-1:10.11.0-1.module_2200\+adbac02b.x86_64
    \s+:\s+nodejs-devel-1:10.11.0-1.module_2200\+adbac02b.x86_64
    \s+:\s+nodejs-docs-1:10.11.0-1.module_2200\+adbac02b.noarch
    \s+:\s+npm-1:10.11.0-1.module_2200\+adbac02b.x86_64

    Name\s+:\s+nodejs
    Stream\s+:\s+10
    Version\s+:\s+20190102201818
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default \[d\])
    Default profiles\s+:\s+default
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+http-parser-0:2.9.0-1.module_2672\+97d6a5e9.x86_64
    \s+:\s+http-parser-devel-0:2.9.0-1.module_2672\+97d6a5e9.x86_64
    \s+:\s+libnghttp2-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
    \s+:\s+libnghttp2-devel-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
    \s+:\s+libuv-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
    \s+:\s+libuv-devel-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
    \s+:\s+libuv-static-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
    \s+:\s+nghttp2-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
    \s+:\s+nodejs-1:10.14.1-1.module_2533\+7361f245.x86_64
    \s+:\s+nodejs-devel-1:10.14.1-1.module_2533\+7361f245.x86_64
    \s+:\s+nodejs-docs-1:10.14.1-1.module_2533\+7361f245.noarch

    Name\s+:\s+nodejs
    Stream\s+:\s+8 \[d\]\[e\]
    Version\s+:\s+20180801080000
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default \[d\])
    Default profiles\s+:\s+default
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
    \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
    \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
    \s+:\s+npm-1:8.11.4-1.module_2030\+42747d40.x86_64

    Name\s+:\s+nodejs
    Stream\s+:\s+8 \[d\]\[e\]\[a\]
    Version\s+:\s+20181216123422
    Context\s+:\s+7f892346
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default \[d\])
    Default profiles\s+:\s+default
    Repo\s+:\s+dnf-ci-fedora-modular-updates
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
    \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
    \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
    \s+:\s+npm-1:8.14.0-1.module_2030\+42747d41.x86_64

    Name\s+:\s+nodejs
    Stream\s+:\s+11
    Version\s+:\s+20180920144611
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default)
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+nodejs-1:11.0.0-1.module_2311\+8d497411.x86_64
    \s+:\s+nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
    \s+:\s+nodejs-docs-1:11.0.0-1.module_2311\+8d497411.noarch
    \s+:\s+npm-1:11.0.0-1.module_2311\+8d497411.x86_64

    Name\s+:\s+nodejs
    Stream\s+:\s+11
    Version\s+:\s+20181102165620
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default)
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+libnghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+libnghttp2-devel-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-devel-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-static-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+nghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+nodejs-1:11.1.0-1.module_2379\+8d497405.x86_64
    \s+:\s+nodejs-devel-1:11.1.0-1.module_2379\+8d497405.x86_64
    \s+:\s+nodejs-docs-1:11.1.0-1.module_2379\+8d497405.noarch
    \s+:\s+npm-1:11.1.0-1.module_2379\+8d497405.x86_64
     
    Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
  """


Scenario: Get info for an enabled stream, module name and stream specified
 When I execute dnf with args "module info nodejs:11"
 Then the exit code is 0
 Then stdout matches each line once
  """
    Name\s+:\s+nodejs
    Stream\s+:\s+11
    Version\s+:\s+20180920144611
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default)
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+nodejs-1:11.0.0-1.module_2311\+8d497411.x86_64
    \s+:\s+nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
    \s+:\s+nodejs-docs-1:11.0.0-1.module_2311\+8d497411.noarch
    \s+:\s+npm-1:11.0.0-1.module_2311\+8d497411.x86_64

    Name\s+:\s+nodejs
    Stream\s+:\s+11
    Version\s+:\s+20181102165620
    Context\s+:\s+6c81f848
    Architecture\s+:\s+x86_64
    Profiles\s+:\s+(development|minimal|default)
    Repo\s+:\s+dnf-ci-fedora-modular
    Summary\s+:\s+Javascript runtime
    Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
    Artifacts\s+:\s+libnghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+libnghttp2-devel-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-devel-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+libuv-static-1:1.23.2-1.module_2365\+652bf990.x86_64
    \s+:\s+nghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
    \s+:\s+nodejs-1:11.1.0-1.module_2379\+8d497405.x86_64
    \s+:\s+nodejs-devel-1:11.1.0-1.module_2379\+8d497405.x86_64
    \s+:\s+nodejs-docs-1:11.1.0-1.module_2379\+8d497405.noarch
    \s+:\s+npm-1:11.1.0-1.module_2379\+8d497405.x86_64

    Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
  """

  
  @bz1540189
  Scenario: Get info for an installed profile, module name and profile specified
   When I execute dnf with args "module info nodejs/minimal"
   Then the exit code is 0
   Then stdout matches each line once
    """
      Ignoring unnecessary profile: 'nodejs/minimal'
      Name\s+:\s+nodejs
      Stream\s+:\s+10
      Version\s+:\s+20180920144631
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:10.11.0-1.module_2200\+adbac02b.x86_64
      \s+:\s+nodejs-devel-1:10.11.0-1.module_2200\+adbac02b.x86_64
      \s+:\s+nodejs-docs-1:10.11.0-1.module_2200\+adbac02b.noarch
      \s+:\s+npm-1:10.11.0-1.module_2200\+adbac02b.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+10
      Version\s+:\s+20190102201818
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+http-parser-0:2.9.0-1.module_2672\+97d6a5e9.x86_64
      \s+:\s+http-parser-devel-0:2.9.0-1.module_2672\+97d6a5e9.x86_64
      \s+:\s+libnghttp2-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
      \s+:\s+libnghttp2-devel-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
      \s+:\s+libuv-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
      \s+:\s+libuv-devel-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
      \s+:\s+libuv-static-1:1.23.2-1.module_2302\+4c6ccf2f.x86_64
      \s+:\s+nghttp2-0:1.35.1-1.module_2672\+97d6a5e9.x86_64
      \s+:\s+nodejs-1:10.14.1-1.module_2533\+7361f245.x86_64
      \s+:\s+nodejs-devel-1:10.14.1-1.module_2533\+7361f245.x86_64
      \s+:\s+nodejs-docs-1:10.14.1-1.module_2533\+7361f245.noarch
  
      Name\s+:\s+nodejs
      Stream\s+:\s+8 \[d\]\[e\]
      Version\s+:\s+20180801080000
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
      \s+:\s+npm-1:8.11.4-1.module_2030\+42747d40.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+8 \[d\]\[e\]\[a\]
      Version\s+:\s+20181216123422
      Context\s+:\s+7f892346
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular-updates
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
      \s+:\s+npm-1:8.14.0-1.module_2030\+42747d41.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20180920144611
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-docs-1:11.0.0-1.module_2311\+8d497411.noarch
      \s+:\s+npm-1:11.0.0-1.module_2311\+8d497411.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20181102165620
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+libnghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libnghttp2-devel-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-devel-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-static-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+nghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+nodejs-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-devel-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-docs-1:11.1.0-1.module_2379\+8d497405.noarch
      \s+:\s+npm-1:11.1.0-1.module_2379\+8d497405.x86_64
       
      Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
    """
  
  
  @bz1540189
  Scenario: Get info for an installed profile, module name, stream and profile specified
   When I execute dnf with args "module info nodejs:11/minimal"
   Then the exit code is 0
   Then stdout matches each line once
    """
      Ignoring unnecessary profile: 'nodejs/minimal'
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20180920144611
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-docs-1:11.0.0-1.module_2311\+8d497411.noarch
      \s+:\s+npm-1:11.0.0-1.module_2311\+8d497411.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20181102165620
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+libnghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libnghttp2-devel-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-devel-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-static-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+nghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+nodejs-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-devel-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-docs-1:11.1.0-1.module_2379\+8d497405.noarch
      \s+:\s+npm-1:11.1.0-1.module_2379\+8d497405.x86_64
  
      Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
    """
  
  
  @bz1540189
  Scenario: Non-existent profile is ignored for dnf module info
   When I execute dnf with args "module info nodejs:11/non-existing-profile"
   Then the exit code is 0
   Then stdout matches each line once
    """
      Ignoring unnecessary profile: 'nodejs/non-existing-profile'
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20180920144611
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-devel-1:11.0.0-1.module_2311\+8d497411.x86_64
      \s+:\s+nodejs-docs-1:11.0.0-1.module_2311\+8d497411.noarch
      \s+:\s+npm-1:11.0.0-1.module_2311\+8d497411.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+11
      Version\s+:\s+20181102165620
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default)
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+libnghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libnghttp2-devel-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-devel-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+libuv-static-1:1.23.2-1.module_2365\+652bf990.x86_64
      \s+:\s+nghttp2-0:1.34.0-1.module_2365\+652bf990.x86_64
      \s+:\s+nodejs-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-devel-1:11.1.0-1.module_2379\+8d497405.x86_64
      \s+:\s+nodejs-docs-1:11.1.0-1.module_2379\+8d497405.noarch
      \s+:\s+npm-1:11.1.0-1.module_2379\+8d497405.x86_64
  
      Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
    """
  
  
  @bz1623535
  Scenario: Get error message when info for non-existent module is requested
   When I execute dnf with args "module info non-existing-module"
   Then the exit code is 1
    And stdout contains "Unable to resolve argument non-existing-module"
    And stderr contains "Error: No matching Modules to list"
  
  
  Scenario: Get info for two enabled modules from different repos
   When I execute dnf with args "module info nodejs:8 postgresql:10"
   Then the exit code is 0
   Then stdout matches each line once
   """
      Name\s+:\s+nodejs
      Stream\s+:\s+8 \[d\]\[e\]
      Version\s+:\s+20180801080000
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
      \s+:\s+npm-1:8.11.4-1.module_2030\+42747d40.x86_64
  
      Name\s+:\s+nodejs
      Stream\s+:\s+8 \[d\]\[e\]\[a\]
      Version\s+:\s+20181216123422
      Context\s+:\s+7f892346
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(development|minimal|default \[d\])
      Default profiles\s+:\s+default
      Repo\s+:\s+dnf-ci-fedora-modular
      Summary\s+:\s+Javascript runtime
      Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
      Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
      \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
      \s+:\s+npm-1:8.14.0-1.module_2030\+42747d41.x86_64
  
      Name\s+:\s+postgresql
      Stream\s+:\s+10
      Version\s+:\s+20181211125304
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(client|server|default)
      Repo\s+:\s+dnf-ci-fedora-modular-updates
      Summary\s+:\s+PostgreSQL module
      Description\s+:\s+PostgreSQL is an advanced Object-Relational database management system \(DBMS\). The PostgreSQL server can be found in the postgresql-server sub-package.
      Artifacts\s+:\s+postgresql-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-contrib-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-devel-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-docs-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-libs-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plperl-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plpython-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plpython3-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-pltcl-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-server-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-static-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-test-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-test-rpm-macros-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-upgrade-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-upgrade-devel-0:10.6-1.module_2594\+0c9aadc5.x86_64
  
      Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
      """
  
  
  @bz1623535
  # Command "dnf module info" should behave like "dnf info" in case that only one argument cannot
  # be resolved (success).
  Scenario: Get info for two modules, one of them non-existent
   When I execute dnf with args "module info postgresql:10 non-existing-module"
   Then the exit code is 0
   Then stdout matches each line once
    """
      Unable to resolve argument non-existing-module
      Name\s+:\s+postgresql
      Stream\s+:\s+10
      Version\s+:\s+20181211125304
      Context\s+:\s+6c81f848
      Architecture\s+:\s+x86_64
      Profiles\s+:\s+(client|server|default)
      Repo\s+:\s+dnf-ci-fedora-modular-updates
      Summary\s+:\s+PostgreSQL module
      Description\s+:\s+PostgreSQL is an advanced Object-Relational database management system \(DBMS\). The PostgreSQL server can be found in the postgresql-server sub-package.
      Artifacts\s+:\s+postgresql-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-contrib-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-devel-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-docs-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-libs-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plperl-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plpython-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-plpython3-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-pltcl-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-server-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-static-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-test-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-test-rpm-macros-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-upgrade-0:10.6-1.module_2594\+0c9aadc5.x86_64
      \s+:\s+postgresql-upgrade-devel-0:10.6-1.module_2594\+0c9aadc5.x86_64
  
      Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
    """
  
  
  Scenario: Run 'dnf module info' without further argument
   When I execute dnf with args "module info"
   Then the exit code is 1
    And stderr contains "Error: dnf module info: too few arguments"
  
  
  @bz1571214
  Scenario Outline: I can get the info about content of existing module streams with <command>
   When I execute dnf with args "<command>"
   Then the exit code is 0
   Then stdout matches each line once
   """
   Name\s+:\s+postgresql:10:20181211125304:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:11:20181212114126:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:9.6:20180816142114:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:9.6:20190109151606:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
   """

Examples:
    | command                               |
    | module info --profile postgresql      |
    | -q module info --profile postgresql   |

  
  
  Scenario: Profile specification is ignored by dnf module info --profile
   When I execute dnf with args "module info --profile postgresql/client"
   Then the exit code is 0
   Then stdout matches each line once
   """
   Ignoring unnecessary profile: 'postgresql/client'
   Name\s+:\s+postgresql:10:20181211125304:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:11:20181212114126:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:9.6:20180816142114:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
  
   Name\s+:\s+postgresql:9.6:20190109151606:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
   """
  
  
  Scenario: I can get the info about contents of more than one module profile streams
   When I execute dnf with args "module info --profile postgresql:10 nodejs:11"
   Then the exit code is 0
   Then stdout matches each line once
   """
   Name\s+:\s+nodejs:11:20180920144611:6c81f848:x86_64
   development\s+:\s+nodejs
   \s+:\s+nodejs-devel
   \s+:\s+npm
   minimal\s+:\s+nodejs
   default\s+:\s+nodejs
   \s+:\s+npm
  
   Name\s+:\s+nodejs:11:20181102165620:6c81f848:x86_64
   development\s+:\s+nodejs
   \s+:\s+nodejs-devel
   \s+:\s+npm
   minimal\s+:\s+nodejs
   default\s+:\s+nodejs
   \s+:\s+npm
  
   Name\s+:\s+postgresql:10:20181211125304:6c81f848:x86_64
   client\s+:\s+postgresql
   server\s+:\s+postgresql-server
   default\s+:\s+postgresql-server
   """
  
  
  Scenario: "dnf module profile" without any additional arguments should raise an error
   When I execute dnf with args "module info --profile"
   Then the exit code is 1
    And stderr is
    """
    Error: dnf module info: too few arguments
  
    """

  @bz1636091
  Scenario: The module stream context information is present
   When I execute dnf with args "module info nodejs:11"
   Then the exit code is 0
   And stdout contains "Context\s+:\s+6c81f848"

  @bz1700250
  @bz1636337
  Scenario: I can get the module context of the active stream
   When I execute dnf with args "module info nodejs:8"
   Then stdout matches each line once
      """
        Name\s+:\s+nodejs
        Stream\s+:\s+8
        Version\s+:\s+20180801080000
        Context\s+:\s+6c81f848
        Architecture\s+:\s+x86_64
        Profiles\s+:\s+(development|minimal|default \[d\])
        Default profiles\s+:\s+default
        Repo\s+:\s+dnf-ci-fedora-modular
        Summary\s+:\s+Javascript runtime
        Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
        Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
        \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
        \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
        \s+:\s+npm-1:8.11.4-1.module_2030\+42747d40.x86_64

        Name\s+:\s+nodejs
        Stream\s+:\s+8 \[d\]\[e\]\[a\]
        Version\s+:\s+20181216123422
        Context\s+:\s+7f892346
        Architecture\s+:\s+x86_64
        Profiles\s+:\s+(development|minimal|default \[d\])
        Default profiles\s+:\s+default
        Repo\s+:\s+dnf-ci-fedora-modular-updates
        Summary\s+:\s+Javascript runtime
        Description\s+:\s+Node.js is a platform built on Chrome''s JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.
        Artifacts\s+:\s+nodejs-1:8.11.4-1.module_2030\+42747d40.x86_64
        \s+:\s+nodejs-devel-1:8.11.4-1.module_2030\+42747d40.x86_64
        \s+:\s+nodejs-docs-1:8.11.4-1.module_2030\+42747d40.noarch
        \s+:\s+npm-1:8.14.0-1.module_2030\+42747d41.x86_64

        Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled, \[a\]ctive
      """
     And stdout does not contain "\[a\]ctive\]"
