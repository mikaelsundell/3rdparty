# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: opentimelineio-master-250205 (0.19.0.dev1, fork based on bad7ab5)
# Archive: opentimelineio-master-250205.tar.gz
# Upstream copyright and license notices: licenses/third-party/opentimelineio/

build_info( " Adding opentimelineio project" )

# project configuration

# project name
set( project_name "opentimelineio" )

# project pkg
set( project_pkg "opentimelineio-master-250205" )

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
    set( package_dir "${build_sitepackages_dir}/opentimelineio" )
    build_add_files( "opentime.lib;opentimelineio.lib" "${package_dir}" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "opentime.dll;opentimelineio.dll" "${package_dir}" runtime_output )
    endif()
    build_add_files( "opentime/rationalTime.h;opentimelineio/timeline.h" "${build_inc_dir}" inc_output )
    build_add_files(
        "cmake/opentime/OpenTimeConfig.cmake;cmake/opentimelineio/OpenTimelineIOConfig.cmake"
        "${build_lib_dir}" cmake_output
    )
    build_add_files(
        "_opentime${build_python3_extension}.pyd;_otio${build_python3_extension}.pyd;__init__.py"
        "${package_dir}" sitepackages_output
    )
else()
    # inc dir
    set( inc_dir
        opentime
        opentimelineio
    )

    # lib files
    set( lib_files
        opentime
        opentimelineio
    )

    # site-packages
    set( sitepackages_files
        _opentime
        _otio
    )

    # inc files
    set( inc_files
        opentime/rationalTime.h
        opentimelineio/timeline.h
    )

    # pkg files
    set( pkg_files
        cmake/opentime/OpenTimeConfig.cmake
        cmake/opentimelineio/OpenTimelineIOConfig.cmake
    )

    # inc dir
    build_add_dir(
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    build_add_files(
        "${inc_files}" "${build_inc_dir}" inc_output
    )

    build_add_files(
        "${pkg_files}" "${build_lib_dir}" pkg_output
    )

    # lib files
    set( lib_version "0.19.0" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            if( CMAKE_SHARED_LIBS )
                list( APPEND lib_output
                    ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
                )
            else()
                list( APPEND lib_output
                    ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
                )
            endif()
        endif()
    endforeach()

    # site packages files
    foreach( lib_file ${sitepackages_files} )
        if ( APPLE )
            list( APPEND lib_output
                ${build_sitepackages_dir}/opentimelineio/${lib_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
            )
        endif()
    endforeach()
endif()

# build configuration

# options shared by the Windows and Unix build passes
set( build_config
    -DOTIO_FIND_IMATH=ON
    -DOTIO_FIND_PYBIND11=ON
    -DOTIO_FIND_RAPIDJSON=ON
    -DOTIO_FIND_MINIZIP_NG=ON
    -DOTIO_AUTOMATIC_SUBMODULES=OFF
    -DOTIO_DEPENDENCIES_INSTALL=OFF
    -DOTIO_PYTHON_INSTALL=ON
    -DBUILD_TESTING=OFF
)

if( WIN32 )
    set( build_prepare ${build_python_check} )
    set( build_runtime_path "${build_dir}/bin" "${build_lib_dir}" )
    set( build_options
        ${build_config}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DOTIO_SHARED_LIBS=${CMAKE_SHARED_LIBS}

        -DOTIO_CXX_INSTALL=ON
        -DOTIO_DEBUG_POSTFIX=
        "-DOTIO_PYTHON_INSTALL_DIR=${build_sitepackages_dir}"
        -DPYBIND11_FINDPYTHON=ON
        ${build_python_find_options}
        ${build_python_options}
    )
    build_cmake_commands( "${project_bin_dir}/OpenTimelineIO-system-dependencies-261115" build_make ${build_options} )

    set( build_output ${lib_output} ${runtime_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DOTIO_SHARED_LIBS=true )
    else()
        set( build_options -DOTIO_SHARED_LIBS=false )
    endif()

    # config
    list( APPEND build_config

        -DOTIO_CXX_INSTALL=OFF

        -DOTIO_PYTHON_INSTALL_DIR=${build_sitepackages_dir}
        -DPython_EXECUTABLE=${build_python3}

    )

    # configure, make and install
    # The AWS archive retains this source directory name.
    set( build_make
        ${build_env} &&
        cd OpenTimelineIO-system-dependencies-261115 &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
            -DCMAKE_INSTALL_PREFIX=${build_dir}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_OSX_ARCHITECTURES=${lib_arch}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
            ${build_options}
            ${build_config} &&
        make ${build_flags} &&
        make install &&
        cd .. &&
        ${build_python3} setup.py build_py --build-lib ${build_sitepackages_dir} &&
        cd ${build_cmake} &&
        cmake ../ -DOTIO_PYTHON_INSTALL=OFF -DOTIO_CXX_INSTALL=ON &&
        make ${build_flags} &&
        make install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

    # scripts
    set( build_output
        ${inc_output}
        ${lib_output}
        ${pkg_output}
        ${build_sitepackages_dir}/opentimelineio/__init__.py
    )

    build_install_script(
        "${lib_output}"
        ${build_dir}
        ${build_prefix_lib}
        ${build_prefix_framework}
        build_script
    )

    build_install_check(
        "${build_output}"
        build_check
    )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

# dependencies
build_add_dependencies( ${project_name} imath pybind rapidjson minizip-ng )
