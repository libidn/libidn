dnl Process this file with autoconf to produce a configure script.

dnl Copyright (C) 2002-2025 Simon Josefsson
dnl
dnl This file is part of GNU Libidn.
dnl
dnl This program is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or
dnl (at your option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program.  If not, see <https://www.gnu.org/licenses/>.

AC_INIT([GNU Libidn],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [help-libidn@gnu.org])

# Library code modified:                              REVISION++
# Interfaces changed/added/removed:   CURRENT++       REVISION=0
# Interfaces added:                             AGE++
# Interfaces removed:                           AGE=0
AC_SUBST(LT_CURRENT, 18)
AC_SUBST(LT_REVISION, 6)
AC_SUBST(LT_AGE, 6)

DLL_VERSION=`expr ${LT_CURRENT} - ${LT_AGE}`
AC_SUBST(DLL_VERSION)

AC_MSG_NOTICE([$PACKAGE_NAME $PACKAGE_VERSION $PACKAGE_TARNAME $LT_CURRENT:$LT_REVISION:$LT_AGE $DLL_VERSION])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([lib/m4])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([-Wall tar-ustar])
AM_SILENT_RULES([yes])

AC_PROG_CC
gl_EARLY
lgl_EARLY

# Checks for programs.
AM_PROG_AR
LT_INIT([win32-dll])
AM_MISSING_PROG(PERL, perl, $missing_dir)
AM_MISSING_PROG(HELP2MAN, help2man, $missing_dir)
AM_MISSING_PROG([DOT], [dot])
AM_MISSING_PROG([GS], [gs])
AM_ICONV
AM_PATH_LISPDIR

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.19.8])

AM_LANGINFO_CODESET

# For gnulib stuff in gl/.
gl_INIT
lgl_INIT
AC_DEFINE([GNULIB_NO_VLA], 1, [Disable VLA usage in gettext.h.])

# Make it possible to disable TLD code.
AC_ARG_ENABLE(tld, AS_HELP_STRING([--disable-tld], [disable TLD code]),
		enable_tld=$enableval, enable_tld=yes)
AM_CONDITIONAL(TLD, test "$enable_tld" != "no")
if test "$enable_tld" != "no"; then
	AC_DEFINE([WITH_TLD], 1, [Define to 1 if you want TLD code.])
fi
AC_MSG_CHECKING([if TLD API for specific TLD rules should be built])
AC_MSG_RESULT($enable_tld)

#
# check for gtk-doc
#
m4_ifdef([GTK_DOC_CHECK], [
GTK_DOC_CHECK([1.14],[--flavour no-tmpl])
],[
AM_CONDITIONAL([ENABLE_GTK_DOC], false)
])
# needed for some older versions of gtk-doc
m4_ifdef([GTK_DOC_USE_LIBTOOL], [], [
AM_CONDITIONAL([GTK_DOC_USE_LIBTOOL], false)
])

# Check for java
AC_ARG_ENABLE(java, AS_HELP_STRING([--enable-java], [enable Java API]),,
		enable_java=no)
if test "$enable_java" != "no"; then
  AX_JAVA_OPTIONS
  AX_PROG_JAVAC
  AX_PROG_JAVADOC
  AX_PROG_JAR
  AM_MISSING_PROG(JAVADOC, javadoc, $missing_dir)
fi
AM_CONDITIONAL(JAVA, test "$enable_java" != "no")
AC_MSG_CHECKING([if implementation in Java should be built])
AC_MSG_RESULT($enable_java)

# Check for C#
if test -n "$HAVE_CSHARPCOMP"; then
  gt_CSHARPEXEC
