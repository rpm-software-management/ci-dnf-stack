# destructive because it can create a new user on the system
@destructive
@dnf5
Feature: Testing functionality related to sharing root metadata cache to users

Background:
  Given I use repository "dnf-ci-fedora"
    # unprivileged user will need access to enter installroot and read files there
    And I successfully execute "chmod go+rwx {context.dnf.installroot}"
    # prepare a directory for the user's cache
    And I create directory "/{context.dnf.installroot}/var/cache/dnf-user"
    And I successfully execute "chmod 777 {context.dnf.installroot}/var/cache/dnf-user"
    And I successfully execute dnf with args "makecache"
   Then stdout matches line by line
   """
   Updating and loading repositories:
    dnf-ci-fedora test repository .*
   Repositories loaded.
   Metadata cache created.
   """


Scenario: Root cache is shared when user metadata are empty
   When I execute dnf with args "makecache --setopt=system_cachedir={context.dnf.installroot}/var/cache/dnf --setopt=cachedir={context.dnf.installroot}/var/cache/dnf-user" as an unprivileged user
   Then stdout matches line by line
   """
   Updating and loading repositories:
   Repositories loaded.
   Metadata cache created.
   """


Scenario: Root cache is not shared when the user doesn't have permissions
   When I successfully execute "chmod 700 {context.dnf.installroot}/var/cache/dnf"
    And I execute dnf with args "makecache --setopt=system_cachedir={context.dnf.installroot}/var/cache/dnf --setopt=cachedir={context.dnf.installroot}/var/cache/dnf-user" as an unprivileged user
   Then stdout matches line by line
   """
   Updating and loading repositories:
    dnf-ci-fedora test repository .*
   Repositories loaded.
   Metadata cache created.
   """
