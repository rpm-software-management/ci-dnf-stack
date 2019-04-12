# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import os

from common import *


@behave.step("I use the repository \"{repo}\"")
def step_repo_condition(context, repo):
    if "repos" not in context.dnf:
        context.dnf["repos"] = []
    if repo not in context.dnf["repos"]:
        context.dnf["repos"].append(repo)


@behave.step("I use the http repository based on \"{repo}\"")
def step_impl(context, repo):
    assert hasattr(context, 'httpd'), 'Httpd fixture not set. Use @fixture.httpd tag.'
    host, port = context.httpd.start_new_server(context.dnf.repos_location)
    http_reposdir = "/http.repos.d"
    repo_id = 'http-{}'.format(repo)
    repocfg = ("[{repo_id}]\n"
        "name={repo_id}\n"
        "baseurl=http://{host}:{port}/{repo}/\n"
        "enabled=1\n"
        "gpgcheck=0\n")

    # generate repo file based on "repo" in /http.repos.d
    repos_path = os.path.join(context.dnf.installroot, http_reposdir.lstrip("/"))
    ensure_directory_exists(repos_path)
    repo_file_path = os.path.join(repos_path, '{}.repo'.format(repo_id))
    create_file_with_contents(
        repo_file_path,
        repocfg.format(repo_id=repo_id, repo=repo, host=host, port=port))

    # add /http.repos.d to reposdir
    current_reposdir = context.dnf._get(context, "reposdir")
    if not repos_path in current_reposdir:
        context.dnf._set("reposdir", "{},{}".format(current_reposdir, repos_path))

    # enable newly created http repo
    context.execute_steps('Given I use the repository "{}"'.format(repo_id))

@behave.step("I disable the repository \"{repo}\"")
def step_repo_condition(context, repo):
    if "repos" not in context.dnf:
        context.dnf["repos"] = []
    context.dnf["repos"].remove(repo)


@behave.given("There are no repositories")
def given_no_repos(context):
    context.dnf["reposdir"] = "/dev/null"
