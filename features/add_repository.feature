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

Feature: Add repositories to config_opts['yum.conf']
  In order to test a project with various dependencies, I want to add
  repositories to the Mock's "config_opts['yum.conf']" option.

  Scenario: Add Fedora 22
    Given following options are configured as follows:
       | Option            | Value |
       | --add-non-rawhide | 22    |
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['yum.conf'] contains the Fedora 22 repository

  Scenario: Add Fedora Rawhide
    Given following options are configured as follows:
       | Option        |
       | --add-rawhide |
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['yum.conf'] contains the Rawhide repository