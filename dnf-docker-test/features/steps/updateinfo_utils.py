#!/usr/bin/python

import os
import re
import gzip
import xml.dom.minidom
import ConfigParser

REPO_TMPL = "/etc/yum.repos.d/{!s}.repo"


def get_repo_dir(repository):
    repo_prefixes = {'file://': '', 'http://localhost': '/var/www/html', 'ftp://localhost': '/var/ftp'}
    repofile = REPO_TMPL.format(repository)
    config = ConfigParser.ConfigParser()
    config.read(repofile)
    baseurl = config.get(config.sections()[0], 'baseurl')
    for prefix in repo_prefixes:
        if baseurl.startswith(prefix):
            return baseurl.replace(prefix, repo_prefixes[prefix])
    return ''


def get_repodata_file_path(regexp, repository):
    repodir = get_repo_dir(repository)
    if repodir:
        repodata_dir = os.path.join(repodir, "repodata")
        filenames = os.listdir(repodata_dir)
        for filename in filenames:
            if re.match(regexp, filename):
                return os.path.join(repodir, "repodata", filename)
    return ''


def parse_pkg_details_from_primary_xml_gz(filename):
    f = gzip.open(filename, 'rb')
    doc = xml.dom.minidom.parse(f)
    f.close()
    pkg_dict = {}
    for pkg in doc.getElementsByTagName('package'):
        d = {}
        d['pkg_filename'] = pkg.getElementsByTagName("location")[0].getAttribute("href").split("/")[-1]
        d['pkg_name'] = pkg.getElementsByTagName("name")[0].firstChild.data
        d['pkg_version'] = pkg.getElementsByTagName("version")[0].getAttribute("ver")
        d['pkg_release'] = pkg.getElementsByTagName("version")[0].getAttribute("rel")
        d['pkg_epoch'] = pkg.getElementsByTagName("version")[0].getAttribute("epoch")
        d['pkg_arch'] = pkg.getElementsByTagName("arch")[0].firstChild.data
        d['pkg_src'] = pkg.getElementsByTagName("rpm:sourcerpm")[0].firstChild.data
        d['pkg_sum'] = pkg.getElementsByTagName("checksum")[0].firstChild.data
        d['pkg_sumtype'] = pkg.getElementsByTagName("checksum")[0].getAttribute("type")
        pkg_dict[d['pkg_filename']] = d
    return pkg_dict


