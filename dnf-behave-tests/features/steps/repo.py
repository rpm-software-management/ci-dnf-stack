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
