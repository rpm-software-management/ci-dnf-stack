# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import os
import parse

from common import *


@behave.step("I use the repository \"{repo}\"")
def step_repo_condition(context, repo):
    if "repos" not in context.dnf:
        context.dnf["repos"] = []
    if repo not in context.dnf["repos"]:
        context.dnf["repos"].append(repo)

@behave.step('I require client certificate verification with certificate "{client_cert}" and key "{client_key}"')
def step_impl(context, client_cert, client_key):
    if "client_ssl" not in context.dnf:
        context.dnf["client_ssl"] = dict()
    context.dnf["client_ssl"]["certificate"] = os.path.join(context.dnf.fixturesdir,
                                                            client_cert)
    context.dnf["client_ssl"]["key"] = os.path.join(context.dnf.fixturesdir,
                                                    client_key)

@parse.with_pattern(r"http|https")
def parse_repo_type(text):
    if text in ("http", "https"):
        return text
    assert False
behave.register_type(repo_type=parse_repo_type)

@behave.step("I use the {rtype:repo_type} repository based on \"{repo}\"")
def step_impl(context, rtype, repo):
    assert hasattr(context, 'httpd'), 'Httpd fixture not set. Use @fixture.httpd tag.'
    if rtype == "http":
        host, port = context.httpd.new_http_server(context.dnf.repos_location)
    else:
        cacert = os.path.join(context.dnf.fixturesdir,
                              'certificates/testcerts/ca/cert.pem')
        cert = os.path.join(context.dnf.fixturesdir,
                            'certificates/testcerts/server/cert.pem')
        key = os.path.join(context.dnf.fixturesdir,
                           'certificates/testcerts/server/key.pem')
        client_ssl = context.dnf._get(context, "client_ssl")
        if client_ssl:
            client_cert = client_ssl["certificate"]
            client_key = client_ssl["key"]
        host, port = context.httpd.new_https_server(
            context.dnf.repos_location, cacert, cert, key,
            client_verification=bool(client_ssl))
    http_reposdir = "/http.repos.d"
    repo_id = '{}-{}'.format(rtype, repo)
    repocfg = ("[{repo_id}]\n"
        "name={repo_id}\n"
        "baseurl={rtype}://{host}:{port}/{repo}/\n"
        "enabled=1\n"
        "gpgcheck=0\n"
        )
    if rtype == "https":
        repocfg += "sslcacert={cacert}\n"
        if client_ssl:
            repocfg += "sslclientcert={client_cert}\n"
            repocfg += "sslclientkey={client_key}\n"

    # generate repo file based on "repo" in /http.repos.d
    repos_path = os.path.join(context.dnf.installroot, http_reposdir.lstrip("/"))
    ensure_directory_exists(repos_path)
    repo_file_path = os.path.join(repos_path, '{}.repo'.format(repo_id))
    create_file_with_contents(
        repo_file_path,
        repocfg.format(**locals()))

    # add /http.repos.d to reposdir
    current_reposdir = context.dnf._get(context, "reposdir")
    if not repos_path in current_reposdir:
        context.dnf._set("reposdir", "{},{}".format(current_reposdir, repos_path))

    if not hasattr(context.dnf, "ports"):
        context.dnf._set("ports", {})

    context.dnf.ports[rtype + "-" + repo] = port

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
