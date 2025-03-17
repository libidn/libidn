## Process this file with automake to produce Makefile.in
# Copyright (C) 2002-2025 Simon Josefsson
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

SUBDIRS = gl lib/gl lib po src
if ENABLE_DOC
SUBDIRS += doc
endif
SUBDIRS += fuzz examples
if JAVA
SUBDIRS += java
endif
if CSHARP
SUBDIRS += csharp
endif
SUBDIRS += tests

EXTRA_DIST = cfg.mk maint.mk
EXTRA_DIST += CONTRIBUTING.md DEPENDENCIES.md
EXTRA_DIST += COPYING.LESSERv2 COPYING.LESSERv3 COPYINGv2

ACLOCAL_AMFLAGS = -I lib/m4 -I gl/m4 -I lib/gl/m4 -I m4
AM_DISTCHECK_CONFIGURE_FLAGS = --enable-doc --enable-gtk-doc --disable-valgrind-tests

EXTRA_DIST += FAQ libc/README libc/getaddrinfo-idn.txt libc/example.c	\
	contrib/README contrib/idn-python/README			\
	contrib/idn-python/Makefile contrib/idn-python/idn.c		\
	contrib/idn-python/test.py contrib/web/idn.php			\
	contrib/java/README contrib/java/autogen.sh			\
	contrib/java/configure.ac contrib/java/Makefile.am		\
	contrib/java/ExampleIDNA.java contrib/java/IDNA.java		\
	contrib/java/IDNA.c contrib/doxygen/Doxyfile.in			\
	contrib/doxygen/Doxyfile.orig contrib/doxygen/gdoc2doxygen

# Visual Studio project files.
EXTRA_DIST += windows/libidn.sln windows/libidn.vcproj			\
	windows/include/unistd.h windows/include/idn-int.h		\
	windows/include/stdbool.h windows/include/ac-stdint.h		\
	windows/include/config.h windows/libidn4win.mk

# version-stamp
EXTRA_DIST += $(top_srcdir)/.version
BUILT_SOURCES = $(top_srcdir)/.version

# git-version-gen
dist-hook: dist-tarball-version
.PHONY: dist-tarball-version
dist-tarball-version:
	echo '$(VERSION)' > $(distdir)/.tarball-version

dist-hook: po-CreationDate-to-mtime-NEWS
.PHONY: po-CreationDate-to-mtime-NEWS
po-CreationDate-to-mtime-NEWS: mtime-NEWS-to-git-HEAD
	$(AM_V_GEN)for p in $(distdir)/po/*.po $(distdir)/po/$(PACKAGE).pot; do \
	  if test -f "$$p"; then \
	    $(SED) -e 's,POT-Creation-Date: .*\\n",POT-Creation-Date: '"$$(env LC_ALL=C TZ=UTC0 stat --format=%y $(srcdir)/NEWS | cut -c1-16,31-)"'\\n",' < $$p > $$p.tmp && \
	    if cmp $$p $$p.tmp > /dev/null; then \
	      rm -f $$p.tmp; \
	    else \
	      mv $$p.tmp $$p; \
	    fi \
	  fi \
	done

dist-hook: srcdist
.PHONY: srcdist
srcdist:
	$(AM_V_GEN)if test -e $(srcdir)/.git \
			&& command -v git > /dev/null; then \
	 cd $(srcdir) && \
	   git archive --prefix=$(PACKAGE)-v$(VERSION)/ \
	       -o $(abs_builddir)/$(PACKAGE)-v$(VERSION)-src.tar.gz HEAD; \
	fi

dist-hook: mtime-NEWS-to-git-HEAD
.PHONY: mtime-NEWS-to-git-HEAD
mtime-NEWS-to-git-HEAD:
	$(AM_V_GEN)if test -e $(srcdir)/.git \
			&& command -v git > /dev/null; then \
		touch -m -t "$$(git log -1 --format=%cd --date=format-local:%Y%m%d%H%M.%S)" $(srcdir)/NEWS; \
	fi

dist-hook: texi-stamps-to-mtime-NEWS
.PHONY: texi-stamps-to-mtime-NEWS
texi-stamps-to-mtime-NEWS: mtime-NEWS-to-git-HEAD
	$(AM_V_GEN)touch -m -r $(srcdir)/NEWS $(srcdir)/doc/$(PACKAGE).texi

dist-hook: gen-ChangeLog
.PHONY: gen-ChangeLog
gen-ChangeLog:
	$(AM_V_GEN)if test -e $(srcdir)/.git; then			\
	  LC_ALL=en_US.UTF-8 TZ=UTC0					\
	    $(top_srcdir)/build-aux/gitlog-to-changelog			\
	      --srcdir=$(srcdir) --					\
	      v$(PREV_VERSION)~.. > $(distdir)/cl-t &&			\
	    { printf '\n\nSee the source repo for older entries\n'	\
	      >> $(distdir)/cl-t &&					\
	      rm -f $(distdir)/ChangeLog &&				\
	      mv $(distdir)/cl-t $(distdir)/ChangeLog; }		\
	fi
