# -*- coding: utf-8 -*-
#
# Copyright 2015 ci-dnf-stack Authors. See the AUTHORS file
# found in the top-level directory of this distribution and
# at https://github.com/rpm-software-management/ci-dnf-stack/.
#
# Licensed under the GNU General Public License; either version 2,
# or (at your option) any later version. See the LICENSE file found
# in the top-level directory of this distribution and at
# https://github.com/rpm-software-management/ci-dnf-stack. No part
# of ci-dnf-stack, including this file, may be copied, modified,
# propagated, or distributed except according to the terms contained
# in the LICENSE file.

Feature: Configure Copr projects
  In order to test the stack in Copr, I want to easily configure the
  relevant Copr projects.

  Scenario: Create Copr project
    Given following options are configured as follows:
       | Option  | Value              |
       | CHROOT  | rawhide            |
       | PROJECT | _ci-dnf-stack_test |
     When I create a Copr project
     Then I should have a Copr project called _ci-dnf-stack_test with chroots fedora-rawhide-i386, fedora-rawhide-x86_64

  Scenario: Add URL to Copr project
    Given following options are configured as follows:
       | Option            | Value                  |
       | CHROOT            | rawhide                |
       | PROJECT           | _ci-dnf-stack_test     |
       | --add-repository  | http://www.example.com |
     When I create a Copr project
     Then I should have the http://www.example.com repository added to the Copr project called _ci-dnf-stack_test