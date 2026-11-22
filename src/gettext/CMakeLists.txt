# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: gettext-0.18.3.1
# Archive: gettext-0.18.3.1.tar.gz
# Upstream copyright and license notices: licenses/third-party/gettext/

build_info( " Adding gettext project" )

# project configuration

# project name
set( project_name "gettext" )

# project pkg
set( project_pkg ${project_name}-0.18.3.1)

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

include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )

# inc files
set( inc_files
    autosprintf.h
    gettext-po.h
)

if( APPLE )
    set( inc_files
        ${inc_files}
        libintl.h
    )
endif()

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
build_add_libs(
    "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
)

# pkg files
build_add_files(
    "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
)

# build configuration

# options
if( CMAKE_SHARED_LIBS )
    set( build_options --enable-shared --disable-static )
else()
    set( build_options --enable-static --disable-shared )
endif()

# configure, make and install
SET( build_make
    ${build_env} &&
    export PATH=${build_bin_dir}:$PATH &&
    cd ${project_pkg} &&
    ./configure
        --prefix=${build_dir}
        ${build_options} &&
    make ${build_flags} &&
    make install
)

# scripts

IF ( APPLE )

    # build output

    SET( build_output ${bin_output} )

    IF ( CMAKE_SHARED_LIBS )
        SET( build_output ${build_output} ${lib_output} )
    ENDIF()

    SET( build_script
        ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh
            --prefix-lib ${build_prefix_lib}
            --prefix-framework ${build_prefix_framework}
            --absolute-path ${build_dir}
            ${build_output}
    )
ENDIF()

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

# run
set( build_output ${bin_output} ${lib_output} )
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output}
)

# dependencies
build_add_dependencies( ${project_name} autoconf )

