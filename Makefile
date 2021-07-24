SCRIPT_NAME := efi-mkuki

prefix      := /usr/local
bindir      := $(prefix)/bin

INSTALL     := install
GIT         := git
SED         := sed

MAKEFILE_PATH  = $(lastword $(MAKEFILE_LIST))


#: Print list of targets.
help:
	@printf '%s\n\n' 'List of targets:'
	@$(SED) -En '/^#:.*/{ N; s/^#: (.*)\n([A-Za-z0-9_-]+).*/\2 \1/p }' $(MAKEFILE_PATH) \
		| while read label desc; do printf '%-15s %s\n' "$$label" "$$desc"; done

#: Install script into $DESTDIR.
install:
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL) -m 755 $(SCRIPT_NAME) "$(DESTDIR)$(bindir)/$(SCRIPT_NAME)"
	test -z "$(EFISTUB_DIR)" || $(SED) -i "s|/usr/lib/gummiboot|$(EFISTUB_DIR)|" "$(DESTDIR)$(bindir)/$(SCRIPT_NAME)"

#: Uninstall the script from $DESTDIR.
uninstall:
	rm -f "$(DESTDIR)$(bindir)/$(SCRIPT_NAME)"

#: Update version in the script and README.adoc to $VERSION.
bump-version:
	test -n "$(VERSION)"  # $$VERSION
	$(SED) -E -i "s/^(VERSION)=.*/\1='$(VERSION)'/" $(SCRIPT_NAME)
	$(SED) -E -i "s/^(:version:).*/\1 $(VERSION)/" README.adoc

#: Bump version to $VERSION, create release commit and tag.
release: .check-git-clean | bump-version
	test -n "$(VERSION)"  # $$VERSION
	$(GIT) add .
	$(GIT) commit -m "Release version $(VERSION)"
	$(GIT) tag -s v$(VERSION) -m v$(VERSION)


.check-git-clean:
	@test -z "$(shell $(GIT) status --porcelain)" \
		|| { echo 'You have uncommitted changes!' >&2; exit 1; }

.PHONY: help install uninstall bump-version release .check-git-clean
