##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  bzip2 CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# bzip2 Copyright
# Copyright © 1996-2007 Julian Seward.

# bzip2 from bzip.org 2012-12-15
# http://www.bzip.org/

build_info( " Adding bzip2 project" )

# project configuration

# project name
set( project_name "bzip2" )

# project pkg
set( project_pkg ${project_name}-1.0.6 )

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
    bzcat
    bzdiff
    bzgrep
    bzip2
    bzip2recover
    bzmore
)

# include files
set( inc_files
    bzlib.h
)

# lib files
set( lib_files
    bz2.1.0.6
    bz2.1.0
    bz2
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
    
    # patch - change from static to shared libs
    if( CMAKE_SHARED_LIBS )
        if( APPLE )
            set( build_patch
                ${copy} ${project_src_dir}/Makefile.apple ${project_bin_dir}/${project_pkg}/Makefile
            )
        else()
            set( build_patch
                ${copy} ${project_src_dir}/Makefile.linux ${project_bin_dir}/${project_pkg}/Makefile
            )
        endif()
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        make PREFIX=${build_dir} install
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
        OUTPUT ${inc_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_patch}
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

