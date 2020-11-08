##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  Master CMakeLists.txt for 3rdparty
##  
##  Run 'make help' to list helpful options.
##
##-*****************************************************************************

cmake_minimum_required( VERSION 3.0 )

# project configuration
message( STATUS "Project configuration" )
project( 3rdparty )

# general configuration
message( STATUS "General configuration" )

# build variables
set( build_dir
    ${PROJECT_BINARY_DIR}
    CACHE
    STRING
    "Build dir"
)

set( build_base
    ON
    CACHE
    BOOL
    "Build libs"
)

set( build_libs  
    OFF
    CACHE
    BOOL
    "Build libs"
)

set( build_viewers 
    OFF
    CACHE
    BOOL
    "Build viewers"
)

set( build_autotools 
    OFF
    CACHE
    BOOL
    "Build autotools"
)

set( build_tests
    OFF
    CACHE
    BOOL
    "Build tests" 
)

set( build_media
    OFF
    CACHE
    BOOL
    "Build media" 
)

set( build_summary
    OFF
    CACHE
    BOOL
    "Build help" 
)

# cmake variables
set( CMAKE_SHARED_LIBS 
    ON 
    CACHE 
    BOOL 
    "Build 3rdparty shared libraries"
)

set( CMAKE_VERBOSE_MAKEFILE 
    ON 
    CACHE 
    BOOL 
    "Build verbose debug or release version"
)

set( CMAKE_BUILD_TYPE 
    Debug 
    CACHE 
    STRING 
    "Build debug or release version"
)

