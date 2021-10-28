#!/bin/sh


# This file is part of racket-ebuild.

# racket-ebuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.

# racket-ebuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with racket-ebuild.  If not, see <https://www.gnu.org/licenses/>.

# Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>
# Licensed under the GNU GPL v3 License
# SPDX-License-Identifier: GPL-3.0-only


trap 'exit 128' INT
set -e
export PATH


myroot="$( dirname "${0}" )/../"
cd "${myroot}/src/"

MAKE="$( command -v gmake || command -v make )"
[ -z "${MAKE}" ] && exit 1

${MAKE} "${@}"
