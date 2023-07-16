##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  pcre2 CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# pcre2 Copyright
# Original API code Copyright (c) 1997-2012 University of Cambridge
# New API code Copyright (c) 2016-2020 University of Cambridge

# pcre2 from github.com 10.39 2022-03-19
# https://github.com/PhilipHazel/pcre2

build_info( " Adding pcre2 project" )

# project configuration

# project name
set( project_name "pcre2" )

# project pkg
set( project_pkg ${project_name}-10.32 )

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
    pcre2grep
    pcre2test
)

# include files
set( inc_files
    pcre2.h
    pcre2posix.h
)

# lib files
set( lib_files
    pcre2-8
    pcre2-16
    pcre2-posix
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
    
ENDIF()

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
        SET( build_options -DBUILD_SHARED_LIBS=true )
    else()
        SET( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    # config
    set( build_config ${build_config} -DPCRE2_BUILD_PCRE2_16=true )
    
    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        cmake -DCMAKE_INSTALL_PREFIX=${build_dir} 
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            ${build_options}
            ${build_config} &&
        make ${build_flags} &&
        make install
    )

    # scripts

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
    DEPENDS ${lib_output}
)
