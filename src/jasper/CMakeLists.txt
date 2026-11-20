# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: jasper-master
# Archive: jasper-master.zip
# Upstream copyright and license notices: licenses/third-party/jasper/

build_info( " Adding jasper project" )

# project configuration

# project name
set( project_name "jasper" )

# project pkg
set( project_pkg "jasper-master" )

# project archive
set( project_arc ${project_pkg}.zip )

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

# platform-specific outputs
if( WIN32 )
    set( lib_files jasper )
    set( bin_files imgcmp imginfo jasper )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    set( inc_files jasper/jasper.h )
    build_add_files( "jasper.pc" "${build_lib_dir}/pkgconfig" pkg_output )
else()
    # bin files
    set( bin_files
        imgcmp
        jasper
        jiv
    )

    # lib files
    set( lib_files
        jasper.5.0.0
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# build configuration

if( WIN32 )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DJAS_ENABLE_SHARED=${CMAKE_SHARED_LIBS}
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_OPENGL=OFF
        -DJAS_ENABLE_DOC=OFF
        -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON
    )

    set( build_output ${lib_output} ${bin_output} ${inc_output} ${pkg_output} ${cmake_output} )

    build_add_dependencies( ${project_name} jpeg )
else()
    # options
    set( build_options -DCMAKE_VERBOSE_MAKEFILE=true )

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

    set( build_output ${bin_output} ${lib_output} )

    set( build_options
        ${build_options}
    )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
