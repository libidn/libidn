#!/bin/sh

# Copyright (C) 2024-2025 Simon Josefsson
#
# This file is part of GNU Libidn.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# standalone.sh: build and run libidn's C-based test suite.
#
# To check that system libidn behaves:
#
# tests/standalone.sh
#
# To check that a newly built static libidn behaves:
#
# env STANDALONE_CFLAGS="-Ilib lib/.libs/libidn.a" tests/standalone.sh
#
# To check that a newly built shared libidn behaves:
#
# env STANDALONE_CFLAGS="-Ilib -Wl,-rpath lib/.libs lib/.libs/libidn.so" tests/standalone.sh

set -e

srcdir="${srcdir:-$(dirname "$0")}"
STANDALONE_CC="${CC:-cc}"
STANDALONE_CFLAGS="${STANDALONE_CFLAGS:-$(pkg-config --cflags --libs libidn)}"

echo "srcdir=$srcdir"
echo "STANDALONE_CC: $STANDALONE_CC"
echo "STANDALONE_CFLAGS: $STANDALONE_CFLAGS"

rc=0

for f in "$srcdir"/tst_*.c; do
    ADD=yes
    test "$f" = "$srcdir"/tst_versions.c && ADD=
    if $STANDALONE_CC -o foo "$f" $STANDALONE_CFLAGS ${ADD:+-DWITH_TLD=1 "$srcdir"/utils.c}; then
        echo "PASS: cc $f"
        if ./foo; then
            echo "PASS: run $f"
        else
            echo "FAIL: run $f"
	    rc=1
        fi
    else
        echo "FAIL: cc $f"
	rc=1
    fi
done

rm -f foo

exit $rc
