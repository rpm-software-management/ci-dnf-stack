Feature: Plugin API


Background:
Given I do not disable plugins
  And I do not set config file
  And I create and substitute file "/etc/dnf/dnf.conf" with
  """
  [main]
  pluginpath={context.dnf.installroot}/plugins
  """


@bz1650446
Scenario: Plugins have access to transaction items after transaction is finished
Given I create file "/plugins/test.py" with
  """
  import dnf

  class Test(dnf.Plugin):
    name = "testTransactionAccess"
    def __init__(self, base, cli):
        super(Test, self).__init__(base, cli)

    def transaction(self):
        downloads = self.base.transaction.install_set
        for pkg in downloads:
            print("Plugin has access to installed pkg: " +
                   pkg.name + "+" + pkg.version + "+" + pkg.release + "+" + pkg.arch)

  """
  And I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install setup filesystem"
 Then stdout contains "Plugin has access to installed pkg: setup\+2.12.1\+1.fc29\+noarch"
 Then stdout contains "Plugin has access to installed pkg: filesystem\+3.9\+2.fc29\+x86_64"
