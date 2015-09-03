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

Feature: Add repositories to build configurations
  In order to test a project with various dependencies, I want to add
  repositories to the build configurations.

  Scenario: Add URL to Copr project
    Given following options are configured as follows:
       | Option            | Value                  |
       | CHROOT            | rawhide                |
       | PROJECT           | _dnf-stack-ci_test     |
       | --add-repository  | http://www.example.com |
     When I create a Copr project
     Then I should have the http://www.example.com repository added to the Copr project called _dnf-stack-ci_test

  Scenario: Add Fedora 22 to config_opts['yum.conf']
    Given following options are configured as follows:
       | Option            | Value |
       | --add-non-rawhide | 22    |
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['yum.conf'] contains the Fedora 22 repository

  Scenario: Add Fedora Rawhide to config_opts['yum.conf']
    Given following options are configured as follows:
       | Option        |
       | --add-rawhide |
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['yum.conf'] contains the Rawhide repository

  Scenario: Add URL to config_opts['yum.conf']
    Given following options are configured as follows:
       | Option            | Value |
       | --add-repository  | $URL  |
       | --add-non-rawhide | 22    |
    Given “$URL” is replaced with the URL of a testing repository in all options
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['yum.conf'] contains the testing repository