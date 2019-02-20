Feature: DNF test (plugin api)

@bz1626093
Scenario: Plugin can edit http headers
  Given http repository "base" with packages
    | Package | Tag       | Value  |
    | TestA   |           |        |
  When I save rpmdb
  And I enable repository "base"
  Given a file "/test/plugins/test.py" with 
  """
  import dnf
  import dnf.cli
  import dnf.exceptions
  import dnf.rpm.transaction

  class Test(dnf.Plugin): 

    name = "test" 
    def __init__(self, base, cli):
        super(Test, self).__init__(base, cli)

    def config(self): 
        for repoid, repo in self.base.repos.items(): 
            repo.set_http_headers([ 
                "custom_user_key20190218: custom_user_value", 
            ])
  """
  Given a file "/etc/dnf/dnf.conf" with 
  """
  [main]
  pluginpath=/test/plugins
  """
  When I successfully run "dnf clean all"
  Then I sniff packets expecting "custom_user_key20190218: custom_user_value"
