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

# bin files
set( bin_files
    shiboken6
)

# inc dir
SET( inc_dir
    PySide6
    shiboken6
)

# lib files
set( lib_files
    pyside6
    shiboken6
)

# site-packages
set( pyside6_files
    Qt3DAnimation
    Qt3DCore
    Qt3DExtras
    Qt3DInput
    Qt3DLogic
    Qt3DRender
    QtConcurrent
    QtCore
    QtDBus
    QtGui
    QtHelp
    QtHttpServer
    QtMultimedia
    QtMultimediaWidgets
    QtNetwork
    QtNetworkAuth
    QtOpenGL
    QtOpenGLWidgets
    QtPositioning
    QtPrintSupport
    QtScxml
    QtSerialPort
    QtSql
    QtStateMachine
    QtSvg
    QtSvgWidgets
    QtTest
    QtUiTools
    QtWebSockets
    QtWidgets
    QtXml
)

set( shiboken6_files
    Shiboken
)

if( UNIX )
    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

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

# build configuration

# unix

IF( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

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
        export PATH=${build_ninja_dir}:$$PATH &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir} 
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
    
    # Reconfigure/rebuild bindings when installed Qt modules are added or changed.
    file(GLOB qt_module_configs CONFIGURE_DEPENDS
        "${build_lib_dir}/cmake/Qt6*/Qt6*Config.cmake")

    # run
    add_custom_command(
        OUTPUT ${bin_output} ${lib_output}
        DEPENDS ${qt_module_configs}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
        COMMAND ${sitepackage_script}
    )

endif()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${include_output} ${lib_output} 
)

# dependencies
build_add_dependencies( ${project_name} llvm ninja )
