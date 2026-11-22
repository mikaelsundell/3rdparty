# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: tiff-4.0.3
# Archive: tiff-4.0.3.tar.gz
# Upstream copyright and license notices: licenses/third-party/tiff/

build_info( " Adding tiff project" )

# project configuration

# project name
set( project_name "tiff" )

# project pkg
set( project_pkg ${project_name}-4.0.3 )

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
    tiff.h
    tiffconf.h
    tiffio.h
    tiffio.hxx
    tiffvers.h
)

include( "${CMAKE_CURRENT_LIST_DIR}/outputs.cmake" )

# platform-specific outputs
if( WIN32 )
    set( lib_files tiff tiffxx )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
else()

    # lib files
    set( lib_files
        tiff.5
        tiffxx.5
    )
    # 4.0.3 is not built on apple
    if( LINUX )
        set( ${lib_files}
             tiff.5.0.3
             tiffxx.5.0.3
        )
    endif()

    # pkgfiles
    set( pkg_files
        libtiff-4.pc
    )

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/modern-msvc-stdio.patch"
        "${project_src_dir}/msvc/export-exif-directory-api.patch"
    )
    list( APPEND build_patch
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${project_src_dir}/msvc/CMakeLists.txt"
            "${project_bin_dir}/${project_pkg}/CMakeLists.txt"
    )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

    set( build_output ${lib_output} ${bin_output} ${inc_output} )
else()
    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options --enable-debug )
    endif()

    if( CMAKE_SHARED_LIBS )
        set( build_options ${build_options} --enable-shared --disable-static )
    else()
        set( build_options ${build_options} --enable-static --disable-shared )
    endif()

    # HAVE_APPLE_OPENGL_FRAMEWORK needed on apple since 4.0.3

    if( APPLE )
        set( CFLAGS CFLAGS=-DHAVE_APPLE_OPENGL_FRAMEWORK )
    endif()

    # configure, make and install

    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        ./configure
            --prefix=${build_dir}
            ${CFLAGS}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
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

# dependencies
build_add_dependencies( ${project_name} jpeg zlib-ng )
