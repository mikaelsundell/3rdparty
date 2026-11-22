# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: libwebp-1.2.2
# Archive: libwebp-1.2.2.tar.gz
# Upstream copyright and license notices: licenses/third-party/libwebp/

build_info( " Adding libwebp project" )

# project configuration

# project name
set( project_name "libwebp" )

# project pkg
set( project_pkg ${project_name}-1.2.2 )

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
    set( lib_files webp webpdecoder webpdemux webpmux )
    set( bin_files cwebp dwebp gif2webp img2webp webpinfo webpmux )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    set( inc_files webp/decode.h webp/encode.h webp/demux.h webp/mux.h )
    build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
    string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
    set( cmake_files WebPConfig.cmake WebPConfigVersion.cmake WebPTargets.cmake "WebPTargets-${build_variant}.cmake" )
    build_add_files( "${cmake_files}" "${build_dir}/share/WebP/cmake" cmake_output )
    set( pkg_files libwebp.pc libwebpdecoder.pc libwebpdemux.pc libwebpmux.pc )
else()
    # bin files
    set( bin_files
        cwebp
        dwebp
    )

    # lib files
    if ( CMAKE_SHARED_LIBS )
        set( lib_files
            webp.7
            webpdemux.2
            webpmux.3
        )
    else()
        set( lib_files
            webp
            webpdemux
            webpmux
        )
    endif()

    # pkgfiles
    set( pkg_files
        libwebp.pc
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output )

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/msvc-tool-data-imports.patch"
    )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DWEBP_BUILD_VWEBP=OFF
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

    set( build_output ${lib_output} ${bin_output} ${inc_output} ${pkg_output} ${cmake_output} )
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

if( WIN32 )
    build_add_dependencies( ${project_name} giflib jpeg libpng tiff )
endif()
