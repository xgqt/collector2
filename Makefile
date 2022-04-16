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


.PHONY: all src-make-%
.PHONY: clean compile install setup test remove
.PHONY: public-clean public-regen

all: clean compile


src-make-%:
	$(MAKE) -C $(PWD)/src DEPS-FLAGS=" --no-pkg-deps " $(*)


clean: src-make-clean

compile: src-make-compile

install: src-make-install

setup: src-make-setup

test: src-make-test

remove: src-make-remove


bin: src-make-exe
	cp -r ./src/bin .


public:
	$(SH) $(PWD)/scripts/public.sh

public-clean:
	rm -dfr $(PWD)/public

public-regen: public-clean public
