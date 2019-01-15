import behave

from common import *


@behave.given("I use the repository \"{repo}\"")
def given_repo_condition(context, repo):
    if "repos" not in context.dnf:
        context.dnf["repos"] = []
    if repo not in context.dnf["repos"]:
        context.dnf["repos"].append(repo)


@behave.given("I disable the repository \"{repo}\"")
def given_repo_condition(context, repo):
    if "repos" not in context.dnf:
        context.dnf["repos"] = []
    context.dnf["repos"].remove(repo)


@behave.when("I enable the repository \"{repo}\"")
def when_repo_condition(context, repo):
    context.execute_steps("Given I use the repository \"{}\"".format(repo))


@behave.given("There are no repositories")
def given_no_repos(context):
    context.dnf["reposdir"] = "/dev/null"
