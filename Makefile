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


MAKE        := make
SH          := sh

# For recursive calls
WHAT        :=


.PHONY: all src-make clean compile install setup test remove purge
.PHONY: public-clean public-regen

all: compile


src-make:
	cd ./src && $(MAKE) DEPS-FLAGS=" --no-pkg-deps " $(WHAT)


clean:
	$(MAKE) src-make WHAT=clean

compile:
	$(MAKE) src-make WHAT=compile

install:
	$(MAKE) src-make WHAT=install

setup:
	$(MAKE) src-make WHAT=setup

test:
	$(MAKE) src-make WHAT=test

remove:
	$(MAKE) src-make WHAT=remove

purge:
	$(MAKE) src-make WHAT=purge


exe:
	$(MAKE) src-make WHAT=exe
	cp -r ./src/bin .


public:
	$(SH) ./scripts/public.sh

public-clean:
	rm -dfr ./public

public-regen: public-clean public
