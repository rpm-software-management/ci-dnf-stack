# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import os
import parse

from common import *
from common.rpmdb import get_rpmdb_rpms


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

@parse.with_pattern(r"http|https|ftp|metalink")
def parse_repo_type(text):
    if text in ("http", "https", "ftp", "metalink"):
        return text
    assert False
behave.register_type(repo_type=parse_repo_type)

@behave.step("I use the {rtype:repo_type} repository based on \"{repo}\"")
def step_impl(context, rtype, repo):
    assert (hasattr(context, 'httpd') or hasattr(context, 'ftpd')), \
        'Httpd or Ftpd fixture not set. Use @fixture.httpd or @fixture.ftpd tag.'

    metalink = False
    if rtype == "metalink":
        rtype = "http"
        metalink = True

    if rtype == "http":
        host, port = context.httpd.new_http_server(context.dnf.repos_location)
    elif rtype == "ftp":
        host, port = context.ftpd.new_ftp_server(context.dnf.repos_location)
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
    key = "baseurl"
    url = "{}://{}:{}/{}/".format(rtype, host, port, repo)
    if metalink:
        key = "metalink"
        url += "metalink.xml"
    repocfg = ("[{repo_id}]\n"
        "name={repo_id}\n"
        "{key}={url}\n"
        "enabled=1\n"
        "gpgcheck=0\n"
        )
    if rtype == "https":
        repocfg += "sslcacert={cacert}\n"
        if client_ssl:
            repocfg += "sslclientcert={client_cert}\n"
            repocfg += "sslclientkey={client_key}\n"

    data_path = os.path.join(context.dnf.repos_location, repo)
    generate_metalink(data_path, (rtype, host, port))

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


@behave.step("I am running a system identified as the \"{system}\"")
def given_system(context, system):
    data = dict(zip(('NAME', 'VERSION_ID', 'VARIANT_ID'), system.split(' ')))
    context.osrelease.set(data)


@behave.given("I am using {package} of the version X.Y.Z")
def given_package_version(context, package):
    rpms = [rpm for rpm in get_rpmdb_rpms() if rpm.name == package]
    assert len(rpms) == 1, 'There should be exactly one %s installed' % package
    context.versions = {package: rpms[0].version}


@behave.step("I have enabled a remote repository")
def step_remote_repo(context):
    context.execute_steps('when I use the http repository based on "dnf-ci-fedora"')


@behave.step("{quantifier} HTTP {command} request should match")
def step_check_http_log(context, quantifier, command):
    # Obtain the httpd log
    path = context.dnf.repos_location
    log = context.httpd.get_log(path)
    assert log is not None, 'Logging should be enabled on the HTTP server'
    log = [rec for rec in log if rec.command == command]
    context.httpd.clear_log(path)
    assert log, 'Some HTTP requests should have been received'

    # A log dump, printed on failures for convenience
    dump = '\n' + '\n'.join(map(str, log)) + '\n'

    # Requests matching the table
    matches = []

    # Detect what kind of data we have in the table
    headings = context.table.headings
    if 'header' in headings:
        # Expand any X.Y.Z version strings in the User-Agent header (we need to
        # copy the context table for that)
        table = []
        for row in context.table:
            header, value = row['header'], row['value']
            version = None
            if header == 'User-Agent' and hasattr(context, 'versions'):
                package = value.split('/')[0]
                version = context.versions.get(package)
                if version is not None:
                    value = value.replace('X.Y.Z', version)
            table.append({'header': header, 'value': value})

        headers = (rec.headers for rec in log)
        matches = (row['value'] == h[row['header']]
                   for h in headers
                   for row in table)

    if quantifier == 'every':
        assert all(matches), 'Every request should match the table: ' + dump
