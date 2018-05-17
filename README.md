# Instructions how to compile static Linux binaries for Python and OpenSSL

A quick&amp;dirty way of building static Linux binaries for Python and OpenSSL for x86 and arm

Contents:

* Build instructions for Python and OpenSSL on Ubuntu 16.04
* Creating an ARM architecture ubuntu 16.04 chroot on (presumably x86) ubuntu 16.04.

Versions of software built:
* openssl-1.0.2o
* Python-3.5.5

## Build instructions for Python and OpenSSL on Ubuntu 16.04

### Setting up the environment

First of all, update the current system - update inside schroot if you are running in schroot or update the host system if you are doing the build directly on the host system:

```sh
apt-get update && apt-get upgrade -y
```

List of packages to install, copied from https://forum.xda-developers.com/android/software-hacking/scripting-python-static-2-7-8-3-4-2-t2958679/post57168101#post57168101

```sh
apt-get build-dep python python3 -y
apt-get install -y build-essential gcc make # building tools
apt-get install -y zlib1g-dev # zlib
apt-get install -y libreadline-dev libncurses5-dev # readline, curses
apt-get install -y libbz2-dev # bz2
apt-get install -y libsqlite3-dev # sqlite3
apt-get install -y python-bsddb3 python3-bsddb3
apt-get install -y libgdbm-dev # gdb
apt-get install -y libssl-dev # ssl
apt-get install -y python-tk python3-tk # tkinter
apt-get install -y libdb-dev # db
apt-get install -y python-gdbm python-bsddb3
apt-get install -y libffi-dev # _ctypes
apt-get install -y tcl8.6-dev # tkinter
apt-get install -y libx11-dev # tkinter
apt-get install -y libmpdec-dev # decimal
```

An additional list of packages to install from https://stackoverflow.com/questions/12344970/building-python-from-source-with-zlib-support

```sh
apt-get install python-dev python-setuptools python-pip python-smbus libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl -y
apt-get build-dep python3.5 -y
```

Additionally, install:

```sh
apt-get install -y libexpat1-dev # for pyexpat
apt-get install -y zip
```

Alternatively, you can use a one-liner of the above:

```sh
apt-get build-dep python python3 -y && apt-get install -y build-essential gcc make zlib1g-dev libreadline-dev libncurses5-dev libbz2-dev libsqlite3-dev python-bsddb3 python3-bsddb3 libgdbm-dev libssl-dev python-tk python3-tk libdb-dev python-gdbm python-bsddb3 libffi-dev tcl8.6-dev libx11-dev libmpdec-dev python-dev python-setuptools python-pip python-smbus libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libexpat1-dev zip -y && apt-get build-dep python3.5 -y && echo "success"
```

### OpenSSL static libraries for Python

This doesn't build the OpenSSL static binary itself.

```sh
./config --prefix="$PWD"/out --openssldir="$PWD"/out
make
make install
```

Or use `build.sh` as described in the following *Python* subchapter.

### Python

Inspiration:

* https://wiki.python.org/moin/BuildStatically
* http://stackoverflow.com/questions/5937337/building-python-with-ssl-support-in-non-standard-location

using Python 3.5.5

1) configure

without ensurepip because it caused problems later (requires modules that don't compile)

```sh
./configure --prefix="$PWD"/out LDFLAGS="-static -static-libgcc" CPPFLAGS=-static CXXFLAGS=-static CFLAGS="-Os -static" --without-ensurepip --disable-shared
```

2) edit Modules/Setup

* enable features that fail during `make install`
* enable features you want
* keep disabled those features that can't compile
* some features need a little tweaking

Put this line at the beginning:

```
*static*
```

Use the following configuration (the important parts are which lines are commented/uncommented):

