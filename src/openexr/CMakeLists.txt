##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# openexr Copyright
# Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

# openexr from github.com 3.1.4 2022-03-19
# https://github.com/AcademySoftwareFoundation/openexr

build_info( " Adding openexr project" )

# project configuration

# project name
set( project_name "openexr" )

# project pkg
set( project_pkg ${project_name}-3.1.4 )

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
    exr2aces
    exrenvmap
    exrheader
    exrinfo
    exrmakepreview
    exrmaketiled
    exrmultipart
    exrmultiview
)

# inc dir
set( inc_dir
    OpenEXR
)

# lib files
set( lib_files
    Iex-3_1
    IlmThread-3_1
    OpenEXR-3_1
    OpenEXRCore-3_1
    OpenEXRUtil-3_1   
)

# pkgfiles
set( pkg_files
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
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_d" )
    endif()

    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.30.4.1${lib_suffix}
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
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        cmake -DZLIB_ROOT=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir}
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
add_dependencies( ${project_name} imath boost zlib )
