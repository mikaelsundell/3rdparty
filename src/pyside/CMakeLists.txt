##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  pyside2 CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# Qt Copyright
# Copyright (C) 2020 The Qt Company Ltd.

# pyside from github 2022-03-24
# https://github.com/pyside/pyside-setup

build_info( " Adding pyside project" )

# project configuration

# project name
set( project_name "pyside" )

# project pkg
set( project_pkg ${project_name}-setup-opensource-src-5.15.2.1 )

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
    pyside2-lupdate
    shiboken2
)

# inc dir
SET( inc_dir
    PySide2
    shiboken2
)

# lib files
set( lib_files
    pyside2
    shiboken2
)

# site-packages
set( pyside2_files
    Qt3DAnimation
    Qt3DCore
    Qt3DExtras
    Qt3DInput
    Qt3DLogic
    Qt3DRender
    QtConcurrent
    QtCore
    QtDataVisualization
    QtGui
    QtHelp
    QtMacExtras
    QtMultimedia
    QtMultimediaWidgets
    QtNetwork
    QtOpenGL
    QtOpenGLFunctions
    QtPrintSupport
    QtQml
    QtQuick
    QtQuickControls2
    QtQuickWidgets
    QtRemoteObjects
    QtScript
    QtScriptTools
    QtScxml
    QtSerialPort
    QtSql
    QtSvg
    QtTest
    QtUiTools
    QtWidgets
    QtXml
    QtXmlPatterns
)

set( shiboken_files
    shiboken2
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" include_output
    )

    # lib files
    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}.cpython-${build_python3_versiontag}-darwin.5.15.2.1${lib_suffix}
            )
        endif()    
    endforeach()

    # site packages files
    foreach( lib_file ${pyside2_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/python${build_python3_version}/site-packages/PySide2/${lib_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
            )

        endif()    
    endforeach()

    foreach( lib_file ${shiboken_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_lib_dir}/python${build_python3_version}/site-packages/shiboken2/${lib_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
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
        cd pyside-setup-opensource-src-5.15.2 &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir} 
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=1
            -DPYTHON_EXECUTABLE=${build_python3}
            -DPYTHON_INCLUDE_DIR=${build_python3_include_dir}
            -DPYTHON_LIBRARY=${build_python3_library_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_add_script( 
        "${build_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        build_script
    )

    build_add_check( 
        "${build_output}" 
        build_check
    )

    # site-package

    set( sitepackage_output ${pyside2_output} ${shiboken2_output} )

    build_add_sitepackage( 
        "${sitepackage_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        sitepackage_script
    )

    # run
    add_custom_command( 
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
        COMMAND ${sitepackage_script}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${include_output} ${lib_output} 
)

# dependencies
add_dependencies( ${project_name} llvm )