```
*static*

# -*- makefile -*-
# The file Setup is used by the makesetup script to construct the files
# Makefile and config.c, from Makefile.pre and config.c.in,
# respectively.  The file Setup itself is initially copied from
# Setup.dist; once it exists it will not be overwritten, so you can edit
# Setup to your heart's content.  Note that Makefile.pre is created
# from Makefile.pre.in by the toplevel configure script.

# (VPATH notes: Setup and Makefile.pre are in the build directory, as
# are Makefile and config.c; the *.in and *.dist files are in the source
# directory.)

# Each line in this file describes one or more optional modules.
# Modules enabled here will not be compiled by the setup.py script,
# so the file can be used to override setup.py's behavior.

# Lines have the following structure:
#
# <module> ... [<sourcefile> ...] [<cpparg> ...] [<library> ...]
#
# <sourcefile> is anything ending in .c (.C, .cc, .c++ are C++ files)
# <cpparg> is anything starting with -I, -D, -U or -C
# <library> is anything ending in .a or beginning with -l or -L
# <module> is anything else but should be a valid Python
# identifier (letters, digits, underscores, beginning with non-digit)
#
# (As the makesetup script changes, it may recognize some other
# arguments as well, e.g. *.so and *.sl as libraries.  See the big
# case statement in the makesetup script.)
#
# Lines can also have the form
#
# <name> = <value>
#
# which defines a Make variable definition inserted into Makefile.in
#
# Finally, if a line contains just the word "*shared*" (without the
# quotes but with the stars), then the following modules will not be
# built statically.  The build process works like this:
#
# 1. Build all modules that are declared as static in Modules/Setup,
#    combine them into libpythonxy.a, combine that into python.
# 2. Build all modules that are listed as shared in Modules/Setup.
# 3. Invoke setup.py. That builds all modules that
#    a) are not builtin, and
#    b) are not listed in Modules/Setup, and
#    c) can be build on the target
#
# Therefore, modules declared to be shared will not be
# included in the config.c file, nor in the list of objects to be
# added to the library archive, and their linker options won't be
# added to the linker options. Rules to create their .o files and
# their shared libraries will still be added to the Makefile, and
# their names will be collected in the Make variable SHAREDMODS.  This
# is used to build modules as shared libraries.  (They can be
# installed using "make sharedinstall", which is implied by the
# toplevel "make install" target.)  (For compatibility,
# *noconfig* has the same effect as *shared*.)
#
# In addition, *static* explicitly declares the following modules to
# be static.  Lines containing "*static*" and "*shared*" may thus
# alternate throughout this file.

# NOTE: As a standard policy, as many modules as can be supported by a
# platform should be present.  The distribution comes with all modules
# enabled that are supported by most platforms and don't require you
# to ftp sources from elsewhere.


# Some special rules to define PYTHONPATH.
# Edit the definitions below to indicate which options you are using.
# Don't add any whitespace or comments!

# Directories where library files get installed.
# DESTLIB is for Python modules; MACHDESTLIB for shared libraries.
DESTLIB=$(LIBDEST)
MACHDESTLIB=$(BINLIBDEST)

# NOTE: all the paths are now relative to the prefix that is computed
# at run time!

# Standard path -- don't edit.
# No leading colon since this is the first entry.
# Empty since this is now just the runtime prefix.
DESTPATH=

# Site specific path components -- should begin with : if non-empty
SITEPATH=

# Standard path components for test modules
TESTPATH=

# Path components for machine- or system-dependent modules and shared libraries
MACHDEPPATH=:$(PLATDIR)
EXTRAMACHDEPPATH=

COREPYTHONPATH=$(DESTPATH)$(SITEPATH)$(TESTPATH)$(MACHDEPPATH)$(EXTRAMACHDEPPATH)
PYTHONPATH=$(COREPYTHONPATH)


# The modules listed here can't be built as shared libraries for
# various reasons; therefore they are listed here instead of in the
# normal order.

# This only contains the minimal set of modules required to run the
# setup.py script in the root of the Python source tree.

posix posixmodule.c     # posix (UNIX) system calls
errno errnomodule.c     # posix (UNIX) errno values
pwd pwdmodule.c         # this is needed to find out the user's home dir
                # if $HOME is not set
_sre _sre.c         # Fredrik Lundh's new regular expressions
_codecs _codecsmodule.c     # access to the builtin codecs and codec registry
_weakref _weakref.c     # weak references
_functools _functoolsmodule.c   # Tools for working with functions and callable objects
_operator _operator.c           # operator.add() and similar goodies
_collections _collectionsmodule.c # Container types
itertools itertoolsmodule.c    # Functions creating iterators for efficient looping
atexit atexitmodule.c      # Register functions to be run at interpreter-shutdown
_stat _stat.c           # stat.h interface
time timemodule.c   # -lm # time operations and variables

# access to ISO C locale support
_locale _localemodule.c  # -lintl

# Standard I/O baseline
_io -I$(srcdir)/Modules/_io _io/_iomodule.c _io/iobase.c _io/fileio.c _io/bytesio.c _io/bufferedio.c _io/textio.c _io/stringio.c

# The zipimport module is always imported at startup. Having it as a
# builtin module avoids some bootstrapping problems and reduces overhead.
zipimport zipimport.c

# faulthandler module
faulthandler faulthandler.c

# debug tool to trace memory blocks allocated by Python
_tracemalloc _tracemalloc.c hashtable.c

# The rest of the modules listed in this file are all commented out by
# default.  Usually they can be detected and built as dynamically
# loaded modules by the new setup.py script added in Python 2.1.  If
# you're on a platform that doesn't support dynamic loading, want to
# compile modules statically into the Python binary, or need to
# specify some odd set of compiler switches, you can uncomment the
# appropriate lines below.

# ======================================================================

# The Python symtable module depends on .h files that setup.py doesn't track
_symtable symtablemodule.c

# Uncommenting the following line tells makesetup that all following
# modules are to be built as shared libraries (see above for more
# detail; also note that *static* reverses this effect):

#*shared*

# GNU readline.  Unlike previous Python incarnations, GNU readline is
# now incorporated in an optional module, configured in the Setup file
# instead of by a configure script switch.  You may have to insert a
# -L option pointing to the directory where libreadline.* lives,
# and you may have to change -ltermcap to -ltermlib or perhaps remove
# it, depending on your system -- see the GNU readline instructions.
# It's okay for this to be a shared library, too.

readline readline.c -lreadline -ltermcap


# Modules that should always be present (non UNIX dependent):

array arraymodule.c # array objects
#cmath cmathmodule.c _math.c # -lm # complex math library functions
math mathmodule.c _math.c # -lm # math library functions, e.g. sin()
_struct _struct.c   # binary structure packing/unpacking
#_weakref _weakref.c    # basic weak reference support
#_testcapi _testcapimodule.c    # Python C API test module
_random _randommodule.c # Random number generator
_elementtree -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI -DXML_DEV_URANDOM _elementtree.c    # elementtree accelerator
_pickle _pickle.c   # pickle accelerator
_datetime _datetimemodule.c # datetime accelerator
_bisect _bisectmodule.c # Bisection algorithms
_heapq _heapqmodule.c   # Heap queue algorithm

unicodedata unicodedata.c    # static Unicode character database


# Modules with some UNIX dependencies -- on by default:
# (If you have a really backward UNIX, select and socket may not be
# supported...)

#fcntl fcntlmodule.c    # fcntl(2) and ioctl(2)
#spwd spwdmodule.c      # spwd(3)
#grp grpmodule.c        # grp(3)
select selectmodule.c   # select(2); not on ancient System V

# Memory-mapped files (also works on Win32).
mmap mmapmodule.c

# CSV file helper
_csv _csv.c

# Socket module helper for socket(2)
_socket socketmodule.c

# Socket module helper for SSL support; you must comment out the other
# socket line above, and possibly edit the SSL variable:
#SSL=/usr/local/ssl
#_ssl _ssl.c \
#   -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
#   -L$(SSL)/lib -lssl -lcrypto
SSL=/pythonbuild/Python-Python-3.5.5/openssl-1.0.2o/out
_ssl _ssl.c \
    -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
    -L$(SSL)/lib -lssl -lcrypto -ldl


# The crypt module is now disabled by default because it breaks builds
# on many systems (where -lcrypt is needed), e.g. Linux (I believe).
#
# First, look at Setup.config; configure may have set this for you.

_crypt _cryptmodule.c -lcrypt   # crypt(3); needs -lcrypt on some systems


# Some more UNIX dependent modules -- off by default, since these
# are not supported by all UNIX systems:

#nis nismodule.c -lnsl  # Sun yellow pages -- not everywhere
#termios termios.c  # Steen Lumholt's termios module
#resource resource.c    # Jeremy Hylton's rlimit interface

_posixsubprocess _posixsubprocess.c  # POSIX subprocess module helper

# Multimedia modules -- off by default.
# These don't work for 64-bit platforms!!!
# #993173 says audioop works on 64-bit platforms, though.
# These represent audio samples or images as strings:

#audioop audioop.c  # Operations on audio samples


# Note that the _md5 and _sha modules are normally only built if the
# system does not have the OpenSSL libs containing an optimized version.

# The _md5 module implements the RSA Data Security, Inc. MD5
# Message-Digest Algorithm, described in RFC 1321.

_md5 md5module.c


# The _sha module implements the SHA checksum algorithms.
# (NIST's Secure Hash Algorithms.)
_sha1 sha1module.c
_sha256 sha256module.c
_sha512 sha512module.c


# The _tkinter module.
#
# The command for _tkinter is long and site specific.  Please
# uncomment and/or edit those parts as indicated.  If you don't have a
# specific extension (e.g. Tix or BLT), leave the corresponding line
# commented out.  (Leave the trailing backslashes in!  If you
# experience strange errors, you may want to join all uncommented
# lines and remove the backslashes -- the backslash interpretation is
# done by the shell's "read" command and it may not be implemented on
# every system.

# *** Always uncomment this (leave the leading underscore in!):
# _tkinter _tkinter.c tkappinit.c -DWITH_APPINIT \
# *** Uncomment and edit to reflect where your Tcl/Tk libraries are:
#   -L/usr/local/lib \
# *** Uncomment and edit to reflect where your Tcl/Tk headers are:
#   -I/usr/local/include \
# *** Uncomment and edit to reflect where your X11 header files are:
#   -I/usr/X11R6/include \
# *** Or uncomment this for Solaris:
#   -I/usr/openwin/include \
# *** Uncomment and edit for Tix extension only:
#   -DWITH_TIX -ltix8.1.8.2 \
# *** Uncomment and edit for BLT extension only:
#   -DWITH_BLT -I/usr/local/blt/blt8.0-unoff/include -lBLT8.0 \
# *** Uncomment and edit for PIL (TkImaging) extension only:
#     (See http://www.pythonware.com/products/pil/ for more info)
#   -DWITH_PIL -I../Extensions/Imaging/libImaging  tkImaging.c \
# *** Uncomment and edit for TOGL extension only:
#   -DWITH_TOGL togl.c \
# *** Uncomment and edit to reflect your Tcl/Tk versions:
#   -ltk8.2 -ltcl8.2 \
# *** Uncomment and edit to reflect where your X11 libraries are:
#   -L/usr/X11R6/lib \
# *** Or uncomment this for Solaris:
#   -L/usr/openwin/lib \
# *** Uncomment these for TOGL extension only:
#   -lGL -lGLU -lXext -lXmu \
# *** Uncomment for AIX:
#   -lld \
# *** Always uncomment this; X11 libraries to link with:
#   -lX11

# Lance Ellinghaus's syslog module
#syslog syslogmodule.c      # syslog daemon interface


# Curses support, requiring the System V version of curses, often
# provided by the ncurses library.  e.g. on Linux, link with -lncurses
# instead of -lcurses).
#
# First, look at Setup.config; configure may have set this for you.

#_curses _cursesmodule.c -lcurses -ltermcap
# Wrapper for the panel library that's part of ncurses and SYSV curses.
#_curses_panel _curses_panel.c -lpanel -lncurses


# Modules that provide persistent dictionary-like semantics.  You will
# probably want to arrange for at least one of them to be available on
# your machine, though none are defined by default because of library
# dependencies.  The Python module dbm/__init__.py provides an
# implementation independent wrapper for these; dbm/dumb.py provides
# similar functionality (but slower of course) implemented in Python.

# The standard Unix dbm module has been moved to Setup.config so that
# it will be compiled as a shared library by default.  Compiling it as
# a built-in module causes conflicts with the pybsddb3 module since it
# creates a static dependency on an out-of-date version of db.so.
#
# First, look at Setup.config; configure may have set this for you.

#_dbm _dbmmodule.c  # dbm(3) may require -lndbm or similar

# Anthony Baxter's gdbm module.  GNU dbm(3) will require -lgdbm:
#
# First, look at Setup.config; configure may have set this for you.

#_gdbm _gdbmmodule.c -I/usr/local/include -L/usr/local/lib -lgdbm


# Helper module for various ascii-encoders
binascii binascii.c

# Fred Drake's interface to the Python parser
parser parsermodule.c


# Lee Busby's SIGFPE modules.
# The library to link fpectl with is platform specific.
# Choose *one* of the options below for fpectl:

# For SGI IRIX (tested on 5.3):
#fpectl fpectlmodule.c -lfpe

# For Solaris with SunPro compiler (tested on Solaris 2.5 with SunPro C 4.2):
# (Without the compiler you don't have -lsunmath.)
#fpectl fpectlmodule.c -R/opt/SUNWspro/lib -lsunmath -lm

# For other systems: see instructions in fpectlmodule.c.
#fpectl fpectlmodule.c ...

# Test module for fpectl.  No extra libraries needed.
#fpetest fpetestmodule.c

# Andrew Kuchling's zlib module.
# This require zlib 1.1.3 (or later).
# See http://www.gzip.org/zlib/
# https://stackoverflow.com/a/46964015
zlib zlibmodule.c -I$(prefix)/include -I/usr/include -L$(exec_prefix)/lib -L/lib/arm-linux-gnueabihf -L/lib/x86_64-linux-gnu -lz


# Interface to the Expat XML parser
#
# Expat was written by James Clark and is now maintained by a group of
# developers on SourceForge; see www.libexpat.org for more
# information.  The pyexpat module was written by Paul Prescod after a
# prototype by Jack Jansen.  Source of Expat 1.95.2 is included in
# Modules/expat/.  Usage of a system shared libexpat.so/expat.dll is
# not advised.
#
# More information on Expat can be found at www.libexpat.org.
#
pyexpat expat/xmlparse.c expat/xmlrole.c expat/xmltok.c pyexpat.c -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI -DXML_DEV_URANDOM 

# Hye-Shik Chang's CJKCodecs

# multibytecodec is required for all the other CJK codec modules
_multibytecodec cjkcodecs/multibytecodec.c

_codecs_cn cjkcodecs/_codecs_cn.c
_codecs_hk cjkcodecs/_codecs_hk.c
_codecs_iso2022 cjkcodecs/_codecs_iso2022.c
_codecs_jp cjkcodecs/_codecs_jp.c
_codecs_kr cjkcodecs/_codecs_kr.c
_codecs_tw cjkcodecs/_codecs_tw.c

# Example -- included for reference only:
# xx xxmodule.c

# Another example -- the 'xxsubtype' module shows C-level subtyping in action
xxsubtype xxsubtype.c
```

