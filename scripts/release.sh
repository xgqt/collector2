#!/bin/sh


# This file is part of collector2.

# collector2 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.

# collector2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with collector2.  If not, see <https://www.gnu.org/licenses/>.

# Original author: Maciej Barć <xgqt@riseup.net>
# Copyright (c) 2021-2022, src_prepare group
# Licensed under the GNU GPL v3 License
# SPDX-License-Identifier: GPL-3.0-only


trap 'exit 128' INT
set -e
export PATH


myroot="$( realpath "$( dirname "${0}" )/../" )"

cd "${myroot}"


MAJOR="${1}"
MINOR="${2}"
PATCH="${3}"

WHOLE="${MAJOR}.${MINOR}.${PATCH}"

cat <<EOF
MAJOR:  ${MAJOR}
MINOR:  ${MINOR}
PATCH:  ${PATCH}
WHOLE:  ${WHOLE}
EOF

if [ -z "${PATCH}" ] ; then
    echo
    echo "[ERROR] Pass 3 arguments,"
    echo "representing MAJOR, MINOR and PATCH release numbers"
    exit 1
fi


sed -i "s|(values .*|(values ${MAJOR} ${MINOR} ${PATCH}))|g"  \
    src/collector2-lib/collector2/version.rkt

racket ./scripts/bump.rkt

git add .
git commit -m "*/info.rkt: bump to ${WHOLE}" --signoff
git tag "${WHOLE}" -m "bump to ${WHOLE}" --sign
