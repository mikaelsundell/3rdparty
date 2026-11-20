# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: boost_1_87_0
# Archive: boost_1_87_0.tar.gz
# Upstream copyright and license notices: licenses/third-party/boost/

build_info( " Adding boost project" )

# project configuration

# project name
set( project_name "boost" )

# project pkg
set( project_pkg ${project_name}_1_87_0 )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

# project config
set( project_cfg_without_mpi TRUE )

# project src dir
set( project_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# project bin dir
set( project_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

include( "${CMAKE_CURRENT_LIST_DIR}/outputs.cmake" )

# platform-specific outputs
if( WIN32 )
    string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
    set( lib_tag "-mt-x64" )
    set( zlib_name zlib )
    if( NOT CMAKE_SHARED_LIBS )
        set( zlib_name zlibstatic )
    endif()
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_tag "-mt-gyd-x64" )
        string( APPEND zlib_name "d" )
    endif()

    list( TRANSFORM lib_files APPEND "${lib_tag}" )
    if( CMAKE_SHARED_LIBS )
        set( runtime_files ${lib_files} )
        list( TRANSFORM runtime_files APPEND "${CMAKE_SHARED_LIBRARY_SUFFIX}" )
        # Boost installs DLLs beside its import libraries and refers to them there in BoostConfig.
        build_add_files( "${runtime_files}" "${build_lib_dir}" bin_output )
    else()
        list( TRANSFORM lib_files PREPEND "lib" )
    endif()
    list( APPEND lib_files "libboost_test_exec_monitor${lib_tag}" )
    list( TRANSFORM lib_files APPEND "${CMAKE_STATIC_LIBRARY_SUFFIX}" )
    build_add_files( "${lib_files}" "${build_lib_dir}" lib_output )
    build_add_files( "boost/version.hpp" "${build_inc_dir}" inc_output )
    build_add_files(
        "BoostConfig.cmake;BoostConfigVersion.cmake"
        "${build_lib_dir}/cmake/Boost-1.87.0" cmake_output
    )

    set( build_link static )
    if( CMAKE_SHARED_LIBS )
        set( build_link shared )
    endif()
else()

    # lib files
    set( lib_mttag "-mt" )

    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "-d" )
    endif()

    if (lib_arch STREQUAL "x86_64" )
        set( lib_atag "x64" )
    elseif (lib_arch STREQUAL "arm64" )
        set( lib_atag "a64" )
    else()
        set( lib_atag ${lib_arch} )
    endif()

    set( lib_version "1.87.0" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            # boost_exception and boost_test_exec_monitor are static, see below
            if( NOT ${lib_file} STREQUAL "boost_exception" AND
                NOT ${lib_file} STREQUAL "boost_test_exec_monitor" )

                list( APPEND lib_output
                    ${build_lib_dir}/${lib_prefix}${lib_file}${lib_mttag}${lib_dtag}-${lib_atag}${lib_suffix}
                )
            endif()

        else()

            # INFO: on UNIX lib files appends version after suffix
            if( NOT ${lib_file} STREQUAL "boost_thread" )
                STRING( REGEX REPLACE
                    "^([^.]+)([.]*)(.*)"
                    "${lib_prefix}\\1${lib_dtag}${lib_suffix}.${lib_version}\\2\\3"
                    st_file "${lib_file}"
                )

                list( APPEND lib_output
                    ${build_lib_dir}/${st_file}
                )
            endif()

            string( REGEX REPLACE
                "^([^.]+)([.]*)(.*)"
                "${lib_prefix}\\1${lib_mttag}${lib_dtag}${lib_suffix}.${lib_version}\\2\\3"
                mt_file "${lib_file}"
            )

            list( APPEND lib_output
                ${build_lib_dir}/${mt_file}
            )

        endif()

    endforeach()
endif()

# build configuration

if( WIN32 )
    string( REGEX MATCH "^[0-9]+[.][0-9]" build_msvc_version "$ENV{VCToolsVersion}" )
    file( TO_CMAKE_PATH "$ENV{VCINSTALLDIR}" build_vc_dir )
    set( build_vcvars "${build_vc_dir}/Auxiliary/Build/vcvarsall.bat" )
    configure_file( "${project_src_dir}/msvc-config.jam.in" "${project_bin_dir}/msvc-config.jam" @ONLY )

    # options
    set( build_options
        "--prefix=${build_dir}" --layout=tagged --without-mpi -j${num_cpus}
        "toolset=msvc-${build_msvc_version}" address-model=64 threading=multi
        "variant=${build_variant}" "link=${build_link}" "python-debugging=${build_python3_debugging}"
        "-sBZIP2_INCLUDE=${build_inc_dir}" "-sBZIP2_LIBRARY_PATH=${build_lib_dir}" -sBZIP2_NAME=bz2
        "-sZLIB_INCLUDE=${build_inc_dir}" "-sZLIB_LIBRARY_PATH=${build_lib_dir}" "-sZLIB_NAME=${zlib_name}"
    )
    set( build_prepare ${build_python_check} )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/cmake-debug-python-definition.patch"
    )
    set( build_make
        COMMAND ${CMAKE_COMMAND} -E chdir "${project_bin_dir}/${project_pkg}" cmd.exe /d /c call bootstrap.bat msvc
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${project_bin_dir}/msvc-config.jam"
            "${project_bin_dir}/${project_pkg}/project-config.jam"
        COMMAND ${CMAKE_COMMAND} -E chdir "${project_bin_dir}/${project_pkg}" b2.exe install ${build_options}
    )

    set( build_output ${lib_output} ${bin_output} ${inc_output} ${cmake_output} )
else()
    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options variant=debug )
    else()
        set( build_options variant=release )
    endif()

    if( CMAKE_SHARED_LIBS )
        set( build_options ${build_options} link=shared )
    else()
        set( build_options ${build_options} link=static )
    endif()

    # config
    if( project_cfg_without_mpi )
        set( build_config --without-mpi )
    endif()

    # userconfig
    set( userconfig
        ${build_scripts_dir}/install_userconfig.sh
        --python3 ${build_python3}
        --version ${build_python3_version}
        --include-dir ${build_python3_include_dir}
        --library-dir ${build_python3_library_dir}
        ./tools/build/src/user-config.jam
    )

    # bootstrap, b2 install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        ${userconfig} &&
        ./bootstrap.sh &&
        ./b2 install
            --prefix=${build_dir}
            --build-type=complete
            --layout=tagged
            --debug-configuration
            ${build_config}
            ${build_options}
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

    # scripts
    if ( APPLE )
        # build output
        set( build_output ${bin_output} )

        if ( CMAKE_SHARED_LIBS )
            set( build_output ${build_output} ${lib_output} )

            # remove static boost_exception
            list( REMOVE_ITEM build_output
                ${build_lib_dir}/${lib_prefix}boost_exception${static_lib_suffix}
            )
        endif()

        set( build_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    endif()

    build_install_check(
        "${build_output}"
        build_check
    )

    set( build_output ${lib_output} )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

# dependencies
build_add_dependencies( ${project_name} bzip2 zlib-ng )
