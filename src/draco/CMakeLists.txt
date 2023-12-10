##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  draco CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# draco Copyright
# Copyright 2019 The Draco Authors.

# draco from github 2022-03-27
# https://github.com/google/draco/releases/tag/1.5.2

build_info( " Adding draco project" )

# project configuration

# project name
set( project_name "draco" )

# project pkg
set( project_pkg ${project_name}-1.5.2 )

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
    draco_encoder-1.5.2
    draco_decoder-1.5.2  
)

# inc dir
SET( inc_dir
    draco
)

# lib files
set( lib_files
    draco
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

     # config
    set( build_config ${build_config} -DCMAKE_MODULE_PATH=${build_dir}/share/cmake/pybind11 )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        export CPLUS_INCLUDE_PATH=${build_inc_dir} &&
        export LD_LIBRARY_PATH=${build_lib_dir} &&
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

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${lib_output}
)
