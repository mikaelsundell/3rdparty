##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  libpng CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# libpng Copyright
# Copyright (c) 1998-2009 Glenn Randers-Pehrson
# (Version 0.96 Copyright (c) 1996, 1997 Andreas Dilger)
# (Version 0.88 Copyright (c) 1995, 1996 Guy Eric Schalnat, Group 42, Inc.)

# libpng from sourceforge.net/projects/libpng 1.2.40 2011-11-18
# https://sourceforge.net/projects/libpng/files/libpng15/1.5.6

build_info( " Adding libpng project" )

# project configuration

# project name
set( project_name "libpng" )

# project pkg
set( project_pkg ${project_name}-1.5.6 )

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
    libpng15-config
)

# inc files
set( inc_files
    png.h
    pngconf.h
    pnglibconf.h
)

# inc dir
set( inc_dir
    libpng15
)

# lib files
if( CMAKE_SHARED_LIBS )
    set( lib_files
        png
        png15
        png15.15
    )
    # 15.6.0 is not built on apple
    if( LINUX )
        set( ${lib_files}
             png15.15.6.0
        )
    endif()
else()
    set( lib_files
        png
    )
endif()

# pkgfiles
set( pkg_files
    libpng.pc
    libpng15.pc
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

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
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
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
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

    # configure, make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    set( build_output ${bin_output} )

    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_add_script( 
        "${build_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        build_script
    )

    build_add_check( 
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

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)
