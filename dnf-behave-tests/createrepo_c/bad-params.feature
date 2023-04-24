Feature: Tests createrepo_c with bad parameters


Scenario Outline: Not specified directory
 When I execute createrepo_c with args " " in "."
 Then the exit code is 1
  And stderr is
      """
      Must specify exactly one directory to index
      Usage: createrepo_c [options] <directory_to_index>
      """


Scenario Outline: Bad params
 When I execute createrepo_c with args "<bad_param> " in "."
 Then the exit code is 1
  And stderr is
      """
      <stderr_output>
      """

Examples:
      | bad_param                                    | stderr_output                                                   |
      | /somenonexistingdirectorytoindex/            | Directory /somenonexistingdirectorytoindex/ must exist          |
      | --someunknownparam                           | Argument parsing failed: Unknown option --someunknownparam      |
      | --checksum foobarunknownchecksum .           | Unknown/Unsupported checksum type "foobarunknownchecksum"       |
      | --compress-type foobarunknowncompression .   | Unknown/Unsupported compression type "foobarunknowncompression" |
      | --groupfile badgroupfile .                   | groupfile ./badgroupfile doesn't exist                          |
      | --pkglist badpkglist .                       | pkglist file "badpkglist" doesn't exist                         |
      | --retain-old-md-by-age 1 --retain-old-md 1 . | --retain-old-md-by-age cannot be combined with --retain-old-md  |
      | --retain-old-md-by-age 55Z .                 | Bad time unit "Z"                                               |
