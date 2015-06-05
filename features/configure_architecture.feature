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

Feature: Configure config_opts['target_arch']
  In order to test a project on various systems, I want to configure the
  value of the Mock's "config_opts['target_arch']" option.

  Scenario: Configure i686
    Given following options are configured as follows:
       | Option       | Value |
       | ARCHITECTURE | i686  |
     When I execute this program
     Then I should have the result that is produced if config_opts['target_arch'] == 'i686'