fi
AC_MSG_CHECKING([[if implementation in C# should be built]])
if test -n "$HAVE_CSHARPCOMP" && test -n "$HAVE_CSHARPEXEC"; then
  enable_csharp=yes
else
  enable_csharp=no
fi
AC_MSG_RESULT($enable_csharp)
AM_CONDITIONAL(CSHARP, test "$enable_csharp" = yes)

ubsan=no
AC_ARG_ENABLE([ubsan],
  [AS_HELP_STRING([--enable-ubsan], [Turn on Undefined Behavior Sanitizer (UBSan)])],
  [
    if test "$enableval" = yes; then
      ubsan=yes
      CFLAGS=$CFLAGS" -fsanitize=undefined -fno-sanitize-recover=undefined"
    fi
  ])

asan=no
AC_ARG_ENABLE([asan],
  [AS_HELP_STRING([--enable-asan], [Turn on Address Sanitizer (ASan)])],
  [
    if test "$enableval" = yes; then
      asan=yes
      CFLAGS=$CFLAGS" -fsanitize=address -fno-omit-frame-pointer"
    fi
  ])

AC_ARG_ENABLE([gcc-warnings],
  [AS_HELP_STRING([[--enable-gcc-warnings[=TYPE]]],
    [control generation of GCC warnings.  The TYPE 'no' disables
     warnings; 'yes' (default) generates cheap warnings;
     'expensive' in addition generates expensive warnings
     and 'error' also turn warnings into errors.])])

# https://www.gnu.org/software/gnulib//manual/html_node/manywarnings.html
AS_IF([test "$enable_gcc_warnings" != no],
  [
   # Set up the list of unwanted warning options.
   nw=
   if test "$enable_gcc_warnings" = yes; then
     nw="$nw -fanalyzer"
   fi
   nw="$nw -Wbad-function-cast" # Casting a function's result is not more
                                # dangerous than casting any other value.
   nw="$nw -Winline"            # It's OK to not inline.
   nw="$nw -Wsign-compare"      # Too many false alarms.
   nw="$nw -Wstrict-overflow"   # It's OK to optimize strictly.
   nw="$nw -Wsystem-headers"    # Don't warn in system headers.

   nw="$nw -Wsuggest-attribute=pure"  # Is it worth using attributes?
   nw="$nw -Wsuggest-attribute=const" # Is it worth using attributes?
   nw="$nw -Wmissing-field-initializers" # We use missing fields = 0 a lot
   gl_WARN_ADD([-Wframe-larger-than=208], [WARN_LIB_CFLAGS])

   if test "$enable_gcc_warnings" = error; then
     gl_WARN_ADD([-Werror], [WERROR_CFLAGS])
     gl_WARN_ADD([-Wno-error=suggest-attribute=malloc], [WERROR_CFLAGS])
     gl_WARN_ADD([-Wno-error=overlength-strings], [WERROR_CFLAGS])
     gl_WARN_ADD([-Wno-error=analyzer-out-of-bounds], [WERROR_CFLAGS])
   fi

   # Setup the list of meaningful warning options for the C compiler.
   # The list comes from manywarnings.m4. Warning options that are not
   # generally meaningful have already been filtered out (cf.
   # build-aux/gcc-warning.spec).
   gl_MANYWARN_ALL_GCC([possible_warning_options])

   # Compute the list of warning options that are desired.
   gl_MANYWARN_COMPLEMENT([desired_warning_options],
                          [$possible_warning_options], [$nw])
   # Compute the list of remaining undesired warning options.
   # Namely those, that were not in manywarnings.m4 because they were
   # already listed in build-aux/gcc-warning.spec; this includes those
   # that are implied by -Wall.
   gl_MANYWARN_COMPLEMENT([remaining_undesired_warning_options],
                          [$nw], [$possible_warning_options])

   # Add the desired warning options to WARN_CFLAGS.
   for w in $desired_warning_options; do
     gl_WARN_ADD([$w])
   done

   # Add the opposites of the remaining undesired warning options to
   # WARN_CFLAGS.
   for w in `echo "$remaining_undesired_warning_options" | sed -e 's/-W/-Wno-/g'`; do
     gl_WARN_ADD([$w])
   done
])

AC_ARG_ENABLE(doc,
  AS_HELP_STRING([--disable-doc], [don't generate any documentation]),
    enable_doc=$enableval, enable_doc=yes)
AM_CONDITIONAL(ENABLE_DOC, test "$enable_doc" != "no")

AC_CONFIG_FILES([
  Makefile
  contrib/doxygen/Doxyfile
  csharp/Makefile
  doc/Makefile
  doc/cyclo/Makefile
  doc/java/Makefile
  doc/reference/Makefile
  doc/reference/version.xml
  doc/specifications/Makefile
  doc/tld/Makefile
  examples/Makefile
  fuzz/Makefile
  gl/Makefile
  java/Makefile
  java/pom.xml
  java/src/Makefile
  java/src/main/Makefile
  java/src/main/java/Makefile
  java/src/main/java/gnu/Makefile
  java/src/main/java/gnu/inet/Makefile
  java/src/main/java/gnu/inet/encoding/Makefile
  java/src/test/Makefile
  java/src/test/java/Makefile
  java/src/util/Makefile
  java/src/util/java/Makefile
  lib/Makefile
  lib/gl/Makefile
  lib/libidn.pc
  po/Makefile.in
  src/Makefile
  tests/Makefile
])
gl_CONFIG_VERSION_STAMP
AC_OUTPUT

AC_MSG_NOTICE([summary of main build options:

  Version:            ${VERSION}
  Libtool version     $LT_CURRENT:$LT_REVISION:$LT_AGE
  DLL version:        $DLL_VERSION
  Build system:       ${build}
  Host/Target system: ${host}
  Install prefix:     ${prefix}
  Compiler:           ${CC}
  CFLAGS:             ${CFLAGS}
  CPPFLAGS:           ${CPPFLAGS}
  LDFLAGS:            ${LDFLAGS}
  Library types:      Shared=${enable_shared}, Static=${enable_static}

  Warning flags:      $enable_gcc_warnings
      WERROR_CFLAGS:  $WERROR_CFLAGS
    WARN_LIB_CFLAGS:  $WARN_LIB_CFLAGS
        WARN_CFLAGS:  $WARN_CFLAGS

  Documentation:      ${enable_doc}
  nl_langinfo:        $gl_cv_header_langinfo_codeset
  iconv:              $am_cv_func_iconv_summary $LTLIBICONV
  Version script:     $have_ld_version_script
  TLD code:           $enable_tld
  Build Java port:    $enable_java
  Build C# port:      $enable_csharp
  Address Sanitizer:  $asan
  UB Sanitizer:       $ubsan

  Valgrind:           $opt_valgrind_tests ${VALGRIND}
])
