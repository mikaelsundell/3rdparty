# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# libraw Copyright
# Copyright (C) 2008-2021 LibRaw LLC

# libraw from libraw.org 0.21.1 2023-05-24
# https://www.libraw.org/download

build_info( " Adding libraw project" )

# project configuration

# project name
set( project_name "libraw" )

# project pkg
set( project_pkg ${project_name}-0.21.1 )

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
    4channels
    dcraw_emu
    dcraw_half
    half_mt
    mem_image
    multirender_test
    postprocessing_benchmark
    raw-identify
    rawtextdump
    simple_dcraw
    unprocessed_raw
)

# inc dir
SET( inc_dir
    libraw
)

# lib files
set( lib_files
    raw.23
    raw_r.23
)

# pkgfiles
set( pkg_files
    libraw.pc
    libraw_r.pc
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
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

IF( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    # configure, make and install
    SET( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$$PATH &&
        export PKG_CONFIG_PATH=${build_pkgconfig_dir}:$$PKG_CONFIG_PATH &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            CFLAGS=-I${build_inc_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            --enable-jpeg
            --enable-jasper
            --enable-lcms
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output

        SET( build_output ${bin_output} )

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${build_output} ${lib_output} )
        ENDIF()
    
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    ENDIF()

    # run
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
    DEPENDS ${project_name} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} jpeg jasper lcms2 )
