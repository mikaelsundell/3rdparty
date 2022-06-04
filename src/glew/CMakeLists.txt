##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  glew CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# glew Copyright
# Copyright (C) 2002-2007, Milan Ikits <milan ikits[]ieee org>
# Copyright (C) 2002-2007, Marcelo E. Magallon <mmagallo[]debian org>
# Copyright (C) 2002, Lev Povalahev

# flew from sourceforge.net/projects/glew 2.2.0 2020-08-04
# https://sourceforge.net/projects/glew/files/glew/2.2.0

build_info( " Adding glew project" )

# project configuration

# project name
set( project_name "glew" )

# project pkg
set( project_pkg ${project_name}-2.2.0 )

# project archive
set( project_arc ${project_pkg}.tgz )

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
    GL
)

# lib files
set( lib_files
    GLEW.2.2.0
)

# pkgfiles
set( pkg_files
    glew.pc
)

if( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
endif()

# build configuration

# unix

if( UNIX )

    # download
    SET( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    SET( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # make and install
    SET( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        make GLEW_PREFIX=${build_dir} GLEW_DEST=${build_dir} install
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
