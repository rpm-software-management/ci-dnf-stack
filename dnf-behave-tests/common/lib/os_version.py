# -*- coding: utf-8 -*-

import distro


def detect_os_version():
    os_id = distro.id()

    # treat centos as RHEL in context of scenario tag matching
    if os_id == "centos":
        os_id = "rhel"

    return os_id + "__" + distro.major_version()
