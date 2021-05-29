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
# Copyright (c) 2021, src_prepare group
# Licensed under the GNU GPL v3 License
# SPDX-License-Identifier: GPL-3.0-only


PACKAGE-NAME		:= $(shell basename $(abspath .))
PACKAGE-EXE			:= $(PACKAGE-NAME)
PACKAGE-BIN-DIR		:= ./bin
PACKAGE-BIN			:= $(PACKAGE-BIN-DIR)/$(PACKAGE-EXE)
PACKAGE-ZIP			:= $(PACKAGE-NAME).zip

RACKET				:= racket
RACO				:= raco

ENTRYPOINT			:= $(PACKAGE-NAME)/main.rkt
COMPILE-FLAGS		:= -v
RUN-FLAGS			:=
EXE-FLAGS			:= --orig-exe -v -o $(PACKAGE-BIN)
DO-DOCS				:= --no-docs
INSTALL-FLAGS		:= --auto $(DO-DOCS)
DEPS-FLAGS			:= --check-pkg-deps --unused-pkg-deps
TEST-FLAGS			:= --heartbeat --no-run-if-absent --submodule test --table


all:	install setup test

compile:
	$(RACO) make $(COMPILE-FLAGS) $(ENTRYPOINT)

run:
	$(RACKET) $(RUN-FLAGS) $(ENTRYPOINT)

install:
	$(RACO) pkg install $(INSTALL-FLAGS) --name $(PACKAGE-NAME)


# Distribution

exe:	compile
	mkdir -p ./bin
	$(RACO) exe $(EXE-FLAGS) $(ENTRYPOINT)

# Source only
pkg:	clean
	$(RACO) pkg create --source $(PWD)


# Removal

distclean:
	if [ -d $(PACKAGE-BIN-DIR) ] ; then rm -r $(PACKAGE-BIN-DIR) ; fi
	if [ -f $(PACKAGE-ZIP) ] ; then rm $(PACKAGE-ZIP)* ; fi

clean:	distclean
	find . -depth -type d -name 'compiled' -exec rm -r {} \;
	find . -depth -type d -name 'doc'      -exec rm -r {} \;

remove:
	$(RACO) pkg remove $(DO-DOCS) $(PACKAGE-NAME)

purge:	remove clean

reinstall:	remove install

resetup:	reinstall setup


# Tests

# This builds docs
setup:
	$(RACO) setup --tidy --avoid-main $(DEPS-FLAGS) --pkgs $(PACKAGE-NAME)

check-deps:
	$(RACO) setup $(DO-DOCS) $(DEPS-FLAGS) $(PACKAGE-NAME)

test-local:
	$(RACO) test $(TEST-FLAGS) ./$(PACKAGE-NAME)

test:
	$(RACO) test $(TEST-FLAGS) --package $(PACKAGE-NAME)


# Everything

everything-test:	clean compile install setup check-deps test purge

everything-dist:	pkg exe
