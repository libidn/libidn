# Copyright (C) 2006-2024 Simon Josefsson
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

manual_title = Internationalized Domain Names Library

old_NEWS_hash = 08790cbc825916c81904d5fc00b0dd92

bootstrap-tools = gnulib,autoconf,automake,libtoolize,make,makeinfo,help2man,gperf,gengetopt,gtkdocize,tar,gzip

local-checks-to-skip = sc_GPL_version sc_prohibit_strcmp
local-checks-to-skip += sc_prohibit_gnu_make_extensions
local-checks-to-skip += sc_prohibit_have_config_h sc_require_config_h	\
	sc_require_config_h_first
VC_LIST_ALWAYS_EXCLUDE_REGEX = \
	^(GNUmakefile|maint.mk|gtk-doc.make|m4/pkg.m4|m4/libtool.m4|doc/specifications|contrib/doxygen/Doxyfile|doc/fdl-1.3.texi|csharp/libidn.*suo|(lib/)?(gl|gltests|build-aux)/)

# Explicit syntax-check exceptions.
exclude_file_name_regexp--sc_trailing_blank = '^doc/components.fig\|csharp/\|fuzz/libidn_\(toascii\|stringprep\|tounicode\)_fuzzer.in/.*\|java/src/\|lib/gen-unicode-tables.pl\|lib/\(gunibreak\|gunicomp\|gunidecomp\).h$$'
exclude_file_name_regexp--sc_bindtextdomain = ^examples/|libc/|tests/|fuzz/
exclude_file_name_regexp--sc_prohibit_atoi_atof = ^examples/example2.c$$
exclude_file_name_regexp--sc_useless_cpp_parens = ^lib/nfkc.c$$
exclude_file_name_regexp--sc_prohibit_strncpy = ^src/idn.c$$
exclude_file_name_regexp--sc_prohibit_empty_lines_at_EOF = ^fuzz/libidn_.*fuzzer.(in|repro)/.*$$
exclude_file_name_regexp--sc_two_space_separator_in_usage = ^cfg.mk$$
exclude_file_name_regexp--sc_prohibit_always_true_header_tests = ^lib/toutf8.c$$
exclude_file_name_regexp--sc_indent = '^lib/\(gunibreak\|gunicomp\|gunidecomp\).h$$'
exclude_file_name_regexp--sc_fsf_postal = ^(COPYINGv2|COPYING.LESSERv2)$$

TAR_OPTIONS += --mode=go+u,go-w --mtime=$(abs_top_srcdir)/NEWS

# maint.mk's public-submodule-commit breaks on shallow gnulib
# https://lists.gnu.org/archive/html/bug-gnulib/2022-08/msg00040.html
# so let's disable it - XXX FIXME let's revisit this later
submodule-checks =
gl_public_submodule_commit =

aximport:
	for f in m4/ax_*.m4; do \
		wget -O $$f "https://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=blob_plain;f=$$f"; \
	done

review-diff:
	git diff `git describe --abbrev=0`.. \
	| grep -v -e '^index' -e '^deleted file mode' -e '^new file mode' \
	| filterdiff -p 1 -x 'build-aux/*' -x 'gl/*' -x 'lib/gl/*' -x 'po/*' -x 'maint.mk' -x '.gitignore' -x .gitlab-ci.yml -x '.x-sc*' -x ChangeLog -x GNUmakefile -x .prev-version -x bootstrap -x bootstrap-funclib.sh \
	| less

my-update-copyright:
	make update-copyright update-copyright-env='UPDATE_COPYRIGHT_USE_INTERVALS=1'
	make update-copyright update-copyright-env='UPDATE_COPYRIGHT_HOLDER="Simon Josefsson" UPDATE_COPYRIGHT_USE_INTERVALS=1'
	perl -pi -e "s/2002-20.. Simon Josefsson/2002-`(date +%Y)` Simon Josefsson/" doc/Makefile.am src/idn.c

CODESPELL_IGNORE_WORDS_LIST = meu,bu,te,ba,noe,nwe,mye,myu,tye,tim,ede,wich
exclude_file_name_regexp--sc_codespell = '^gnulib|doc/specifications/.*|doc/gdoc|fuzz/libidn_(stringprep|toascii|tounicode)_fuzzer.in/.*$$'
sc_codespell:
	@if ! command -v codespell > /dev/null; then			\
	   echo 1>&2 '$(ME): sc_codespell: codespell is missing';	\
	else								\
	   codespell --ignore-words-list $(CODESPELL_IGNORE_WORDS_LIST)	\
		$$(git -C $(srcdir) ls-files | egrep -v			\
			$(exclude_file_name_regexp--sc_codespell));	\
	fi

sc_libtool_version_bump:
	@git -C $(srcdir) diff v$(PREV_VERSION).. | grep '^+AC_SUBST(LT' > /dev/null

# Fuzz

COVERAGE_CCOPTS ?= "-g --coverage"
COVERAGE_OUT ?= doc/coverage

fuzz-coverage:
	$(MAKE) $(AM_MAKEFLAGS) clean
	lcov --directory . --zerocounters
	$(MAKE) $(AM_MAKEFLAGS) CFLAGS=$(COVERAGE_CCOPTS) CXXFLAGS=$(COVERAGE_CCOPTS)
	$(MAKE) -C fuzz $(AM_MAKEFLAGS) CFLAGS=$(COVERAGE_CCOPTS) CXXFLAGS=$(COVERAGE_CCOPTS) check
	mkdir -p $(COVERAGE_OUT)
	lcov --directory . --output-file $(COVERAGE_OUT)/$(PACKAGE).info --capture
	lcov --remove $(COVERAGE_OUT)/$(PACKAGE).info '*/lib/gl/*' -o $(COVERAGE_OUT)/$(PACKAGE).info
	genhtml --output-directory $(COVERAGE_OUT) \
                $(COVERAGE_OUT)/$(PACKAGE).info \
                --highlight --frames --legend \
                --title "$(PACKAGE_NAME)"
	@echo
	@echo "View fuzz coverage report with 'xdg-open $(COVERAGE_OUT)/index.html'"
