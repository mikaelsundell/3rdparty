# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: nanogui-master-240216
# Archive: nanogui-master-240216.tar.gz
# Upstream copyright and license notices: licenses/third-party/nanogui/

build_info( " Adding nanogui project" )

# project configuration

# project name
set( project_name "nanogui" )

# project pkg
set( project_pkg ${project_name}-master-240216 )

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

# lib files
set( lib_files
    nanogui
)

# lib files
build_add_libs(
    "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
)

# build configuration

# options
if( CMAKE_SHARED_LIBS )
    SET( build_options -DBUILD_SHARED_LIBS=true )
else()
    SET( build_options -DBUILD_SHARED_LIBS=false )
endif()

# configure, make and install
set( build_make
    ${build_env} &&
    cd ${project_name} &&
    mkdir -p ${build_cmake} &&
    cd ${build_cmake} &&
    cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        ${build_options} &&
    make ${build_flags} &&
    make install
)

# copy include
set( build_include
    cd ${project_name} &&
    "\"${CMAKE_COMMAND}\" -E copy_directory" ./ext/glfw/include/GLFW ${build_dir}/include/GLFW &&
    ${copy} ./ext/nanovg/src/fontstash.h ${build_dir}/include/fontstash.h &&
    ${copy} ./ext/nanovg/src/nanovg_gl_utils.h ${build_dir}/include/nanovg_gl_utils.h &&
    ${copy} ./ext/nanovg/src/nanovg_gl.h ${build_dir}/include/nanovg_gl.h &&
    ${copy} ./ext/nanovg/src/nanovg.h ${build_dir}/include/nanovg.h &&
    ${copy} ./ext/nanovg/src/stb_image.h ${build_dir}/include/stb_image.h &&
    ${copy} ./ext/nanovg/src/stb_truetype.h ${build_dir}/include/stb_truetype.h
)

string( JOIN " " build_make ${build_make} )
string( JOIN " " build_include ${build_include} )
set( build_make
    COMMAND sh -c "${build_make}"
    COMMAND sh -c "${build_include}"
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
set( build_output ${bin_output} ${lib_output} )
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output}
)

# dependencies
build_add_dependencies( ${project_name} pybind )
