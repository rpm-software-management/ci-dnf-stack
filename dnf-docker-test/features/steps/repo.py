try:
    from configparser import ConfigParser
except ImportError:
    from ConfigParser import ConfigParser
import glob
import os
import sys
import behave
import rpmfluff

@behave.given("set of repositories")
def step_impl(ctx):
    assert ctx.table, "Table not found"
    assert ctx.table.headings == ["key", "value"], "Wrong heading: {!r}".format(ctx.table.headings)

    repos = {}
    first = True
    package = None
    for k, v in ctx.table:
        if first:
            assert k == "Repository", "First key must be 'Repository', not {!r}".format(k)
            first = False
        if k == "Repository":
            repo = v
            assert repo not in repos, "Duplicate repository: {!r}".format(repo)
            repos[repo] = []
            pkgs = repos[repo]
            continue
        elif k == "Package":
            name = v
            package = {"Name": name}
            pkgs.append(package)
            continue
        assert package, "Package properties belongs to package, not otherwise"
        assert k not in package, "Duplicate key {!r} for package {!r}/{!r}".format(k, repo, name)
        package[k] = v

    repositories = {}
    for repo, packages in repos.items():
        pkgs = []
        for package in packages:
            name = package.pop("Name")
            version = package.pop("Version", None)
            assert version, "'Version' is not set for package: {!r}/{!r}".format(repo, name)
            release = package.pop("Release", None)
            assert release, "'Release' is not set for package: {!r}/{!r}".format(repo, name)
            build_arch = package.pop("BuildArch", "noarch")
            if build_arch != "noarch":
                raise NotImplementedError("non-noarch packages not supported")
            requires = package.pop("Requires", None)
            provides = package.pop("Provides", None)
            obsoletes = package.pop("Obsoletes", None)
            assert not package, "Additional keys given for {!r}/{!r} package: {!r}".format(
                repo, name, package.keys())
            pkg = rpmfluff.SimpleRpmBuild(name, version, release, [build_arch])
            if requires:
                pkg.add_requires(requires)
            if provides:
                pkg.add_provides(provides)
            if obsoletes:
                pkg.add_obsoletes(obsoletes)
            pkgs.append(pkg)
        repository = rpmfluff.YumRepoBuild(pkgs)
        repository.make("noarch")
        repofile = ConfigParser()
        settings = {"name": repo,
                    "enabled": True,
                    "gpgcheck": False,
                    "baseurl": "file://{!s}".format(repository.repoDir)}
        if sys.version_info.major < 3:
            repofile.add_section(repo)
            for k, v in settings.items():
                repofile.set(repo, k, v)
        else:
            repofile[repo] = settings
        repositories[repo] = repofile

    # Remove existing repos
    for f in glob.glob("/etc/yum.repos.d/*.repo"):
        os.remove(f)
    for repo, repofile in repositories.items():
        with open("/etc/yum.repos.d/{!s}.repo".format(repo), "w") as fd:
            repofile.write(fd)
