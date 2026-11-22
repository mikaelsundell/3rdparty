# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: lcms2-master
# Archive: lcms2-master.tar.gz
# Upstream copyright and license notices: licenses/third-party/lcms2/

build_info( " Adding lcms2 project" )

# project configuration

# project name
set( project_name "lcms2" )

# project pkg
set( project_pkg ${project_name}-master )

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
set( inc_files lcms2.h lcms2_plugin.h )

# bin files
set( bin_files
    jpgicc
    linkicc
    psicc
    tificc
    transicc
)

# platform-specific outputs
if( WIN32 )
    set( lib_files lcms2 )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
else()
    # lib files
    set( lib_files
        lcms2.2
    )

    # pkgfiles
    set( pkg_files
        lcms2.pc
    )

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

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

build_add_dependencies( ${project_name} jpeg tiff )

if( UNIX )
    build_add_dependencies( ${project_name} zlib-ng )
endif()
