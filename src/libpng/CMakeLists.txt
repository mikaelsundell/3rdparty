# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: libpng-1.6.46
# Archive: libpng-1.6.46.tar.gz
# Upstream copyright and license notices: licenses/third-party/libpng/

build_info( " Adding libpng project" )

# project configuration

# project name
set( project_name "libpng" )

# project pkg
set( project_pkg ${project_name}-1.6.46 )

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

# inc files
set( inc_files
    png.h
    pngconf.h
    pnglibconf.h
)

# bin and lib files
if( WIN32 )
    set( bin_files
        pngfix.exe
        png-fix-itxt.exe
    )
    if( CMAKE_SHARED_LIBS )
        set( lib_files libpng16 )
    else()
        set( lib_files libpng16_static )
    endif()
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "d" )
    endif()
else()
    set( bin_files libpng16-config )
    set( lib_files png )
    if( CMAKE_SHARED_LIBS )
        list( APPEND lib_files png16 png16.16 )
    endif()
endif()

# package files
if( WIN32 )
    set( cmake_files
        PNGConfig.cmake
        PNGConfigVersion.cmake
        PNGTargets.cmake
    )
    build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/PNG" cmake_output )
else()
    set( inc_dir libpng16 )
    set( pkg_files
        libpng.pc
        libpng16.pc
    )
    build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
    build_add_files( "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output )
endif()

build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )

# build configuration

# configure, make and install
if( WIN32 )
    if( CMAKE_SHARED_LIBS )
        set( build_static_libs OFF )
    else()
        set( build_static_libs ON )
    endif()
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DPNG_SHARED=${CMAKE_SHARED_LIBS}
        -DPNG_STATIC=${build_static_libs}
        -DPNG_TESTS=OFF
        -DPNG_TOOLS=ON
        "-DZLIB_ROOT=${build_dir}"
    )
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )
else()
    # Keep the upstream Autotools build and its versioned install layout.
    set( build_options "--prefix=${build_dir}" )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( APPEND build_options --enable-debug )
    endif()
    if( CMAKE_SHARED_LIBS )
        list( APPEND build_options --enable-shared --disable-static )
    else()
        list( APPEND build_options --enable-static --disable-shared )
    endif()

    string( JOIN " " configure_env ${build_env} )
    string( JOIN " " make_flags ${build_flags} )
    set( build_make
        COMMAND sh -c
            "${configure_env} && cd \"$1\" && shift && ./configure \"$@\" && make ${make_flags} && make install"
            sh "${project_bin_dir}/${project_pkg}" ${build_options}
    )
endif()

# scripts
if( APPLE AND CMAKE_SHARED_LIBS )
    build_install_script(
        "${lib_output}"
        "${build_dir}"
        "${build_prefix_lib}"
        "${build_prefix_framework}"
        build_script
    )
endif()

# run
set( build_output ${bin_output} ${lib_output} ${inc_output} ${pkg_output} ${cmake_output} )
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} zlib-ng )
