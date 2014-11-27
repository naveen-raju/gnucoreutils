#!/bin/sh
# Verify that internal failure in chroot gives exact status.

# Copyright (C) 2009-2014 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ chroot

require_built_ chroot

# These tests verify exact status of internal failure; since none of
# them actually run a command, we don't need root privileges
chroot # missing argument
test $? = 125 || fail=1
chroot --- / true # unknown option
test $? = 125 || fail=1

# Note chroot("/") succeeds for non-root users on some systems, but not all,
# however we avoid the chroot() with "/" to have common behvavior.
chroot / sh -c 'exit 2' # exit status propagation
test $? = 2 || fail=1
chroot / . # invalid command
test $? = 126 || fail=1
chroot / no_such # no such command
test $? = 127 || fail=1

# Ensure we don't chdir("/") when not changing root
# to allow only changing user ids for a command.
for dir in '/' '/.' '/../'; do
  curdir=$(chroot "$dir" env pwd) || fail=1
  test "$curdir" = '/' && fail=1
done

Exit $fail