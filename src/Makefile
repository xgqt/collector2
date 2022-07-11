MAKE            := make
RACKET          := racket
RACO            := raco
SCRIBBLE        := $(RACO) scribble

DO-DOCS         := --no-docs
INSTALL-FLAGS   := --auto --skip-installed $(DO-DOCS)
REMOVE-FLAGS    := --force --no-trash $(DO-DOCS)
DEPS-FLAGS      := --check-pkg-deps --unused-pkg-deps
SETUP-FLAGS     := --tidy --avoid-main $(DEPS-FLAGS)
TEST-FLAGS      := --heartbeat --no-run-if-absent --submodule test --table

all: clean compile

clean-pkg-%:
	find $(*) -type d -name 'compiled' -exec rm -dr {} +
compile-pkg-%:
	$(RACKET) -e "(require compiler/compiler setup/getinfo) (compile-directory-zos (path->complete-path \"$(*)\") (get-info/full \"$(*)/info.rkt\") #:skip-doc-sources? #t #:verbose #f)"
install-pkg-%:
	cd $(*) && $(RACO) pkg install $(INSTALL-FLAGS)
setup-pkg-%:
	$(RACO) setup $(SETUP-FLAGS) --pkgs $(*)
test-pkg-%:
	$(RACO) test $(TEST-FLAGS) --package $(*)
remove-pkg-%:
	$(RACO) pkg remove $(REMOVE-FLAGS) $(*)

clean-pkg-collector2: clean-pkg-collector2-lib clean-pkg-collector2-doc clean-pkg-collector2-test
clean-pkg-collector2-test: clean-pkg-collector2-lib

clean: clean-pkg-collector2-lib clean-pkg-collector2-doc clean-pkg-collector2-test clean-pkg-collector2

compile-pkg-collector2: compile-pkg-collector2-lib compile-pkg-collector2-doc compile-pkg-collector2-test
compile-pkg-collector2-test: compile-pkg-collector2-lib

compile: compile-pkg-collector2-lib compile-pkg-collector2-doc compile-pkg-collector2-test compile-pkg-collector2

install-pkg-collector2: install-pkg-collector2-lib install-pkg-collector2-doc install-pkg-collector2-test
install-pkg-collector2-test: install-pkg-collector2-lib

install: install-pkg-collector2-lib install-pkg-collector2-doc install-pkg-collector2-test install-pkg-collector2

setup-pkg-collector2: setup-pkg-collector2-lib setup-pkg-collector2-doc setup-pkg-collector2-test
setup-pkg-collector2-test: setup-pkg-collector2-lib

setup: setup-pkg-collector2-lib setup-pkg-collector2-doc setup-pkg-collector2-test setup-pkg-collector2

test-pkg-collector2: test-pkg-collector2-lib test-pkg-collector2-doc test-pkg-collector2-test
test-pkg-collector2-test: test-pkg-collector2-lib

test: test-pkg-collector2-lib test-pkg-collector2-doc test-pkg-collector2-test test-pkg-collector2

remove-pkg-collector2: remove-pkg-collector2-test remove-pkg-collector2-doc remove-pkg-collector2-lib
remove-pkg-collector2-test: remove-pkg-collector2-lib

remove: remove-pkg-collector2 remove-pkg-collector2-test remove-pkg-collector2-doc remove-pkg-collector2-lib
