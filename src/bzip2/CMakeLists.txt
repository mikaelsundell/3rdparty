# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: bzip2-1.0.6
# Archive: bzip2-1.0.6.tar.gz
# Upstream copyright and license notices: licenses/third-party/bzip2/

build_info( " Adding bzip2 project" )

# project configuration

# project name
set( project_name "bzip2" )

# project pkg
set( project_pkg ${project_name}-1.0.6 )

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
set( inc_files bzlib.h )

# platform-specific outputs
if( WIN32 )
    set( lib_files bz2 )
    set( bin_files
        bzip2 bzip2recover
    )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    if( CMAKE_SHARED_LIBS )
        list( APPEND bin_files "libbz2${CMAKE_SHARED_LIBRARY_SUFFIX}" )
        build_add_files( "bz2${CMAKE_IMPORT_LIBRARY_SUFFIX}" "${build_lib_dir}" lib_output )
    else()
        build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    endif()
else()
    # bin files
    set( bin_files
        bzcat
        bzdiff
        bzgrep
        bzip2
        bzip2recover
        bzmore
    )

    # include files

    # lib files
    set( lib_files
        bz2.1.0.6
        bz2.1.0
        bz2
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # patches
    set( build_patch
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
    # patch - change from static to shared libs
    if( CMAKE_SHARED_LIBS )
        if( APPLE )
            set( build_patch
                COMMAND ${copy} ${project_src_dir}/Makefile.apple ${project_bin_dir}/${project_pkg}/Makefile
            )
        else()
            set( build_patch
                COMMAND ${copy} ${project_src_dir}/Makefile.linux ${project_bin_dir}/${project_pkg}/Makefile
            )
        endif()
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
    	cd ${project_pkg} &&
        make PREFIX=${build_dir} install
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

    set( build_output ${inc_output} ${lib_output} )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

