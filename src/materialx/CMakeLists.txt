# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: MaterialX-1.39.4
# Archive: MaterialX-1.39.4.tar.gz
# Upstream copyright and license notices: licenses/third-party/materialx/

build_info( " Adding materialx project" )

# project configuration

# project name
set( project_name "materialx" )

# project pkg
set( project_pkg "MaterialX-1.39.4" )

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
    set( lib_files MaterialXCore MaterialXFormat MaterialXGenShader MaterialXGenGlsl MaterialXRender )
    list( TRANSFORM lib_files APPEND "${build_python3_postfix}" )
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    build_add_files( "MaterialXCore/Document.h" "${build_inc_dir}" inc_output )
    build_add_files( "MaterialXConfig.cmake" "${build_lib_dir}/cmake/MaterialX" cmake_output )
    build_add_files( "PyMaterialXCore${build_python3_extension}.pyd;__init__.py" "${build_dir}/python/MaterialX" sitepackages_output )
else()
    # bin files
    set( bin_files
        MaterialXView
    )

    include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    set( lib_version "1.39.4" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
            )
        endif()
    endforeach()

    # site packages files
    foreach( sitepackages_file ${sitepackages_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_sitepackages_dir}/MaterialX/Py${sitepackages_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
            )
        endif()
    endforeach()
endif()

# build configuration

if( WIN32 )
    set( build_prepare ${build_python_check} )
    set( build_runtime_path "${build_dir}/bin" "${build_lib_dir}" )
    # options
    set( build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DCMAKE_DEBUG_POSTFIX=${build_python3_postfix}"
        -DMATERIALX_BUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DMATERIALX_BUILD_TESTS=OFF
        -DMATERIALX_BUILD_VIEWER=OFF
        -DMATERIALX_BUILD_PYTHON=ON
        -DMATERIALX_PYTHON_LTO=OFF
        "-DMATERIALX_PYTHON_EXECUTABLE=${build_python3}"
        "-DMATERIALX_PYTHON_VERSION=${build_python3_version}"
        -DPYBIND11_FINDPYTHON=ON
        ${build_python_options}
        ${build_python_find_options}
    )

    set( build_output ${lib_output} ${runtime_output} ${inc_output} ${cmake_output} ${sitepackages_output} )

    build_add_dependencies( ${project_name} pybind )
else()
    # config
    set( build_config ${build_config} -DMATERIALX_BUILD_VIEWER=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_SHARED_LIBS=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_OIIO=true )
    set( build_config ${build_config} -DMATERIALX_BUILD_PYTHON=true )
    set( build_config ${build_config} -DMATERIALX_INSTALL_PYTHON=false )
    set( build_config ${build_config} -DMATERIALX_NANOGUI_EXTERNAL=true )
    set( build_config ${build_config} -DNANOGUI_ROOT=${build_dir} )
    set( build_config ${build_config} -DNANOGUI_EXTRA_DEFS="-DNANOGUI_USE_METAL=1" )
    set( build_config ${build_config} -DCMAKE_CXX_FLAGS="-I${build_inc_dir}/eigen3" )

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
        "-DMATERIALX_PYTHON_FOLDER_NAME=${build_sitepackages_dir}/MaterialX"
        -DMATERIALX_BUILD_PYTHON=ON
        "-DPYTHON_EXECUTABLE=${build_python3}"
        "-DPYTHON_INCLUDE_DIR=${build_python3_include_dir}"
        "-DPYTHON_LIBRARY=${build_python3_library}"
        ${build_options}
        ${build_config}
    )

    build_add_dependencies( ${project_name} nanogui oiio )
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
