# 3rdparty #

A developer 3rdparty library for development and packaging of film and color applications.

## 3rdparty consists of ##

  * A set of libraries, viewers and media provided on Mac based platforms.
  
  * A set of configurations to simplify the process of building 3rdparty support without the
    knowledge of each individual build system. 
        
  * Up to date support for the latest platforms and versions.

    See PLATFORMS.txt for details.

## 3rdparty can be used to ##

  * Resolve the most common libraries used for film and color applications.

  * Only build a subset of libraries with a default or non-default configuration.

  * Test new versions of libraries before official releases.

## 3rdparty is not ##

  * A package manager, it's a complement.

## 3rdparty build ##

The 3rdparty build system requires CMake.
Get it from: 

```shell
http://www.cmake.org
```

Make sure it's added to path

```shell
export PATH=$PATH:/Applications/CMake.app/Contents/bin
```

Some build configurations requires python2.7 for bootstrapping and setup.
Get it from:

```shell
https://www.python.org/downloads/release/python-2718
```

On macOS Cataline the Command Line Tools needs to be installed, not just Xcode.
Get Xcode from AppStore.
Get Command Line Tools from "Preferences > Downloads > Command Line Tools", press Install.

Qt is used to build apps.
```shell
http://download.qt.io/official_releases/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz
```

.. use the patched version for Mac M1 arm64:
```shell
https://mikaelsundell.s3.eu-west-1.amazonaws.com/3rdparty/qt-everywhere-src-5.15.1.tar.gz
```

Make sure you download the .tar.xz unix formatted single archive

To build for 3rdparty first build base libraries and configure Qt

3rdparty base libraries (debug):
    
```shell
make verbose=1 build_base=1 debug
```
Qt:

```shell
mkdir build &&
cd build &&
../configure -prefix $(path)/3rdparty/build/macosx.debug/$(arch)
             -libdir $(path)/git/3rdparty/build/macosx.debug/$(arch)/lib 
             QMAKE_APPLE_DEVICE_ARCHS=arm64/x86_64
             -opensource
             -confirm-license
             -system-libpng
             -system-libjpeg
             -system-zlib
             -system-pcre
             -system-harfbuzz
             -skip qtactiveqt
             -skip qtandroidextras
             -skip qtcharts
             -skip qtconnectivity
             -skip qtgamepad
             -skip qtlocation
             -skip qtlottie
             -skip qtpurchasing
             -skip qtsensors
             -skip qtspeech
             -skip qtvirtualkeyboard
             -skip qtwayland
             -skip qtwebchannel
             -skip qtwebengine
             -skip qtwebglplugin
             -skip qtwebsockets
             -skip qtwebview
             -I$(path)/3rdparty/build/macosx.debug/$(arch)/include 
             -L$(path)/3rdparty/build/macosx.debug/$(arch)/lib &&
	     
make install
```

Note: We leave out mobile and web components, remove skip if needed by project.
If skipped the modules will not be included in 3rdpart Pyside2 when built.

3rdparty tools:

```shell
make verbose=1 build_libs=1 (build_extras=1) (debug)
```

## 3rdparty advanced ##

The 3rdparty library can be built from the top directory by typing 
make. Advanced users can use CMake directly, see CMakeLists.txt.

The build will create both a build and a dist directory. The build directory
contains both libraries and binary files suitable for development and test 
while the dist directory contains the final library files for distribution.
Only includes, libraries and pkgconfig files will be copied to the dist 
directory.

For both the build and dist directory a platform directory will be
created with the name of the platform you are building for (e.g. linux,
macosx or win).

See the MANIFEST file for the main projects and their dependencies.


## 3rdparty make ##


Make targets you should know about:

```shell
make                      Build all projects for development and test in 
			  'build/platform'
make debug                Build all projects with debugging symbols when
			  possible.
make clean                Get rid of all the temporary files in 'build/platform'.
make help                 Print all the make options
```

Additionally, a few helpful modifiers alter some build-time options:

```shell
make verbose=0 ...        Show all compilation commands
make build_libs=1 ...     Build libraries
make build_viewers=1 ...  Build viewers
make build_autotools=1 ...Build autotools
make build_media=1 ...    Build media
```

## Github ##

  * Project  https://github.com/mikaelsundell/3rdparty
  * Issues   https://github.com/mikaelsundell/3rdparty/issues
  * Wiki     https://github.com/mikaelsundell/3rdparty/wiki

## Contact ##

Mikael Sundell - mikael.sundell@gmail.com

## License ##

3rdparty packages and their copyrights:

Aces container Copyright
Copyright © 2013 Academy of Motion Picture Arts and Sciences.

Autoconf Copyright
Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

Automake Copyright
Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

Boost Copyright
Copyright Beman Dawes, David Abrahams, 1998-2005.
Copyright Rene Rivera 2004-2007.

bzip2 Copyright 
Copyright © 1996-2007 Julian Seward.

CMake Copyright
Copyright 2006-2010 Kitware, Inc.
Copyright 2006 Alexander Neundorf <neundorf@kde.org>

CTL Copyright
Copyright © 2006 Academy of Motion Picture Arts and Sciences

FFmpeg Copyright
Copyright (c) Fabrice Bellard

FLTK Copyright
Copyright 1998-2011 by Bill Spitzak and others.

Gettext Copyright
Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

GLEW Copyright
Copyright (C) 2002-2007, Milan Ikits <milan ikits[]ieee org>
Copyright (C) 2002-2007, Marcelo E. Magallon <mmagallo[]debian org>
Copyright (C) 2002, Lev Povalahev

GLM Copyright
Copyright (c) 2005 - 2013 G-Truc Creation

GTest Copyright
Copyright 2005, Google Inc.

HDF5 Copyright
Copyright by The HDF Group.
Copyright by the Board of Trustees of the University of Illinois.
All rights reserved. 

Ilmbase Copyright
Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

Jasper Copyright
Copyright (c) 2001-2006 Michael David Adams
Copyright (c) 1999-2000 Image Power, Inc.
Copyright (c) 1999-2000 The University of British Columbia

Jpeg Copyright
Copyright (C) 1991-1997, Thomas G. Lane.

Lcms Copyright
Copyright (c) 1998-2012 Marti Maria Saguer

Libpng Copyright
Copyright (c) 1998-2009 Glenn Randers-Pehrson
(Version 0.96 Copyright (c) 1996, 1997 Andreas Dilger)
(Version 0.88 Copyright (c) 1995, 1996 Guy Eric Schalnat, Group 42, Inc.)

Libtool Copyright
Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

LibWebp
Copyright 2010 Google Inc. All Rights Reserved.

OCIO Copyright
Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

OIIO Copyright
Copyright 2008 Larry Gritz and the other authors and contributors.
All Rights Reserved.

OpenEXR Copyright
Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

pkg-config Copyright
Copyright (C) 2001, 2002 Red Hat Inc.

Tiff Copyright
Copyright (c) 1988-1997 Sam Leffler
Copyright (c) 1991-1997 Silicon Graphics, Inc.

x264 Copyright
Copyright (C) 2003-2013 x264 project

yasm Copyright
Copyright (c) 2001-2007 Peter Johnson

Zlib Copyright
Copyright (C) 1995-2004 Jean-loup Gailly.

See LICENSE.txt for details.
