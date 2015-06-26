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

Feature: Configure config_opts['root']
  In order to test various projects in parallel, I want to configure the
  value of the Mock's "config_opts['root']" option.

  Background: Fedora Rawhide is added
    Given following options are configured as follows:
       | Option        |
       | --add-rawhide |

  Scenario: Configure test-hawkey-x86_64-rawhide
    Given following options are configured as follows:
       | Option | Value                      |
       | --root | test-hawkey-x86_64-rawhide |
     When I build RPMs of the tito-enabled project
     Then I should have the result that is produced if config_opts['root'] == 'test-hawkey-x86_64-rawhide'