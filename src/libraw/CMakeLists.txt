# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: libraw-0.21.1
# Archive: libraw-0.21.1.tar.gz
# Upstream copyright and license notices: licenses/third-party/libraw/

build_info( " Adding libraw project" )

# project configuration

# project name
set( project_name "libraw" )

# project pkg
set( project_pkg ${project_name}-0.21.1 )

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
    4channels
    dcraw_emu
    dcraw_half
    half_mt
    mem_image
    multirender_test
    postprocessing_benchmark
    raw-identify
    rawtextdump
    simple_dcraw
    unprocessed_raw
)

# platform-specific outputs
if( WIN32 )
    set( lib_files raw )
    set( inc_files libraw/libraw.h libraw/libraw_version.h )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
else()
    # lib files
    set( lib_files
        raw.23
        raw_r.23
    )

    # pkgfiles
    set( pkg_files
        libraw.pc
        libraw_r.pc
    )

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # patches
    set( build_patch
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${project_src_dir}/msvc/CMakeLists.txt" "${project_bin_dir}/${project_pkg}/CMakeLists.txt"
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
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$PATH &&
        export PKG_CONFIG_PATH=${build_pkgconfig_dir}:$PKG_CONFIG_PATH &&
        cd ${project_pkg} &&
        ./configure
            --prefix=${build_dir}
            CFLAGS=-I${build_inc_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            --enable-jpeg
            --enable-jasper
            --enable-lcms
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

    # scripts

    IF ( APPLE )

        # build output

        set( build_output ${bin_output} )

        IF ( CMAKE_SHARED_LIBS )
            set( build_output ${build_output} ${lib_output} )
        endif()

        set( build_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    endif()

    # run
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
build_add_dependencies( ${project_name} jpeg jasper lcms2 )
