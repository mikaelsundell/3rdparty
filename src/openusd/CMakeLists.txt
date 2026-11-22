# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: OpenUSD-25.11
# Archive: OpenUSD-25.11.tar.gz
# Upstream copyright and license notices: licenses/third-party/openusd/

build_info( " Adding openusd project" )

# project configuration

# project name
set( project_name "openusd" )

# project pkg
set( project_pkg "OpenUSD-25.11" )

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
    set( lib_files usd_tf usd_sdf usd_usd usd_usdGeom usd_hd )
    set( import_files ${lib_files} )
    list( TRANSFORM import_files APPEND ".lib" )
    build_add_files( "${import_files}" "${build_lib_dir}" lib_output )
    if( CMAKE_SHARED_LIBS )
        list( TRANSFORM lib_files APPEND ".dll" )
        build_add_files( "${lib_files}" "${build_lib_dir}" runtime_output )
    endif()
    build_add_files( "usdcat.exe" "${build_dir}/bin" bin_output )
    build_add_files( "pxr/usd/usd/stage.h" "${build_inc_dir}" inc_output )
    build_add_files( "pxrConfig.cmake" "${build_dir}" cmake_output )
    build_add_files(
        "pxr/__init__.py;pxr/Tf/_tf${build_python3_postfix}.pyd;pxr/Usd/_usd${build_python3_postfix}.pyd"
        "${build_lib_dir}/python" sitepackages_output
    )
else()
    # bin files
    set( bin_files
        sdfdump
        sdffilter
        usdtree
        usdcat
    )

    # inc dir
    set( inc_dir
        pxr
    )

    include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir(
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

# build configuration

# patches
set( patch "${project_src_dir}/sdr-unused-include.patch" )
if( WIN32 )
    list( APPEND patch
        "${project_src_dir}/msvc/contain-python-copysign-macro.patch"
        "${project_src_dir}/msvc/sort-hydra-repr-selectors.patch"
    )
endif()
build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch ${patch} )

if( WIN32 )
    set( build_prepare
        ${build_python_check}
        COMMAND "${build_python3}" -B "${build_scripts_dir}/check_openusd_python.py"
            "${build_sitepackages_dir}"
    )
    set( build_runtime_path "${build_dir}/bin" "${build_lib_dir}" )
    set( build_python_path "${build_sitepackages_dir}" )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DPXR_ENABLE_PYTHON_SUPPORT=ON
        "-DPXR_USE_DEBUG_PYTHON=${build_python3_debugging}"
        "-DPYSIDEUICBINARY=${build_dir}/bin/uic.exe"
        -DPXR_ENABLE_MATERIALX_SUPPORT=ON
        -DPXR_BUILD_ALEMBIC_PLUGIN=ON
        -DPXR_BUILD_DRACO_PLUGIN=ON
        -DPXR_BUILD_TESTS=OFF
        -DPXR_BUILD_EXAMPLES=OFF
        -DPXR_BUILD_TUTORIALS=OFF
        ${build_python_options}
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
    # Python modules installed by the matching PySide prerequisite.
    set( build_env ${build_env} &&
        export PYTHONPATH=${build_lib_dir}/python${build_python3_version}/site-packages:$PYTHONPATH
    )

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=TRUE )
    else()
        set( build_options -DBUILD_SHARED_LIBS=FALSE )
    endif()

    # config
    set( build_config ${build_config} -DCMAKE_CXX_STANDARD=14 )
    set( build_config ${build_config} -DBoost_NO_BOOST_CMAKE=false )
    set( build_config ${build_config} -DPXR_BUILD_USDVIEW=true )
    set( build_config ${build_config} -DPXR_BUILD_TESTS=OFF )
    set( build_config ${build_config} -DPXR_ENABLE_PYTHON_SUPPORT=true )
    set( build_config ${build_config} -DPXR_ENABLE_MATERIALX_SUPPORT=true )
    set( build_config ${build_config} -DPYSIDEUICBINARY=${build_dir}/libexec/uic )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_config ${build_config} -DPXR_USE_DEBUG_PYTHON=ON )
    endif()

    list( APPEND build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DPYTHON_EXECUTABLE=${build_python3}"
        "-DPYTHON_INCLUDE_DIR=${build_python3_include_dir}"
        "-DPYTHON_LIBRARY=${build_python3_library}"
        ${build_config}
    )

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

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} alembic draco materialx onetbb opensubdiv ptex pyside )

if( UNIX )
    build_add_dependencies( ${project_name} pybind )
endif()
