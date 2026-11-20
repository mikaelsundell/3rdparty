# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: openexr-3.4.6
# Archive: openexr-3.4.6.tar.gz
# Upstream copyright and license notices: licenses/third-party/openexr/

build_info( " Adding openexr project" )

# project configuration

# project name
set( project_name "openexr" )

# project pkg
set( project_pkg ${project_name}-3.4.6 )

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
    set( lib_files OpenEXR-3_4 OpenEXRCore-3_4 OpenEXRUtil-3_4 Iex-3_4 IlmThread-3_4 )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "_d" )
    endif()
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    set( bin_files exrheader exrinfo )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    set( inc_files OpenEXR/ImfHeader.h OpenEXR/OpenEXRConfig.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files OpenEXRConfig.cmake OpenEXRConfigVersion.cmake OpenEXRTargets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/OpenEXR" cmake_output )
    build_add_files(
        "OpenEXR${build_python3_postfix}.pyd;Imath.py"
        "${build_dir}/python/OpenEXR" sitepackages_output
    )
else()
    # bin files
    set( bin_files
        exr2aces
        exrenvmap
        exrheader
        exrinfo
        exrmakepreview
        exrmaketiled
        exrmultipart
        exrmultiview
    )

    # lib files
    set( lib_files
        Iex-3_4
        IlmThread-3_4
        OpenEXR-3_4
        OpenEXRCore-3_4
        OpenEXRUtil-3_4
    )

    # pkgfiles
    set( pkg_files
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_d" )
    endif()

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.33.3.4.6${lib_suffix}
            )

        else()
            # INFO: on UNIX lib files appends version after suffix
            string( REGEX REPLACE
                "^([^.]+)([.]*)(.*)"
                "${lib_prefix}\\1${lib_suffix}\\2\\3"
                lib_file "${lib_file}"
            )

            list( APPEND lib_output
                ${build_lib_dir}/${lib_file}
            )
        endif()

    endforeach()

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

build_add_files( "${bin_files}" "${build_dir}/bin" bin_output )

# build configuration

if( WIN32 )
    set( build_prepare ${build_python_check} )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/python-debug-postfix.patch"
        "${project_src_dir}/msvc/export-keycode-comparison.patch"
    )
    # options
    set( build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DOPENEXR_BUILD_PYTHON=ON
        -DBUILD_TESTING=OFF
        -DOPENEXR_INSTALL_DOCS=OFF
        "-DImath_DIR=${build_lib_dir}/cmake/Imath"
        ${build_python_options}
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )

    build_add_dependencies( ${project_name} imath pybind )
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

    set( build_options
        "-DZLIB_ROOT=${build_dir}"
        -DOPENEXR_BUILD_PYTHON_LIBS=TRUE
        ${build_options}
    )

    build_add_dependencies( ${project_name} imath boost zlib-ng )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
