# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
from fnmatch import fnmatch
import os
import parse

from common import *
from common.rpmdb import get_rpmdb_rpms
from environment import osrelease


def repo_config(repo, new={}):
    config = {
        "name": repo + " test repository",
        "enabled": "1",
        "gpgcheck": "0",
    }
    config.update(new)
    return config


def write_repo_config(context, repo, config, path=None):
    path = path or os.path.join(context.dnf.installroot, "etc/yum.repos.d/")

    conf_text = "[%s]\n" % repo
    for key, value in config.items():
        if value:
            conf_text += ("%s=%s\n" % (key, value)).format(repo=repo, context=context)

    create_file_with_contents(os.path.join(path, repo + ".repo"), conf_text)


class RepoInfo(object):
    def __init__(self, context, repo):
        self.active = False
        self.path = os.path.join(context.dnf.repos_location, repo)
        self.config = repo_config(repo, {"baseurl": "file://" + self.path})

    def update_config(self, new_conf):
        self.config.update(new_conf)


def get_repo_info(context, repo):
    return context.dnf.repos.setdefault(repo, RepoInfo(context, repo))


def create_repo_conf(context, repo):
    repo_info = get_repo_info(context, repo)
    repo_info.active = True

    write_repo_config(context, repo, repo_info.config)


def generate_repodata(context, repo):
    if repo in context.repos:
        return

    args = "--no-database --simple-md-filenames --revision=1550000000"

    groups_filename = os.path.join(context.dnf.fixturesdir, "specs", repo, "comps.xml")
    if os.path.isfile(groups_filename):
        args += " --groupfile " + groups_filename

    target_path = os.path.join(context.dnf.repos_location, repo)

    run_in_context(context, "createrepo_c %s %s" % (args, target_path))

    repodata_path = os.path.join(target_path, "repodata")

    updateinfo_filename = os.path.join(context.dnf.fixturesdir, "specs", repo, "updateinfo.xml")
    if os.path.isfile(updateinfo_filename):
        run_in_context(context, "modifyrepo_c %s %s" % (updateinfo_filename, repodata_path))

    modules_filename = os.path.join(context.dnf.fixturesdir, "specs", repo, "modules.yaml")
    if os.path.isfile(modules_filename):
        run_in_context(context, "modifyrepo_c --mdtype=modules %s %s" % (modules_filename, repodata_path))

    context.repos[repo] = True


def start_server_based_on_type(context, server_dir, rtype, certs=None):
    if rtype == "http":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'
        host, port = context.httpd.new_http_server(server_dir)
    elif rtype == "ftp":
        assert (hasattr(context, 'ftpd')), 'Ftpd fixture not set. Use @fixture.ftpd tag.'
        host, port = context.ftpd.new_ftp_server(server_dir)
    elif rtype == "https":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'

        host, port = context.httpd.new_https_server(
            server_dir, certs["cacert"], certs["cert"], certs["key"],
            client_verification=bool(context.dnf._get("client_ssl")))
    else:
        raise AssertionError("Unknown server type: %s" % rtype)

    return host, port


@behave.step("I use repository \"{repo}\"")
def step_use_repository(context, repo):
    """
    Creates the repository's config file at /etc/yum.repos.d/ (inside installroot).
    """
    generate_repodata(context, repo)
    create_repo_conf(context, repo)


@behave.step("I configure repository \"{repo}\" with")
def step_configure_repository(context, repo):
    """
    Sets the repository configuration (i.e. the contents of its config file).
    If the repository is used, overwrites its config file with the new
    configuration.
    """
    check_context_table(context, ["key", "value"])

    repo_info = get_repo_info(context, repo)
    repo_info.update_config(dict(context.table))
    if repo_info.active:
        create_repo_conf(context, repo)


@behave.step("I use repository \"{repo}\" with configuration")
def step_use_repository_with_config(context, repo):
    """
    Sets the repository configuration (i.e. the contents of its config file)
    and creates its config file at /etc/yum.repos.d/ (inside installroot).
    """
    check_context_table(context, ["key", "value"])

    generate_repodata(context, repo)
    get_repo_info(context, repo).update_config(dict(context.table))
    create_repo_conf(context, repo)


@behave.step("I drop repository \"{repo}\"")
def step_drop_repository(context, repo):
    """
    Deletes the repository's config file from /etc/yum.repos.d/ (inside installroot).
    """
    assert repo in context.dnf.repos, 'Repository "%s" was never used.' % repo

    delete_file(os.path.join(context.dnf.installroot, "etc/yum.repos.d/", repo + ".repo"))
    get_repo_info(context, repo).active = False


@behave.step("I copy repository \"{repo}\" for modification")
def step_copy_repository(context, repo):
    """
    Copies the whole contents of the repository directory (i.e. the packages
    and repodata) to a temp directory of the current scenario. Use this if you
    need to modify the data of this directory, so that the original repository
    data stay unchanged for the other tests.
    """
    generate_repodata(context, repo)
    repo_info = get_repo_info(context, repo)
    dst = os.path.join(context.dnf.tempdir, "repos", repo)
    copy_tree(repo_info.path, dst)
    repo_info.path = dst
    repo_info.update_config({"baseurl": dst})


@behave.step("I configure a new repository \"{repo}\" in \"{path}\" with")
def step_configure_new_repository_in(context, repo, path):
    """
    Creates a new repository config at `path` with the default values overriden
    with what is in the context table.
    """
    check_context_table(context, ["key", "value"])
    path = path.format(context=context)
    ensure_directory_exists(path)

    write_repo_config(context, repo, repo_config(repo, dict(context.table)), path)


