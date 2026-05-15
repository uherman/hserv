PREFIX  ?= /usr/local
DESTDIR ?=

LIBDIR := $(DESTDIR)$(PREFIX)/lib/hserv
BINDIR := $(DESTDIR)$(PREFIX)/bin

VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo dev)
DIST_DIR := dist
TARBALL  := $(DIST_DIR)/hserv-$(VERSION).tar.gz

.PHONY: help install uninstall dist clean

help:
	@echo 'Targets:'
	@echo '  install    Install hserv to $$PREFIX (default: /usr/local)'
	@echo '  uninstall  Remove installed files'
	@echo '  dist       Build release tarball at $(TARBALL)'
	@echo '  clean      Remove $(DIST_DIR)/'
	@echo ''
	@echo 'Env vars: PREFIX, DESTDIR, VERSION'

install:
	@command -v hcc >/dev/null 2>&1 || \
	  echo 'warning: hcc not found in PATH; install holyc-lang to use `hserv build`'
	install -d '$(LIBDIR)/framework' '$(LIBDIR)/templates' '$(BINDIR)'
	install -m 0755 hserv '$(LIBDIR)/hserv'
	cp -R framework/. '$(LIBDIR)/framework/'
	cp -R templates/. '$(LIBDIR)/templates/'
	ln -sfn '$(PREFIX)/lib/hserv/hserv' '$(BINDIR)/hserv'
	@echo 'installed: $(BINDIR)/hserv -> $(PREFIX)/lib/hserv/hserv'

uninstall:
	rm -f '$(BINDIR)/hserv'
	rm -rf '$(LIBDIR)'
	@echo 'uninstalled hserv from $(PREFIX)'

dist:
	@mkdir -p '$(DIST_DIR)'
	@tmp=$$(mktemp -d) && \
	  pkg="$$tmp/hserv-$(VERSION)" && \
	  mkdir -p "$$pkg" && \
	  cp -R hserv framework templates README.md Makefile install.sh "$$pkg/" && \
	  tar -czf '$(TARBALL)' -C "$$tmp" "hserv-$(VERSION)" && \
	  rm -rf "$$tmp"
	@echo 'built $(TARBALL)'

clean:
	rm -rf '$(DIST_DIR)'
