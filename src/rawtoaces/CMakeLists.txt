##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  rawtoaces CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# rawtoaces Copyright
# Copyright (c) 2013 Academy of Motion Picture Arts and Sciences

# rawtoaces from github.com master 2022-06-01
# https://github.com/AcademySoftwareFoundation/rawtoaces

build_info( " Adding rawtoaces project" )

# project configuration

# project name
set( project_name "rawtoaces" )

# project pkg
set( project_pkg ${project_name} )

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
    rawtoaces
)

# inc dir
set( inc_dir
    rawtoaces
)

# lib files
set( lib_files
    rawtoaces_idt
    rawtoaces_util
)

# pkgfiles
set( pkg_files
    RAWTOACES.pc
)

IF( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    set( lib_version "0.1.0" )

    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
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

    # options
    set( build_options ${build_options} -DCMAKE_CXX_STANDARD=17 )

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options ${build_options} -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir}
              -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
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

# dependencies
add_dependencies( ${project_name} aces_container ceres-solver )
