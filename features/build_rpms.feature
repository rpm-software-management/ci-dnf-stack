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

Feature: Build RPMs of a project
  In order to test a project, I want to build its software packages.

  Background: Fedora Rawhide is added
    Given following options are configured as follows:
       | Option        |
       | --add-rawhide |

  Scenario: Build tito-enabled project
     When I build RPMs of the tito-enabled project
     Then I should have RPMs of the tito-enabled project

  Scenario: Build librepo fork
     When I build RPMs of the librepo project fork
     Then I should have RPMs of the librepo fork

  Scenario: Configure librepo release
    Given following options are configured as follows:
       | Option    | Value                                                    |
       | --release | 99.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm |
     When I build RPMs of the librepo project fork
     Then the release number of the resulting RPMs of the librepo fork should be 99.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm

  Scenario: Build libcomps fork
     When I build RPMs of the libcomps project fork
     Then I should have RPMs of the libcomps fork