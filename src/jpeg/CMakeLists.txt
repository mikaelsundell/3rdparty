# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# jpeg Copyright
# Copyright (C) 1991-1997, Thomas G. Lane.

# jpeg from ijg.org 9f 2025-12-21
# http://www.ijg.org/files/

build_info( " Adding jpeg project" )

# project configuration

# project name
set( project_name "jpeg" )

# project pkg
set( project_pkg ${project_name} )

# project archive
set( project_arc ${project_pkg}src.v9f.tar.gz )

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
    cjpeg
    djpeg
    jpegtran
    rdjpgcom
    wrjpgcom
)

# inc files
set( inc_files
    jconfig.h
    jerror.h
    jmorecfg.h
    jpeglib.h
)

# lib files
SET( lib_files
    jpeg.9
)
# 9.3.0 is not built on apple
if( LINUX )
    SET( ${lib_files}
         jpeg.9.3.0
    )
endif()

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
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg}-9f &&
        ./configure 
            --prefix=${build_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )
    
    # scripts
    set( build_output ${bin_output} )

    IF ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    ENDIF()

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
        OUTPUT ${bin_output} ${inc_output} ${lib_output}
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
