# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: libjpeg-turbo-2.1.3
# Archive: libjpeg-turbo-2.1.3.tar.gz
# Upstream copyright and license notices: licenses/third-party/libjpeg-turbo/

build_info( " Adding libjpeg-turbo project" )

# project configuration

# project name
set( project_name "libjpeg-turbo" )

# project pkg
set( project_pkg ${project_name}-2.1.3 )

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

# platform-specific outputs
if( WIN32 )
    build_add_files( "turbojpeg-static${CMAKE_STATIC_LIBRARY_SUFFIX}" "${build_dir}/libjpeg-turbo/lib" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "turbojpeg${CMAKE_SHARED_LIBRARY_SUFFIX}" "${build_dir}/libjpeg-turbo/bin" runtime_output )
    endif()
    set( bin_files tjbench )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    build_add_files( "${bin_files}" "${build_dir}/libjpeg-turbo/bin" bin_output )
    set( inc_files turbojpeg.h )
    build_add_files( "${inc_files}" "${build_dir}/libjpeg-turbo/include" inc_output )
    set( cmake_files libjpeg-turboConfig.cmake libjpeg-turboConfigVersion.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/libjpeg-turbo/lib/cmake/libjpeg-turbo" cmake_output )
else()
    # include files
    set( inc_files
        jconfig.h
        jerror.h
        jmorecfg.h
        jpeglib.h
    )

    # lib files
    set( lib_files
        jpeg.62.3.0
        turbojpeg.0.2.0
    )

    # inc files
    build_add_files(
        "${inc_files}" "${build_inc_dir}" inc_output
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

# build configuration

if( WIN32 )
    # options
    set( build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DCMAKE_INSTALL_PREFIX=${build_dir}/libjpeg-turbo"
        -DENABLE_SHARED=${CMAKE_SHARED_LIBS}
        -DENABLE_STATIC=ON
        -DWITH_TESTS=OFF
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
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

    set( build_output ${bin_output} ${lib_output} )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
