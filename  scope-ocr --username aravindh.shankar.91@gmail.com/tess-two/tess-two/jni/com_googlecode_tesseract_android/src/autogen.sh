#!/bin/sh

# This is a simple script which is meant to help developers
# better deal with the GNU autotools, specifically:
#
#   aclocal
#   autoheader
#   autoconf
#   automake
#
# The whole thing is quite complex...
#
# The idea is to run this collection of tools on a single platform,
# typically the main development platform, running a recent version of
# autoconf. In theory, if we had these tools on each platform where we
# ever expected to port the software, we would never need to checkin
# more than a few autotools configuration files. However, the whole
# idea is to generate a configure script and associated files in a way
# that is portable across platforms, so we *have* to check in a whole
# bunch of files generated by all these tools.

# The real source files are:
#
# acinclude.m4 (used by aclocal)
# configure.ac (main autoconf file)
# Makefile.am, */Makefile.am (automake config files)
#
# All the rest is auto-generated.

# create m4 directory if it not exists
if [ ! -d m4 ];  then
    mkdir m4
fi

bail_out()
{
    echo
    echo "  Something went wrong, bailing out!" 
    echo
    exit 1
}

# --- Step 1: Generate aclocal.m4 from:
#             . acinclude.m4 
#             . config/*.m4 (these files are referenced in acinclude.m4)

mkdir -p config

echo "Running aclocal"
aclocal -I config || bail_out

# --- Step 2:

echo "Running libtoolize"
libtoolize -f -c || glibtoolize -f -c || bail_out
libtoolize --automake || glibtoolize --automake || bail_out

# --- Step 3: Generate config.h.in from:
#             . configure.ac (look for AM_CONFIG_HEADER tag or AC_CONFIG_HEADER tag)

echo "Running autoheader"
autoheader -f || bail_out

# --- Step 4: Generate Makefile.in, src/Makefile.in, and a whole bunch of
#             files in config (config.guess, config.sub, depcomp,
#             install-sh, missing, mkinstalldirs) plus COPYING and
#             INSTALL from:
#             . Makefile.am
#             . src/Makefile.am
#
# Using --add-missing --copy makes sure that, if these files are missing,
# they are copied from the system so they can be used in a distribution.

echo "Running automake --add-missing --copy"
automake --add-missing -c  -Wno-portability > /dev/null || bail_out

# --- Step 5: Generate configure and include/miaconfig.h from:
#             . configure.ac
#

echo "Running autoconf"
autoconf || bail_out

echo ""
echo "All done."
echo "To build the software now, do something like:"
echo ""
echo "$ ./configure [--enable-debug] [...other options]"
echo "$ make"
