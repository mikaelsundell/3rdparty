# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: OpenColorIO-2.5.0
# Archive: OpenColorIO-2.5.0.tar.gz
# Upstream copyright and license notices: licenses/third-party/ocio/

build_info( " Adding ocio project" )

# project configuration

# project name
set( project_name "ocio" )

# lib pkg
set( project_pkg "OpenColorIO-2.5.0" )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

# project config
set( project_cfg_cmake_prefix TRUE )

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
    set( lib_files "OpenColorIO${build_python3_postfix}.lib" )
    build_add_files( "${lib_files}" "${build_lib_dir}" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "OpenColorIO${build_python3_postfix}_2_5.dll" "${build_bin_dir}" runtime_output )
    endif()
    build_add_files( "OpenColorIO/OpenColorIO.h" "${build_inc_dir}" inc_output )
    build_add_files( "OpenColorIOConfig.cmake" "${build_lib_dir}/cmake/OpenColorIO" cmake_output )
    build_add_files( "PyOpenColorIO${build_python3_postfix}.pyd;__init__.py" "${build_sitepackages_dir}/PyOpenColorIO" sitepackages_output )
else()
    # bin files
    set( bin_files
        ociobakelut
        ocioarchive
        ociocheck
        ociocpuinfo
        ociodisplay
        ociowrite
        ociomakeclf
        ociochecklut
        ocioconvert
        ociomergeconfigs
        ocioperf
        ociolutimage
    )

    # lib files
    set( lib_files
        OpenColorIO.2.5.0
    )

    # site-packages
    set( sitepackages_files
        PyOpenColorIO
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )

    # site packages files
    foreach( lib_file ${sitepackages_files} )
        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/python${build_python3_version}/site-packages/PyOpenColorIO/PyOpenColorIO${sitepackage_suffix}
            )
        endif()
    endforeach()
endif()

# build configuration

set( build_config
    -DOCIO_BUILD_TESTS=OFF
    -DOCIO_BUILD_GPU_TESTS=OFF
    -DOCIO_USE_OIIO_FOR_APPS=OFF
)

if( WIN32 )
    set( build_prepare ${build_python_check} )
    # patches
    set( patch "${project_src_dir}/msvc/python-debug-postfix.patch" )
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch "${patch}" )
    set( build_runtime_path "${build_dir}/bin" "${build_lib_dir}" )
    # options
    set( build_options
        ${build_config}
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DOCIO_LIBNAME_SUFFIX=${build_python3_postfix}"
        -DOCIO_PYTHON_INSTALL_DIR=site-packages
        -DOCIO_BUILD_PYTHON=ON
        -DOCIO_BUILD_DOCS=OFF
        -DOCIO_INSTALL_EXT_PACKAGES=MISSING
        -DPYBIND11_FINDPYTHON=ON
        ${build_python_options}
        ${build_python_find_options}
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

    set( build_output ${lib_output} ${runtime_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
    # options
    set( build_options -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} )
    set( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=true )
    if( APPLE )
        list( APPEND build_options -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} )
    endif()

    if( project_cfg_cmake_prefix )
        set( build_make
            ${build_make}
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    endif()

    # make and install
    if( project_cfg_cmake_prefix )
        set( build_make
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    endif()

    set( build_make
        ${build_make}
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        export OIIO_PATH=${build_dir} &&
        cmake ../ -G \"${CMAKE_GENERATOR}\" -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir}
              -DPYTHON_SITE_DIR=${build_sitepackages_dir}
              ${build_options}
              ${build_config} &&
        cmake --build . --parallel ${num_cpus} -- -l ${num_cpus} &&
        cmake --install .
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

build_add_dependencies( ${project_name} lcms2 openexr )

if( WIN32 )
    build_add_dependencies( ${project_name} minizip-ng zlib-ng )
endif()
