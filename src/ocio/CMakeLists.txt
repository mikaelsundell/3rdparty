##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  OCIO CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# OCIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# ocio from github.com master 2020-08-04
# https://github.com/AcademySoftwareFoundation/OpenColorIO

build_info( " Adding ocio project" )

# project configuration

# project name
set( project_name "ocio" )

# lib pkg
set( project_pkg "OpenColorIO-201108" )

# project archive
set( project_arc ${project_pkg}.zip )

# project url
set( project_url ${repo_url}/${project_arc} )

# project config
set( project_cfg_cmake_prefix TRUE )

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
    ociobakelut
    ociocheck
    ociowrite
    ociomakeclf
    ociochecklut
    ocioconvert
    ociodisplay
    ocioperf
    ociolutimage
)

# inc dir
set( inc_dir
    OpenColorIO
)

# lib files
set( lib_files
    OpenColorIO.2.0.0
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
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    set( build_options -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} )
    set( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=true )

    if( project_cfg_cmake_prefix )
        set( build_make
            ${build_make}
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    endif()
            
    # make and install
    if( project_cfg_cmake_prefix )
        set( build_make
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    endif()

    set( build_make
        ${build_make}
        cd OpenColorIO-master &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        export OIIO_PATH=${build_dir} &&
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

# custom target, always run
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} oiio lcms2 )
