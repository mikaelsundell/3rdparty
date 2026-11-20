# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: OpenSubdiv-master-250306
# Archive: OpenSubdiv-master-250306.tar.gz
# Upstream copyright and license notices: licenses/third-party/opensubdiv/

build_info( " Adding opensubdiv project" )

# project configuration

# project name
set( project_name "opensubdiv" )

# project pkg
set( project_pkg OpenSubdiv-master-250306 )

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
    # Upstream builds static OpenSubdiv libraries on Windows.
    set( lib_files osdCPU.lib osdGPU.lib )
    build_add_files( "${lib_files}" "${build_lib_dir}" lib_output )
    set( inc_files opensubdiv/far/topologyRefiner.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files OpenSubdivConfig.cmake OpenSubdivConfigVersion.cmake OpenSubdivTargets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/OpenSubdiv" cmake_output )
else()
    # lib files
    set( lib_files
        osdCPU
        osdGPU
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    set( lib_version "3.6.0" )

    foreach( lib_file ${lib_files} )
        list( APPEND lib_output
            ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
        )
    endforeach()
endif()

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/OpenSubdiv" build_patch
        "${project_src_dir}/msvc/cmake-tbb-dependency.patch"
    )
    # options
    set( build_options
        -DNO_EXAMPLES=ON
        -DNO_TUTORIALS=ON
        -DNO_TESTS=ON
        -DNO_GL_TESTS=ON
        -DNO_OPENGL=OFF
        -DNO_DX=ON
        -DNO_GLFW=ON
        -DNO_CUDA=ON
        -DNO_OPENCL=ON
        "-DPTEX_LOCATION=${build_dir}"
        "-DTBB_LOCATION=${build_dir}"
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )

    build_add_dependencies( ${project_name} onetbb ptex )
else()
    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=TRUE )
    else()
        set( build_options -DBUILD_SHARED_LIBS=FALSE )
    endif()

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

    build_add_dependencies( ${project_name} onetbb ptex pybind )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/OpenSubdiv" build_make ${build_options}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
