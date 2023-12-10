##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# opensubdiv Copyright
# Copyright 2022 Pixar

# opensubdiv from github.com master 2022-03-19
# https://github.com/PixarAnimationStudios/OpenSubdiv

build_info( " Adding opensubdiv project" )

# project configuration

# project name
set( project_name "opensubdiv" )

# project pkg
set( project_pkg ${project_name}-master-220324 )

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
    opensubdiv
)

# lib files
set( lib_files
    osdCPU.3.4.4
    osdGPU.3.4.4
)

# pkgfiles
set( pkg_files
)

IF( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
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

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # config
    set( build_config ${build_config} -DBoost_NO_BOOST_CMAKE=false )

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd OpenSubdiv &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir}
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

# dependencies
add_dependencies( ${project_name} onetbb ptex pybind )