def build_updateinfo_xml_elem_update(update, pkg_details):
    doc = xml.dom.minidom.Document()
    elem_update = doc.createElement("update")
    elem_update.setAttribute("from", "nobody@dnf.baseurl.org")
    elem_update.setAttribute("status", "final")
    elem_update.setAttribute("type", update.get('Type', 'security'))
    elem_update.setAttribute("version", "1")
    # id
    elem = doc.createElement("id")
    cnt = doc.createTextNode(update['Id'])
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # title
    elem = doc.createElement("title")
    cnt = doc.createTextNode(update.get('Title', 'Default title of %s' % update['Id']))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # severity
    elem = doc.createElement("severity")
    cnt = doc.createTextNode(update.get('Severity', 'Low'))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # issued
    elem = doc.createElement("issued")
    elem.setAttribute("date", update.get('Issued', '2017-01-01 00:00:01'))
    elem_update.appendChild(elem)
    # updated
    elem = doc.createElement("updated")
    elem.setAttribute("date", update.get('Updated', '2017-01-01 00:00:01'))
    elem_update.appendChild(elem)
    # rights
    elem = doc.createElement("rights")
    cnt = doc.createTextNode(update.get('Rights', 'nobody'))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # summary
    elem = doc.createElement("summary")
    cnt = doc.createTextNode(update.get('Summary', 'Default summary of %s' % update['Id']))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # description
    elem = doc.createElement("description")
    cnt = doc.createTextNode(update.get('Description', 'Default description of %s' % update['Id']))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # solution
    elem = doc.createElement("solution")
    cnt = doc.createTextNode(update.get('Solution', 'Default solution of %s' % update['Id']))
    elem.appendChild(cnt)
    elem_update.appendChild(elem)
    # references
    references = doc.createElement("references")
    cnt = doc.createElement("reference")
    cnt.setAttribute("href", "www.path.to/nowhere")
    cnt.setAttribute("type", "self")
    cnt.setAttribute("title", update['Id'])
    references.appendChild(cnt)
    if 'Reference' in update:
        for ref in update['Reference']:
            cnt = doc.createElement("reference")
            cnt.setAttribute("href", "www.path.to/%s" % ref)
            cnt.setAttribute("title", ref)
            if ref.startswith('BZ'):
                cnt.setAttribute("id", ref[2:])
                cnt.setAttribute("type", 'bugzilla')
            if ref.startswith('CVE'):
                cnt.setAttribute("id", ref)
                cnt.setAttribute("type", 'cve')
            references.appendChild(cnt)
    elem_update.appendChild(references)
    # pkglist
    pkglist = doc.createElement("pkglist")
    elem_update.appendChild(pkglist)
    # collection
    collection = doc.createElement("collection")
    collection.setAttribute("short", update.get('Collection', 'Default collection'))
    pkglist.appendChild(collection)
    # collection <name>
    elem = doc.createElement("name")
    cnt = doc.createTextNode(update.get('Collection', 'Default collection'))
    elem.appendChild(cnt)
    collection.appendChild(elem)
    # now for every package I need to prepare this based on the details obtained from primary.xml
    # <package name="PKG_NAME" version="3.0.33" release="3.29.el5_5.1" epoch="0" arch="i386" src="samba-3.0.33-3.29.el5_5.1.src.rpm">
    # <filename>libsmbclient-3.0.33-3.29.el5_5.1.i386.rpm</filename>
    # <sum type="md5">b5ea308c42fa07a4e59dd7b00c6a9db8</sum>
    # </package>
    for pkg in update['Package']:
        # find the best match in available rpms stored in pkg_details dict
        rpms = [rpm for rpm in pkg_details.keys() if rpm.startswith(pkg)]
        rpms.sort()
        rpm = rpms[-1]  # take the last one as that should be the _latest_ version
        # create new package element
        package = doc.createElement("package")
        package.setAttribute("name", pkg_details[rpm]['pkg_name'])
        package.setAttribute("version", pkg_details[rpm]['pkg_version'])
        package.setAttribute("release", pkg_details[rpm]['pkg_release'])
        package.setAttribute("epoch", pkg_details[rpm]['pkg_epoch'])
        package.setAttribute("arch", pkg_details[rpm]['pkg_arch'])
        package.setAttribute("src", pkg_details[rpm]['pkg_src'])
        elem = doc.createElement("filename")
        cnt = doc.createTextNode(rpm)
        elem.appendChild(cnt)
        package.appendChild(elem)
        elem = doc.createElement("sum")
        elem.setAttribute("type", pkg_details[rpm]['pkg_sumtype'])
        cnt = doc.createTextNode(pkg_details[rpm]['pkg_sum'])
        elem.appendChild(cnt)
        package.appendChild(elem)
        # add package into collection
        collection.appendChild(package)
    return elem_update


def get_updateinfo_xml(repository, updateinfo_table):
    primary_xml = get_repodata_file_path('.*primary.xml.gz$', repository)
    pkg_details = parse_pkg_details_from_primary_xml_gz(primary_xml)
    # prepare updateinfo.xml document
    doc = xml.dom.minidom.Document()
    updates = doc.createElement("updates")
    doc.appendChild(updates)
    for id in updateinfo_table:
        updateinfo_table[id]['Id'] = id
        elem = build_updateinfo_xml_elem_update(updateinfo_table[id], pkg_details)
        updates.appendChild(elem)
    return doc.toxml()
