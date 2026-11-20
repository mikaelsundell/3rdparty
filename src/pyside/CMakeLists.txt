# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: pyside-setup-6.10.1
# Archive: pyside-setup-6.10.1.tar.gz
# Upstream copyright and license notices: licenses/third-party/pyside/

build_info( " Adding pyside project" )

# project configuration

# project name
set( project_name "pyside" )

# project pkg
set( project_pkg ${project_name}-setup-6.10.1 )

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
    set( bin_files shiboken6.exe )
    set( lib_files "pyside6${build_python3_extension}" "shiboken6${build_python3_extension}" )
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${shared_lib_prefix}" "${shared_lib_suffix}" lib_output )
    build_add_files( "PySide6Config.cmake" "${build_lib_dir}/cmake/PySide6" cmake_output )
    build_add_files( "Shiboken6Config.cmake" "${build_lib_dir}/cmake/Shiboken6" shiboken_output )
    build_add_files(
        "PySide6/QtCore${build_python3_extension}.pyd;PySide6/QtMultimedia${build_python3_extension}.pyd;shiboken6/Shiboken${build_python3_extension}.pyd"
        "${build_sitepackages_dir}" sitepackages_output
    )
else()
    # bin files
    set( bin_files
        shiboken6
    )

    # inc dir
    set( inc_dir
        PySide6
        shiboken6
    )

    # lib files
    set( lib_files
        pyside6
        shiboken6
    )

    include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )

    # inc dir
    build_add_dir(
        "${inc_dir}" "${build_dir}" include_output
    )

    # lib files
    set( lib_version "3.6.10" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/${lib_prefix}${lib_file}.abi${lib_version}${lib_suffix}
            )
        endif()
    endforeach()

    # site packages files
    foreach( lib_file ${pyside6_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/python${build_python3_version}/site-packages/PySide6/${lib_file}.abi3${sitepackage_suffix}
            )
        endif()
    endforeach()

    foreach( lib_file ${shiboken6_files} )

    if ( APPLE )
        list( APPEND lib_output
            ${build_lib_dir}/python${build_python3_version}/site-packages/shiboken6/${lib_file}.abi3${sitepackage_suffix}
        )
    endif()
    endforeach()
endif()

build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    set( build_prepare
        ${build_python_check}
        COMMAND ${CMAKE_COMMAND} "-Dqt_prefix=${build_dir}" "-Dqt_configuration=${CMAKE_BUILD_TYPE}"
            -P "${build_scripts_dir}/check_qt_prefix.cmake"
    )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/designer-python-api.patch"
        "${project_src_dir}/msvc/detect-debug-python.patch"
        "${project_src_dir}/msvc/load-sdk-dlls.patch"
        "${project_src_dir}/msvc/python39-callable-annotations.patch"
    )
    set( build_env "LLVM_INSTALL_DIR=${build_dir}" )
    set( build_runtime_path "${build_bin_dir}" "${build_python_root}" )
    # options
    set( build_options
        "${build_python_find_options}"
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DQt6_DIR=${build_lib_dir}/cmake/Qt6"
        "-DClang_DIR=${build_lib_dir}/cmake/clang"
        "-DPYTHON_SITE_PACKAGES=${build_sitepackages_dir}"
        "-DPYTHON_EXTENSION_SUFFIX=${build_python3_extension}"
        -DSHIBOKEN_BUILD_TOOLS=ON
        -DQFP_FIND_NEW_PYTHON_PACKAGE=OFF
        -DFORCE_LIMITED_API=OFF
        -DBUILD_TESTS=OFF
        -DDISABLE_DOCSTRINGS=ON
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

    set( build_output
        ${lib_output} ${bin_output} ${cmake_output} ${shiboken_output} ${sitepackages_output}
    )
else()
    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=true )
    else()
        set( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
        export LLVM_INSTALL_DIR=${build_dir} &&
        export PATH=${build_ninja_dir}:$PATH &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        test -f ${build_lib_dir}/cmake/Qt6/Qt6Config.cmake &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
            -DQt6_DIR=${build_lib_dir}/cmake/Qt6
            -DCMAKE_INSTALL_PREFIX=${build_dir}
            -DCMAKE_BUILD_RPATH=${build_lib_dir}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DPYTHON_EXECUTABLE=${build_python3}
            -DPYTHON_INCLUDE_DIR=${build_python3_include_dir}
            -DPYTHON_LIBRARY=${build_python3_library}
            -DCMAKE_CXX_FLAGS=-stdlib=libc++
            -DSHIBOKEN_GENERATOR_EXTRA_FLAGS=--compiler-path=${build_bin_dir}/clang++
            -DBUILD_TESTS=OFF
            -DNO_QT_TOOLS=yes
            ${build_options}
            -G Ninja &&
        cmake --build . --parallel &&
        ninja install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

    # scripts
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

# Reconfigure bindings when installed Qt modules are added or changed.
file( GLOB build_inputs CONFIGURE_DEPENDS
    "${build_lib_dir}/cmake/Qt6*/Qt6*Config.cmake"
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output} ${include_output}
)

# dependencies
build_add_dependencies( ${project_name} llvm ninja )
