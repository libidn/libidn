# Copyright (C) 2006-2025 Simon Josefsson
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

old_NEWS_hash = 9427ab7d2d1ab949f4fb9788284e9a64

guix = $(shell command -v guix > /dev/null && echo ,guix)
bootstrap-tools = git,gnulib,autoconf,automake,libtoolize,make,makeinfo,help2man,gperf,gengetopt,gtkdocize,tar,gzip$(guix)

# make syntax-check
local-checks-to-skip = sc_GPL_version sc_prohibit_strcmp
local-checks-to-skip += sc_prohibit_have_config_h sc_require_config_h sc_require_config_h_first
local-checks-to-skip += sc_prohibit_gnu_make_extensions
VC_LIST_ALWAYS_EXCLUDE_REGEX = ^doc/specifications/.*|(fuzz/.*.(in|repro)/.*)$$
exclude_file_name_regexp--sc_bindtextdomain = ^examples/|libc/|tests/|fuzz/
exclude_file_name_regexp--sc_file_system = ^contrib/doxygen/Doxyfile.(in|orig)$$
exclude_file_name_regexp--sc_fsf_postal = ^(m4/pkg.m4|COPYINGv2|COPYING.LESSERv2)$$
exclude_file_name_regexp--sc_indent = '^lib/\(gunibreak\|gunicomp\|gunidecomp\).h$$'
exclude_file_name_regexp--sc_prohibit_always_true_header_tests = ^lib/toutf8.c$$
exclude_file_name_regexp--sc_prohibit_atoi_atof = ^examples/example2.c$$
exclude_file_name_regexp--sc_prohibit_empty_lines_at_EOF = ^csharp/libidn.suo|csharp/libidn_PPC.suo$$
exclude_file_name_regexp--sc_trailing_blank = ^doc/components.fig|m4/pkg.m4|contrib/doxygen/Doxyfile.(in|orig)|gl/top/README-release.diff|csharp/|java/src/|lib/gen-unicode-tables.pl|lib/(gunibreak|gunicomp|gunidecomp).h$$
exclude_file_name_regexp--sc_two_space_separator_in_usage = ^cfg.mk$$
exclude_file_name_regexp--sc_unportable_grep_q = ^gl/top/README-release.diff$$
exclude_file_name_regexp--sc_useless_cpp_parens = ^lib/nfkc.c$$

TAR_OPTIONS += --mode=go+u,go-w --mtime=$(abs_top_srcdir)/NEWS

announce_gen_args = --cksum-checksums
url_dir_list = https://ftp.gnu.org/gnu/libidn

DIST_ARCHIVES += $(shell \
	if test -e $(srcdir)/.git && command -v git > /dev/null; then \
		echo $(PACKAGE)-v$(VERSION)-src.tar.gz; \
	fi)

review-diff:
	git diff `git describe --abbrev=0`.. \
	| grep -v -e '^index' -e '^deleted file mode' -e '^new file mode' \
	| filterdiff -p 1 -x 'build-aux/*' -x 'gl/*' -x 'lib/gl/*' -x 'po/*' -x 'maint.mk' -x '.gitignore' -x .gitlab-ci.yml -x '.x-sc*' -x ChangeLog -x GNUmakefile -x .prev-version -x bootstrap -x bootstrap-funclib.sh \
	| less

my-update-copyright:
	make update-copyright update-copyright-env='UPDATE_COPYRIGHT_USE_INTERVALS=1'
	make update-copyright update-copyright-env='UPDATE_COPYRIGHT_HOLDER="Simon Josefsson" UPDATE_COPYRIGHT_USE_INTERVALS=1'
	perl -pi -e "s/2002-20.. Simon Josefsson/2002-`(date +%Y)` Simon Josefsson/" doc/Makefile.am src/idn.c

aximport:
	for f in m4/ax_*.m4; do \
		wget -nv -O $$f "https://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=blob_plain;f=$$f"; \
	done

update-po: refresh-po
	rm -fv po/*.po.in
	for f in `ls po/*.po | grep -v quot.po`; do \
		cp $$f $$f.in; \
	done
	git add po/*.po.in
	git commit po/*.po.in \
		-m "maint: Run 'make update-po' for new translations."

codespell_ignore_words_list = meu,bu,te,ba,noe,nwe,mye,myu,tye,tim,ede,wich,poin
exclude_file_name_regexp--sc_codespell = ^gnulib|doc/specifications/.*|doc/gdoc|po/.*\.po\.in|fuzz/libidn_(stringprep|toascii|tounicode)_fuzzer.in/.*$$

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
