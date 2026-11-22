# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: yasm-1.3.0
# Archive: yasm-1.3.0.tar.gz
# Upstream copyright and license notices: licenses/third-party/yasm/

build_info( " Adding yasm project" )

# project configuration

# project name
set( project_name "yasm" )

# project pkg
set( project_pkg ${project_name}-1.3.0 )

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
    vsyasm
    yasm
    ytasm
)

# inc dirs
set( inc_dirs
    libyasm-stdint.h
    libyasm.h
)

# lib files
set( lib_files
    yasm
)

# pkgfiles
set( pkg_files
)

# bin files
build_add_files(
    "${bin_files}" "${build_bin_dir}" bin_output
)

# inc files
build_add_files(
    "${inc_files}" "${build_inc_dir}" inc_output
)

# lib files
# yasm only provides static libraries
build_add_libs(
    "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${static_lib_suffix} lib_output
)

# pkg files
build_add_files(
    "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
)

# build configuration

# configure, make and install
SET( build_make
    ${build_env} &&
    cd ${project_pkg} &&
    ./configure
        --prefix=${build_dir}
        CFLAGS=-I${build_inc_dir}
        CPPFLAGS=-I${build_inc_dir}
        LDFLAGS=-L${build_lib_dir}
        ${build_options} &&
    make ${build_flags} &&
    make install
)

string( JOIN " " build_make ${build_make} )
set( build_make COMMAND sh -c "${build_make}" )

# scripts
set( build_output ${bin_output} ${lib_output} )

build_install_check(
    "${build_output}"
    build_check
)

# run
set( build_output ${bin_output} ${lib_output} )
build_add_archive_rule()

# Custom target builds missing or outdated installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output}
)
