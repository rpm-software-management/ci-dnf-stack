# -*- coding: utf-8 -*-
#
# Copyright 2015 dnf-stack-ci Authors. See the AUTHORS file
# found in the top-level directory of this distribution and
# at https://github.com/rholy/dnf-stack-ci/.
#
# Licensed under the GNU General Public License; either version 2,
# or (at your option) any later version. See the LICENSE file found
# in the top-level directory of this distribution and at
# https://github.com/rholy/dnf-stack-ci/. No part of dnf-stack-ci,
# including this file, may be copied, modified, propagated, or
# distributed except according to the terms contained in the LICENSE
# file.

Feature: Configure Copr projects
  In order to test the stack in Copr, I want to easily configure the
  relevant Copr projects.

  Scenario: Create Copr project
    Given following options are configured as follows:
       | Option  | Value              |
       | CHROOT  | rawhide            |
       | PROJECT | _dnf-stack-ci_test |
     When I create a Copr project
     Then I should have a Copr project called _dnf-stack-ci_test with chroots fedora-rawhide-i386, fedora-rawhide-ppc64le, fedora-rawhide-x86_64