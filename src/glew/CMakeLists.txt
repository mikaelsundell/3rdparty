# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: glew-2.2.0
# Archive: glew-2.2.0.tgz
# Upstream copyright and license notices: licenses/third-party/glew/

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

# platform-specific outputs
if( WIN32 )
    set( lib_files glew32 )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "d" )
    endif()
    set( inc_files GL/glew.h GL/wglew.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files glew-config.cmake glew-targets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/glew" cmake_output )
else()
    # lib files
    set( lib_files
        GLEW.2.2.0
    )

    # pkgfiles
    set( pkg_files
        glew.pc
    )

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )

# build configuration

if( WIN32 )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DBUILD_UTILS=OFF
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}/build/cmake" build_make ${build_options} )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} )
else()
    # make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        make GLEW_PREFIX=${build_dir} GLEW_DEST=${build_dir} install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

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

    set( build_output ${bin_output} ${lib_output} )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
