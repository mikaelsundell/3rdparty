##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  libtiff CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# libtiff Copyright
# Copyright (c) 1988-1997 Sam Leffler
# Copyright (c) 1991-1997 Silicon Graphics, Inc.

# libtiff from libtiff.maptools.org 4.1.0 2020-08-04
# ftp://ftp.remotesensing.org/pub/libtiff

build_info( " Adding tiff project" )

# project configuration

# project name
set( project_name "tiff" )

# project pkg
set( project_pkg ${project_name}-4.0.3 )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

# project src dir
set( project_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# project bin dir
set( project_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# bin files
set( bin_files
    bmp2tiff
    fax2tiff
    fax2ps
    gif2tiff
    pal2rgb
    ppm2tiff
    ras2tiff
    raw2tiff
    rgb2ycbcr
    tiff2bw
    tiff2pdf
    tiff2ps
    tiff2rgba
    tiffcmp
    tiffcp
    tiffdither
    tiffdump
    tiffinfo
    tiffmedian
    tiffset
    tiffsplit
    thumbnail
)

# inc files
set( inc_files
    tiff.h
    tiffconf.h
    tiffio.h
    tiffio.hxx
    tiffvers.h
)

# lib files
set( lib_files
    tiff.5
    tiffxx.5
)
# 4.0.3 is not built on apple
if( LINUX )
    set( ${lib_files}
         tiff.5.0.3
         tiffxx.5.0.3
    )
endif()

# pkgfiles
set( pkg_files
    libtiff-4.pc
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc files
    build_add_files( 
        "${inc_files}" "${build_inc_dir}" inc_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
endif()

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options --enable-debug )
    endif()

    if( CMAKE_SHARED_LIBS )
        set( build_options ${build_options} --enable-shared --disable-static )
    else()
        set( build_options ${build_options} --enable-static --disable-shared )
    endif()
    
    # HAVE_APPLE_OPENGL_FRAMEWORK needed on apple since 4.0.3
    
    if( APPLE )
        set( CFLAGS CFLAGS=-DHAVE_APPLE_OPENGL_FRAMEWORK )
    endif()

    # configure, make and install

    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            ${CFLAGS}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    set( build_output ${bin_output} )

    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_install_script( 
        "${build_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        build_script
    )

    build_install_check( 
        "${build_output}" 
        build_check
    )

    # run
    add_custom_command( 
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )

ENDIF()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} jpeg zlib )