# test
if( ${PROJECT_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    MESSAGE( FATAL_ERROR "Not allowed to run in-source build!" )
endif()

# define system

# cmake defines APPLE, UNIX and WIN32
if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    SET( LINUX TRUE )
endif()

# define properties

# vcc use folders
set_property( GLOBAL PROPERTY USE_FOLDERS ON )

# define repo
set( repo_url http://s3-eu-west-1.amazonaws.com/mikaelsundell/3rdparty )

# define dirs
set( build_bin_dir ${build_dir}/bin )
set( build_inc_dir ${build_dir}/include )
set( build_lib_dir ${build_dir}/lib )
set( build_framework_dir ${build_dir}/Frameworks )
set( build_plugins_dir ${build_dir}/plugins )
set( build_test_dir ${build_dir}/test )
set( build_media_dir ${build_dir}/media )
set( build_cmake_dir ${build_dir}/cmake )

set( dist_bin_dir ${dist_dir}/bin )
set( dist_lib_dir ${dist_dir}/lib )
set( dist_framework_dir ${dist_dir}/Frameworks )
set( dist_plugins_dir ${dist_dir}/plugins )

IF( APPLE )
    set( build_prefix_lib ${build_lib_dir} )
    set( build_prefix_framework ${build_framework_dir} )
    set( build_prefix_plugins ${build_plugins_dir} )
ENDIF()

set( build_cmake "build_cmake" )

# define commands
if( CMAKE_VERBOSE_MAKEFILE )
    SET( untar tar -xpvf )
else()
    SET( untar tar -xpf )
endif()

if( CMAKE_VERBOSE_MAKEFILE )
    SET( unzip unzip -o )
else()
    SET( unzip unzip -oq )
endif()

# test if wget is present
exec_program( command ARGS -v wget OUTPUT_VARIABLE wget )
if ( wget )
    SET( download wget -N --verbose )
else()
# -C skips the file if it's already downloaded
    set( download curl -OJL --verbose )
endif()

# FIXME(mikael.sundell@gmail.com): cmake currently does not handle wildcards
# SET( copy cmake -E copy )
set( copy cp -f )
set( copy_dir ${CMAKE_COMMAND} -E copy_directory )
set( make_dir ${CMAKE_COMMAND} -E make_directory )

# define modules
list(
  APPEND CMAKE_MODULE_PATH
  "${PROJECT_SOURCE_DIR}/src/cmake"
)
include (buildutils)

# define prefix
set( shared_lib_prefix ${CMAKE_SHARED_LIBRARY_PREFIX} )
set( static_lib_prefix ${CMAKE_STATIC_LIBRARY_PREFIX} )

if( CMAKE_SHARED_LIBS )
    set( lib_prefix ${shared_lib_prefix} ) 
else()
    set( lib_prefix ${static_lib_prefix} ) 
endif()

# define suffix
set( shared_lib_suffix ${CMAKE_SHARED_LIBRARY_SUFFIX} )
set( static_lib_suffix ${CMAKE_STATIC_LIBRARY_SUFFIX} )

if( CMAKE_SHARED_LIBS )
    set( lib_suffix ${shared_lib_suffix} ) 
else()
    set( lib_suffix ${static_lib_suffix} ) 
endif()

# define flags
if( UNIX )
    if( APPLE )
        find_program( cmd_sysctl "sysctl")
        if( cmd_sysctl )
            EXECUTE_PROCESS( COMMAND ${cmd_sysctl} -n hw.physicalcpu OUTPUT_VARIABLE cpus )
            STRING( REGEX REPLACE "^.*([0-9]+).*$" "\\1" num_cpus "${cpus}" ) 
        endif()
    else()
        set( cpuinfo_file "/proc/cpuinfo" )
        if( EXISTS "${cpuinfo_file}" )
            FILE( STRINGS "${cpuinfo_file}" procs REGEX "^processor.: [0-9]+$" )
            LIST( LENGTH procs num_cpus )
        endif()
    endif()
endif()

SET( build_flags ${build_flags} -j${num_cpus} --load-average=${num_cpus} )

# define env
if( UNIX )
    if( APPLE )
        # dynamic linker (tests during build)
        set( build_env 
            unset DYLD_LIBRARY_PATH &&
            export DYLD_FALLBACK_LIBRARY_PATH=${build_lib_dir}
        )
    else()
        # important - only use build_env with non cmake projects as it
        # will conflict with CMAKE_PREFIX_PATH, cmake will think libraries
        # were found in native search paths and not use absolute paths
        # for shared libraries and skip defining rpaths for the build_dir 
        # dependencies.
        set( build_env
            export C_INCLUDE_PATH=${build_inc_dir} &&
            export CPLUS_INCLUDE_PATH=${build_inc_dir} &&
            export LIBRARY_PATH=${build_lib_dir} &&
            export LD_LIBRARY_PATH=${build_lib_dir} # for test programs.
        )
    endif()
endif()

# build configuration

MESSAGE( STATUS "Build configuration" )

if( build_base )

    MESSAGE( STATUS "Adding base" )
    build_add_project( 
              bzip2
              DIR ${CMAKE_SOURCE_DIR}/src/bzip2
              DESCRIPTION "Bzip2"
              BUILD ON
    )
    build_add_project(
              boost
              DIR ${CMAKE_SOURCE_DIR}/src/boost
              DESCRIPTION "Boost C++ Libraries"
              BUILD ON
    )
    build_add_project(
               jasper
               DIR ${CMAKE_SOURCE_DIR}/src/jasper
               DESCRIPTION "Jasper"
               BUILD ON
    )
    build_add_project(
              giflib
              DIR ${CMAKE_SOURCE_DIR}/src/giflib
              DESCRIPTION "Giflib"
              BUILD ON
    )
    build_add_project(
              jpeg
              DIR ${CMAKE_SOURCE_DIR}/src/jpeg
              DESCRIPTION "Jpeg"
              BUILD ON
    )
    build_add_project(
              libpng
              DIR ${CMAKE_SOURCE_DIR}/src/libpng
              DESCRIPTION "LibPNG"
              BUILD ON
    )
    build_add_project(
              libwebp
              DIR ${CMAKE_SOURCE_DIR}/src/libwebp
              DESCRIPTION "LibWebp"
              BUILD ON
    )
    build_add_project(
              openjpeg
              DIR ${CMAKE_SOURCE_DIR}/src/openjpeg
              DESCRIPTION "OpenJpeg"
              BUILD ON
    )
    build_add_project(
              tiff
              DIR ${CMAKE_SOURCE_DIR}/src/tiff
              DESCRIPTION "LibTiff - TIFF Libraries and Utilities"
              BUILD ON
    )
    build_add_project(
              zlib
              DIR ${CMAKE_SOURCE_DIR}/src/zlib
              DESCRIPTION "Zlib"
              BUILD ON
    )
ENDIF()

IF( build_libs )

    MESSAGE( STATUS "Adding libs" )

    build_add_project(
              ffmpeg
              DIR ${CMAKE_SOURCE_DIR}/src/ffmpeg
              DESCRIPTION "FFmpeg"
              BUILD ON
    )
    build_add_project(
              freetype
              DIR ${CMAKE_SOURCE_DIR}/src/freetype
              DESCRIPTION "Freetype"
              BUILD ON
    )
    build_add_project(
              glew
              DIR ${CMAKE_SOURCE_DIR}/src/glew
              DESCRIPTION "The OpenGL Extension Wrangler Library"
              BUILD ON
    )
    build_add_project(
              glm
              DIR ${CMAKE_SOURCE_DIR}/src/glm
              DESCRIPTION "OpenGL Mathematics (GLM)"
              BUILD ON
    )
    build_add_project(
              lcms2
              DIR ${CMAKE_SOURCE_DIR}/src/lcms2
              DESCRIPTION "Lcms2"
              BUILD ON
    )
    build_add_project(
              oiio
              DIR ${CMAKE_SOURCE_DIR}/src/oiio
              DESCRIPTION "OpenImageIO"
              BUILD ON
    )
    build_add_project(
              ocio
              DIR ${CMAKE_SOURCE_DIR}/src/ocio
              DESCRIPTION "OpenColorIO"
              BUILD ON
    )
    build_add_project(
              openexr
              DIR ${CMAKE_SOURCE_DIR}/src/openexr
              DESCRIPTION "OpenEXR"
              BUILD ON
    )
    build_add_project(
              pkg-config
              DIR ${CMAKE_SOURCE_DIR}/src/pkg-config
              DESCRIPTION "pkg-config"
              BUILD ON
    )
    build_add_project(
              pybind
              DIR ${CMAKE_SOURCE_DIR}/src/pybind
              DESCRIPTION "Pybind"
              BUILD ON
    )

    build_add_project(
              x264
              DIR ${CMAKE_SOURCE_DIR}/src/x264
              DESCRIPTION "x264"
              BUILD ON
    )
    build_add_project(
              yasm
              DIR ${CMAKE_SOURCE_DIR}/src/yasm
              DESCRIPTION "yasm"
              BUILD ON
    )
ENDIF()

# build autotools

if( build_autotools )

    build_info( "Adding autotools" )
    build_add_project(
              gettext
              DIR ${CMAKE_SOURCE_DIR}/src/gettext
              DESCRIPTION "Gettext"
              BUILD ON
    )
    build_add_project(
              autoconf
              DIR ${CMAKE_SOURCE_DIR}/src/autoconf
              DESCRIPTION "Autoconf"
              BUILD ON
    )
    build_add_project(
              automake
              DIR ${CMAKE_SOURCE_DIR}/src/automake
              DESCRIPTION "Automake"
              BUILD ON
    )
    build_add_project(
              libtool
              DIR ${CMAKE_SOURCE_DIR}/src/libtool
              DESCRIPTION "Libtool"
              BUILD ON
    )
endif()
 
# build media
if( build_media )

    build_info( "Adding media" )
    build_add_project(
              jpeg2000_images
              DIR ${CMAKE_SOURCE_DIR}/src/jpeg2000_images
              DESCRIPTION "Jpeg2000 images"
              BUILD ON
    )
    build_add_project(
              ocio-images
              DIR ${CMAKE_SOURCE_DIR}/src/ocio-images
              DESCRIPTION "OpenColorIO images"
              BUILD ON
    )
    build_add_project(
              oiio-images
              DIR ${CMAKE_SOURCE_DIR}/src/oiio-images
              DESCRIPTION "OpenImageIO images"
              BUILD ON
    )
    build_add_project(
              openexr-images
              DIR ${CMAKE_SOURCE_DIR}/src/openexr-images
              DESCRIPTION "OpenEXR images"
              BUILD ON
    )
endif()

# summary
IF( build_summary )
    build_info( "Summary" )
    build_info( "Host configuration" )
    build_info( " CMAKE_HOST_SYSTEM_NAME = ${CMAKE_HOST_SYSTEM_NAME}" )
    build_info( " CMAKE_HOST_SYSTEM_PROCESSOR = ${CMAKE_HOST_SYSTEM_PROCESSOR}" )
    build_info( " CMAKE_HOST_SYSTEM_VERSION = ${CMAKE_HOST_SYSTEM_VERSION}" )
    build_info( "CMake configuration" )
    build_info( " CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
    build_info( " CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")
    build_info( " CMAKE_SHARED_LIBS = ${CMAKE_SHARED_LIBS}")
    build_info( " CMAKE_VERBOSE_MAKEFILE = ${CMAKE_VERBOSE_MAKEFILE}")
    build_info( "Build configuration" )
    build_info( " build_dir = ${build_dir}")
    build_info( " build_flags = ${build_flags}")
    build_info( " build_base = ${build_base}")
    build_info( " build_libs = ${build_libs}")
    build_info( " build_viewers = ${build_viewers}")
    build_info( " build_media = ${build_media}")
    build_info( "Usage" )
    build_info( " Change a configuration value with: cmake -D<variable>=<value>" )
ENDIF()