@behave.step("I configure a new repository \"{repo}\" with")
def step_configure_new_repository(context, repo):
    """
    Creates a new repository config at the default location (/etc/yum.repos.d/
    inside installroot) with the default values overriden with what is in the
    context table.
    """
    check_context_table(context, ["key", "value"])

    write_repo_config(context, repo, repo_config(repo, dict(context.table)))


@parse.with_pattern(r"http|https|ftp")
def parse_repo_type(text):
    if text in ("http", "https", "ftp"):
        return text
    assert False
behave.register_type(repo_type=parse_repo_type)


@behave.step("I make packages from repository \"{repo}\" accessible via {rtype:repo_type}")
def make_repo_packages_accessible(context, repo, rtype):
    """
    Starts a new HTTP/FTP server at the repository's location and saves
    its port to context.
    """
    repo_info = get_repo_info(context, repo)
    server_dir = repo_info.path
    host, port = start_server_based_on_type(context, server_dir, rtype)
    context.dnf.ports[repo] = port


@behave.step("I use repository \"{repo}\" as {rtype:repo_type}")
def step_use_repository_as(context, repo, rtype):
    """
    Starts a new HTTP/FTP server at the repository's location and then
    configures the repository's baseurl with the server's url.
    """
    repo_info = get_repo_info(context, repo)
    server_dir = repo_info.path

    if rtype == "https":
        certs = {
            "cacert": os.path.join(context.dnf.fixturesdir, 'certificates/testcerts/ca/cert.pem'),
            "cert": os.path.join(context.dnf.fixturesdir, 'certificates/testcerts/server/cert.pem'),
            "key": os.path.join(context.dnf.fixturesdir, 'certificates/testcerts/server/key.pem'),
        }
        host, port = start_server_based_on_type(context, server_dir, rtype, certs)
    else:
        host, port = start_server_based_on_type(context, server_dir, rtype)

    config = {
        "baseurl": "{}://{}:{}/".format(rtype, host, port)
    }

    if rtype == "https":
        client_ssl = context.dnf._get("client_ssl")

        config["sslcacert"] = certs["cacert"]
        if client_ssl:
            config["sslclientcert"] = client_ssl["certificate"]
            config["sslclientkey"] = client_ssl["key"]

    context.dnf.ports[repo] = port

    repo_info.update_config(config)
    generate_repodata(context, repo)
    create_repo_conf(context, repo)


@behave.step("I set up metalink for repository \"{repo}\"")
def step_set_up_metalink_for_repository(context, repo):
    """
    Generates a metalink for a repository and configures the repository with
    the 'metalink' config option, which points to the newly created file.

    Note that you need to copy the repository using the "I copy repository for
    modification" step beforehand and if you're using a HTTP server, the
    sequence of steps needs to be this:
      I copy repository "foo" for modification
      I use repository "foo" as http
      I set up metalink for repository "foo"
    """
    repo_info = get_repo_info(context, repo)
    assert repo_info.path.startswith(context.dnf.tempdir), \
        "Creating a metalink needs to be done on a repo that was copied for modification."

    url = repo_info.config['baseurl']
    generate_metalink(repo_info.path, url)
    repo_info.update_config({
        "baseurl": "",
        "metalink": url + "metalink.xml",
    })
    create_repo_conf(context, repo)


@behave.step("the server starts responding with HTTP status code {code}")
def step_server_down(context, code):
    context.httpd.conf['status'] = int(code)


@behave.step("I start capturing outbound HTTP requests")
def step_start_http_capture(context):
    context.httpd.conf['logging'] = True


@behave.step('I require client certificate verification with certificate "{client_cert}" and key "{client_key}"')
def step_impl(context, client_cert, client_key):
    if "client_ssl" not in context.dnf:
        context.dnf["client_ssl"] = dict()
    context.dnf["client_ssl"]["certificate"] = os.path.join(context.dnf.fixturesdir,
                                                            client_cert)
    context.dnf["client_ssl"]["key"] = os.path.join(context.dnf.fixturesdir,
                                                    client_key)


@behave.step("I forget any HTTP requests captured so far")
def step_clear_http_logs(context):
    context.httpd.clear_log()


@behave.step("I am running a system identified as the \"{system}\"")
def given_system(context, system):
    behave.use_fixture(osrelease, context)
    data = dict(zip(('NAME', 'VERSION_ID', 'VARIANT_ID'), system.split(' ')))
    context.osrelease.set(data)


@behave.step("I remove the os-release file")
def given_no_osrelease(context):
    behave.use_fixture(osrelease, context)
    context.osrelease.delete()


@behave.step("{quantifier} HTTP {command} request should match")
@behave.step("{quantifier} HTTP {command} requests should match")
def step_check_http_log(context, quantifier, command):
    # Obtain the httpd log for this command
    log = [record
           for record in context.httpd.log
           if record.command == command]
    assert log, 'No HTTP requests have been received!'

    # Find matches
    if 'header' in context.table.headings:
        good = [record
                for record in log
                for row in context.table
                if record.headers[row['header']] == row['value']]
    elif 'path' in context.table.headings:
        good = [record
                for record in log
                for row in context.table
                if fnmatch(record.path, row['path'])]
    else:
        assert False, 'No supported column heading found in the table'

    bad = [record for record in log if record not in good]

    def dump(log):
        return '\n' + '\n'.join(map(str, log)) + '\n'

    if quantifier == 'every':
        assert not bad, \
            '%i requests did not match:%s' \
            % (len(bad), dump(bad))
    elif quantifier.startswith('exactly '):
        num = quantifier.split(' ')[1]
        if num == 'one':
            num = 1
        num = int(num)
        assert len(good) == num, \
            'Expected %i matches but got %i instead, full log:%s' \
            % (num, len(good), dump(log))
    elif quantifier == 'no':
        assert not good, \
            'Expected no matches but got %i:%s' \
            % (len(good), dump(good))
