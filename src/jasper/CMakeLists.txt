##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  jasper CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# jasper Copyright
# Copyright (c) 2001-2006 Michael David Adams
# Copyright (c) 1999-2000 Image Power, Inc.
# Copyright (c) 1999-2000 The University of British Columbia

# jasper from github.com/jasper-software/jasper 2020-10-25
# https://github.com/jasper-software/jasper

build_info( " Adding jasper project" )

# project configuration

# project name
set( project_name "jasper" )

# project pkg
set( project_pkg "jasper-master" )

# project url
set( project_url ${repo_url}/${project_pkg}.zip )

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
    imginfo
    imgcmp
    jasper
    jiv
)

# inc dir
set( inc_dir
    jasper
)

# lib files
set( lib_files
    jasper.5.0.0
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
        ${untar} ${project_bin_dir}/${project_pkg}.zip -C ${project_bin_dir}
    )

    # options
    set( build_options -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} )
    set( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=true )

    # configure, make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        mkdir ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir} ${build_options} &&
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
