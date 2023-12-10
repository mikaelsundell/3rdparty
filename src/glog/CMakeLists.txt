##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  glog CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# glog Copyright
# Copyright (c) 2006, Google Inc.

# glog from github.com master 2022-06-01
# https://github.com/google/glog

build_info( " Adding glog project" )

# project configuration

# project name
set( project_name "glog" )

# project pkg
set( project_pkg ${project_name}-master )

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

# inc dir
set( inc_dir
    glog
)

# lib files
set( lib_files
    glog
)

# pkgfiles
set( pkg_files
    libglog.pc
)

IF( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "d" )
    endif()

    set( lib_version "0.7.0" )

    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.${lib_version}${lib_suffix}
            )

	    else()
            # INFO: on UNIX lib files appends version after suffix
            string( REGEX REPLACE 
                "^([^.]+)([.]*)(.*)" 
                "${lib_prefix}\\1${lib_suffix}\\2\\3" 
                lib_file "${lib_file}"
            )

            list( APPEND lib_output 
                ${build_lib_dir}/${lib_file}
            )
	    endif()
    
    endforeach()

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
endif()

# build configuration

# unix

IF( UNIX )

    # download
    SET( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    SET( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # patch
    if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
        set( build_patch              
                patch ${lib_bin_dir}/${lib_pkg}/exrenvmap/blurImage.cpp
                      ${lib_src_dir}/blurImage.cpp.patch
        )
    endif()

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options ${build_options} -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # config
    set( build_config ${build_config} -DCMAKE_CXX_STANDARD=14 )

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir}
              -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
              ${build_options}
              ${build_config} &&
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
        OUTPUT ${dir_output}
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
    DEPENDS ${dir_output}
)
