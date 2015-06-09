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

Feature: Define RPM macros
  In order to test a project with a particular RPM macro, I want to
  define it.

  Scenario: Define one macro
    Given following options are configured as follows:
       | Option   | Value #1 | Value #2                                               |
       | --define | snapshot | .2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm |
     When I execute this program
     Then I should have the result that is produced if %{snapshot} == '.2.20150102git3a45678901b23c456d78ef90g1234hijk56789lm'