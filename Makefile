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
RACKET      := racket
RACO        := raco
SCRIBBLE    := $(RACO) scribble
SH          := sh
RM          := rm
RMDIR       := $(RM) -r

BINDIR      := $(PWD)/bin
DOCSDIR     := $(PWD)/docs
PUBLICDIR   := $(PWD)/public
SCRIPTSDIR  := $(PWD)/scripts
SRCDIR      := $(PWD)/src
TESTSDIR    := $(PWD)/tests


.PHONY: all
all: clean compile


src-make-%:
	$(MAKE) -C $(PWD)/src DEPS-FLAGS=" --no-pkg-deps " $(*)


.PHONY: clean
clean: src-make-clean

.PHONY: compile
compile: src-make-compile

.PHONY: isntall
install: src-make-install

.PHONY: setup
setup: install
setup: src-make-setup

.PHONY: test
test: install
test: src-make-test

.PHONY: remove
remove: src-make-remove


public:
	mkdir -p $(PUBLICDIR)

.PHONY: docs-html
docs-html: public
	cd $(DOCSDIR) && $(SCRIBBLE) ++main-xref-in --dest $(PWD) \
		--dest-name public --htmls --quiet $(DOCSDIR)/scribblings/main.scrbl

.PHONY: docs-latex
docs-latex: public
	$(RACKET) $(SCRIPTSDIR)/doc.rkt latex

.PHONY: docs-markdown
docs-markdown: public
	$(RACKET) $(SCRIPTSDIR)/doc.rkt markdown

.PHONY: docs-pdf
docs-pdf: public
	$(RACKET) $(SCRIPTSDIR)/doc.rkt pdf

.PHONY: docs-text
docs-text: public
	$(RACKET) $(SCRIPTSDIR)/doc.rkt text

.PHONY: docs-public
docs-public: docs-html

.PHONY: docs-all
docs-all: docs-html docs-latex docs-markdown docs-pdf docs-text

.PHONY: clean-public
clean-public:
	if [ -d $(PUBLICDIR) ] ; then $(RMDIR) $(PUBLICDIR) ; fi

.PHONY: regen-public
regen-public: clean-public docs-public
