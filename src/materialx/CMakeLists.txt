##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  materialx CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# Materialx Copyright
# TM & (c) 2017 Lucasfilm Entertainment Company Ltd. and Lucasfilm Ltd.
# All rights reserved.  See LICENSE.txt for license.

# materialx from github 2022-03-26
# https://github.com/AcademySoftwareFoundation/MaterialX/releases/tag/v1.38.3

build_info( " Adding materialx project" )

# project configuration

# project name
set( project_name "materialx" )

# project pkg
set( project_pkg ${project_name}-1.38.3 )

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
    MaterialXView
)

# inc dir
SET( inc_dir
    MaterialXCore
    MaterialXFormat
    MaterialXGenGlsl
    MaterialXGenMdl
    MaterialXGenOsl
    MaterialXGenShader
    MaterialXRender
    MaterialXRenderGlsl
    MaterialXRenderHw
    MaterialXRenderOsl
)

# lib files
set( lib_files
    MaterialXCore
    MaterialXFormat
    MaterialXGenGlsl
    MaterialXGenMdl
    MaterialXGenOsl
    MaterialXGenShader
    MaterialXRender
    MaterialXRenderGlsl
    MaterialXRenderHw
    MaterialXRenderOsl
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

    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options ${build_options} -DOIIO_LIBNAME_SUFFIX=_d )
    endif()

    # config
    set( build_config ${build_config} -DMATERIALX_BUILD_SHARED_LIBS=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_OIIO=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_PYTHON=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_VIEWER=true )
    set( build_config ${build_config} -DOPENIMAGEIO_ROOT_DIR=${build_dir} )
    set( build_config ${build_config} -DMATERIALX_NANOGUI_EXTERNAL=true )
    set( build_config ${build_config} -DNANOGUI_ROOT=${build_dir} )
    set( build_config ${build_config} -DCMAKE_CXX_STANDARD=14 )
    set( build_config ${build_config} -DCMAKE_CXX_FLAGS="-I${build_inc_dir}/eigen3" )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir} 
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DPYTHON_EXECUTABLE=${build_python3}
            -DPYTHON_INCLUDE_DIR=${build_python3_include_dir}
            -DPYTHON_LIBRARY=${build_python3_library_dir}
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

# dependencies
add_dependencies( ${project_name} nanogui oiio )