In the text above, this is of special importance:

```
SSL=/pythonbuild/Python-Python-3.5.5/openssl-1.0.2o/out
_ssl _ssl.c \
    -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
    -L$(SSL)/lib -lssl -lcrypto -ldl
```

The SSL variable should contain the path to the OpenSSL libraries we compiled in the "OpenSSL static libraries for Python" step above.
The `-ldl` switch has to be added (on the last line)

```
# https://stackoverflow.com/a/46964015
zlib zlibmodule.c -I$(prefix)/include -I/usr/include -L$(exec_prefix)/lib -L/lib/arm-linux-gnueabihf -L/lib/x86_64-linux-gnu -lz
```

There should be the appropriate paths for the architectures you want to build on in the `-L` arguments.

3) make

```sh
make LDFLAGS="-static" LINKFORSHARED=" "
```

4) make install

This installs the build stuff into the `out` directory we configured in the `configure` step.

```sh
make install
```

5) make clean

```sh
make clean
```

6) Optional - delete things that are not necessary, in this case not necessary in [Woolnote for Android](https://github.com/SvobodaJakub/WoolnoteAndroid)

```sh
cd out/lib/python3.5
rm -rf distutils ensurepip idlelib lib2to3 # do this only if you don't need this stuff
zip -r ../python35.zip *
cd ..
rm -rf python3.5
```


Or instead of all of the above, do it in an automated way that *shouldn't* break if the build environment is set up exactly as described:

```sh
grep -r pythonbuild .
vi Setup # edit the path in Setup
bash build.sh
```

Then run with `HOME=/your/home/directory LANG=C.utf-8 PYTHONIOENCODING=utf-8 PYTHONUTF8=1 PYTHONHOME=/path/to/where/lib/directory/is ./python3.5`. `PYTHONHOME` is the path to the `lib` directory that contains the `python35.zip` file.

### OpenSSL

This builds a static OpenSSL binary.

Inspiration:

* http://stackoverflow.com/questions/5937337/building-python-with-ssl-support-in-non-standard-location
* http://stackoverflow.com/questions/20147707/compiling-the-openssl-binary-statically

```sh
./config --prefix="$PWD"/out --openssldir="$PWD"/out -static -static-libgcc
make
make install
```

or

```sh
bash build.sh
```

The binary is inside the `out` directory structure.



## Creating an ARM architecture ubuntu 16.04 chroot on (presumably x86) ubuntu 16.04.

```sh
apt-get install -y qemu-user-static # to be able to execute arm binaries
apt-get install -y ubuntu-dev-tools # for mk-sbuild
```

### Create an Ubuntu 16.04 chroot

```sh
mk-sbuild --arch armhf xenial
```

(if mk-sbuild is run for the first time, install the packages it offers, reboot, run again)

### A few tips

to delete a session:
```sh
schroot -c session:xenial-armhf-6892a855-df0e-47c0-a2b3-35a704abe855 -e
```

to attach an existing session:
```sh
schroot -c session:xenial-armhf-22851a2d-5ff6-4304-baf5-09bd2b9db04b -r -u root
```

list schroots:
```sh
schroot -l
```

enter schroot:
```sh
schroot -u root -c xenial-armhf
```

Beware, the changed state is deleted after exit; it is not deleted if there are opened files, so opening mc from outside inside the chroot will prevent it from being destroyed, it can be attached later.

enter the "golden" schroot:
```sh
sudo schroot -c source:xenial-armhf -u root
```

The "golden" schroot has files directly in /var/lib/schroot/chroots/xenial-armhf and it is easier to launch multiple shells in it and it is slightly easier to work with, if you don't mind you will have to remove and reinstall it if you want to revert it to clean state.


### Building Python and OpenSSL in the ARM chroot

Inside chroot:
```sh
mkdir /pythonbuild && cd /pythonbuild
```

Outside of schroot, use `find . -name pythonbuild` to find where the schroot is (/var/lib/schroot/mount/...).

Copy openssl and python to the schroot.

Extract
```sh
tar xvf openssl-1.0.2o.tar.gz
tar xvf Python-3.5.5.tgz
```

Inside schroot:

Install basic software (add whatever you need):
```sh
apt-get install file ncdu vim mc # things to make my tinkering easier
```

Apt-get all the necessary stuff from the chapter "Build instructions for Python and OpenSSL on Ubuntu 16.04" and continue with the instructions in there.














