# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: oneTBB-2022.3.0
# Archive: oneTBB-2022.3.0.tar.gz
# Upstream copyright and license notices: licenses/third-party/onetbb/

build_info( " Adding onetbb project" )

# project configuration

# project name
set( project_name "onetbb" )

# project pkg
set( project_pkg oneTBB-2022.3.0 )

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
    set( lib_files tbb12 tbbmalloc tbbmalloc_proxy )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "_debug" )
    endif()
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    set( inc_files oneapi/tbb.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files TBBConfig.cmake TBBConfigVersion.cmake TBBTargets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/TBB" cmake_output )
else()
    # lib files
    set( lib_files
        tbb
        tbbmalloc
        tbbmalloc_proxy
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_debug" )
    endif()

    set( default_version "12.17" )
    set( tbb_version "2.17" )

    foreach( lib_file ${lib_files} )
        if( lib_file MATCHES "malloc|proxy" )
            set( lib_version "${tbb_version}" )
        else()
            set( lib_version "${default_version}" )
        endif()

        list( APPEND lib_output
            ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.${lib_version}${lib_suffix}
        )
    endforeach()
endif()

# build configuration

if( WIN32 )
    # options
    set( build_options
        -DTBB_TEST=OFF
        -DTBB_STRICT=OFF
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} )
else()
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

    set( build_output ${bin_output} ${lib_output} )

    set( build_options ${build_config} )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
