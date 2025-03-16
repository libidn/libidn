/* tst_version.c --- Libidn version number sanity checks.
 * Copyright (C) 2022-2025 Simon Josefsson
 *
 * This file is part of GNU Libidn.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <stdio.h>		/* printf */
#include <stdlib.h>		/* EXIT_SUCCESS */
#include <string.h>		/* strcmp */

#include <stringprep.h>

int
main (void)
{
  const char *check_version_null;

  printf ("STRINGPREP_VERSION: %s\n", STRINGPREP_VERSION);

  check_version_null = stringprep_check_version (NULL);
  if (!check_version_null)
    {
      printf ("FAIL: stringprep_check_version (NULL)\n");
      return EXIT_FAILURE;
    }
  printf ("stringprep_check_version (NULL): %s\n", check_version_null);

#ifdef PACKAGE_VERSION
  printf ("PACKAGE_VERSION %s\n", PACKAGE_VERSION);

  if (!stringprep_check_version (PACKAGE_VERSION))
    {
      printf ("FAIL: stringprep_check_version (PACKAGE_VERSION)\n");
      return EXIT_FAILURE;
    }
#endif

  if (!stringprep_check_version (STRINGPREP_VERSION))
    {
      printf ("FAIL: stringprep_check_version (STRINGPREP_VERSION)\n");
      return EXIT_FAILURE;
    }

  if (check_version_null != stringprep_check_version (NULL))
    {
      printf ("FAIL: check_version_null != "
	      "stringprep_check_version (NULL)\n");
      return EXIT_FAILURE;
    }

  if (stringprep_check_version (STRINGPREP_VERSION) !=
      stringprep_check_version (STRINGPREP_VERSION))
    {
      printf ("FAIL: stringprep_check_version (STRINGPREP_VERSION) "
	      "!= stringprep_check_version (STRINGPREP_VERSION)\n");
      return EXIT_FAILURE;
    }

  if (!stringprep_check_version ("0.0"))
    {
      printf ("FAIL: stringprep_check_version(0.0)\n");
      return EXIT_FAILURE;
    }

  if (!stringprep_check_version ("1"))
    {
      printf ("FAIL: stringprep_check_version(1)\n");
      return EXIT_FAILURE;
    }

  if (!stringprep_check_version ("1.1"))
    {
      printf ("FAIL: stringprep_check_version(1.1)\n");
      return EXIT_FAILURE;
    }

  if (!stringprep_check_version ("1.0.1"))
    {
      printf ("FAIL: stringprep_check_version (1.0.1)\n");
      return EXIT_FAILURE;
    }

  if (strcmp (STRINGPREP_VERSION, check_version_null) != 0)
    {
      printf ("FAIL: strcmp (STRINGPREP_VERSION, "
	      "stringprep_check_version (NULL))\n");
      return EXIT_FAILURE;
    }

  if (stringprep_check_version ("100.100"))
    {
      printf ("FAIL: stringprep_check_version(100.100)\n");
      return EXIT_FAILURE;
    }

  if (stringprep_check_version ("4711.42.23"))
    {
      printf ("FAIL: stringprep_check_version(4711.42.23)\n");
      return EXIT_FAILURE;
    }

  if (stringprep_check_version ("UNKNOWN"))
    {
      printf ("FAIL: stringprep_check_version (UNKNOWN)\n");
      return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}
