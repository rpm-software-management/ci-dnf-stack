Feature: Sort search command output


Background:
  Given I use repository "search-sort"


@bz1811802
Scenario: sort alphanumerically
  When I execute dnf with args "search name"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       Package                             Description     Matched fields
       name.x86_64                         Summary         name (exact)
       name-summary.src                    Summary of name name, summary
       name-summary.x86_64                 Summary of name name, summary
       name-summary-description.src        Summary of name name, summary
       name-summary-description.x86_64     Summary of name name, summary
       name-summary-description-url.src    Summary of name name, summary
       name-summary-description-url.x86_64 Summary of name name, summary
       name-summary-url.src                Summary of name name, summary
       name-summary-url.x86_64             Summary of name name, summary
       name-description.src                Summary         name
       name-description.x86_64             Summary         name
       name-description-url.src            Summary         name
       name-description-url.x86_64         Summary         name
       name-url.src                        Summary         name
       name-url.x86_64                     Summary         name
       summary.src                         Summary of name summary
       summary.x86_64                      Summary of name summary
       summary-description.src             Summary of name summary
       summary-description.x86_64          Summary of name summary
       summary-description-url.src         Summary of name summary
       summary-description-url.x86_64      Summary of name summary
       summary-url.src                     Summary of name summary
       summary-url.x86_64                  Summary of name summary
       """


@bz1811802
Scenario: sort --all alphanumerically
  When I execute dnf with args "search --all name"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       Package                             Description  Matched fields
       name.src                            Summary      name (exact)
       name.x86_64                         Summary      name (exact)
       name-summary-description-url.src    Summary of n name, summary, description, url
       name-summary-description-url.x86_64 Summary of n name, summary, description, url
       name-summary-description.src        Summary of n name, summary, description
       name-summary-description.x86_64     Summary of n name, summary, description
       name-summary-url.src                Summary of n name, summary, url
       name-summary-url.x86_64             Summary of n name, summary, url
       name-summary.src                    Summary of n name, summary
       name-summary.x86_64                 Summary of n name, summary
       name-description-url.src            Summary      name, description, url
       name-description-url.x86_64         Summary      name, description, url
       name-description.src                Summary      name, description
       name-description.x86_64             Summary      name, description
       name-url.src                        Summary      name, url
       name-url.x86_64                     Summary      name, url
       summary-description-url.src         Summary of n summary, description, url
       summary-description-url.x86_64      Summary of n summary, description, url
       summary-description.src             Summary of n summary, description
       summary-description.x86_64          Summary of n summary, description
       summary-url.src                     Summary of n summary, url
       summary-url.x86_64                  Summary of n summary, url
       summary.src                         Summary of n summary
       summary.x86_64                      Summary of n summary
       description.src                     Summary      description
       description.x86_64                  Summary      description
       url.src                             Summary      url
       url.x86_64                          Summary      url
       """
