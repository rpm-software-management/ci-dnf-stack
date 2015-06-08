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

Feature: Configure target system release version
  In order to test a project on various systems, I want to configure the
  release version of the target system.

  Scenario: Configure Fedora 22
    Given following options are configured as follows:
       | Option   | Value |
       | --fedora | 22    |
     When I execute this program
     Then I should have the result for Fedora 22