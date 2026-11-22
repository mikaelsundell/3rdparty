# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: jpeg
# Archive: jpegsrc.v9f.tar.gz
# Upstream copyright and license notices: licenses/third-party/jpeg/

build_info( " Adding jpeg project" )

# project configuration

# project name
set( project_name "jpeg" )

# project pkg
set( project_pkg ${project_name} )

# project archive
set( project_arc ${project_pkg}src.v9f.tar.gz )

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
    jconfig.h
    jerror.h
    jmorecfg.h
    jpeglib.h
)

# bin files
set( bin_files
    cjpeg
    djpeg
    jpegtran
    rdjpgcom
    wrjpgcom
)

# platform-specific outputs
if( WIN32 )
    set( lib_files jpeg )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
else()
    # lib files
    set( lib_files
        jpeg.9
    )
    # 9.3.0 is not built on apple
    if( LINUX )
        set( ${lib_files}
             jpeg.9.3.0
        )
    endif()
endif()

build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # patches
    set( build_patch
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${project_src_dir}/msvc/CMakeLists.txt"
            "${project_bin_dir}/${project_pkg}-9f/CMakeLists.txt"
    )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}-9f" build_make ${build_options} )

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
    	cd ${project_pkg}-9f &&
        ./configure
            --prefix=${build_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

    # scripts
    set( build_output ${bin_output} )

    IF ( CMAKE_SHARED_LIBS )
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

    set( build_output ${bin_output} ${inc_output} ${lib_output} )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
