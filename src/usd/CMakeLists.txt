##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# usd Copyright
# Copyright 2022 Pixar

# imath from github.com 22.03 2022-03-19
# https://github.com/PixarAnimationStudios/USD/

build_info( " Adding usd project" )

# project configuration

# project name
set( project_name "usd" )

# project pkg
set( project_pkg ${project_name}-22.03 )

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
    sdfdump
    sdffilter
)

# inc dir
set( inc_dir
    pxr
)

# lib files
set( lib_files
    usd_ar
    usd_arch
    usd_cameraUtil
    usd_garch
    usd_gf
    usd_glf
    usd_hd
    usd_hdSt
    usd_hdx
    usd_hf
    usd_hgi
    usd_hgiGL
    usd_hgiInterop
    usd_hgiMetal
    usd_hio
    usd_js
    usd_kind
    usd_ndr
    usd_pcp
    usd_plug
    usd_pxOsd
    usd_sdf
    usd_sdr
    usd_tf
    usd_trace
    usd_usd
    usd_usdAppUtils
    usd_usdGeom
    usd_usdHydra
    usd_usdImaging
    usd_usdImagingGL
    usd_usdLux
    usd_usdMedia
    usd_usdPhysics
    usd_usdRender
    usd_usdRi
    usd_usdRiImaging
    usd_usdShade
    usd_usdSkel
    usd_usdSkelImaging
    usd_usdUI
    usd_usdUtils
    usd_usdVol
    usd_usdVolImaging
    usd_vt
    usd_work
)

# pkgfiles
set( pkg_files
)

IF( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" include_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
    
endif()

# build configuration

# unix

IF( UNIX )

    # download
    SET( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    SET( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    set( build_options ${build_options} -DBoost_NO_BOOST_CMAKE=false )
    set( build_options ${build_options} -DPXR_BUILD_USDVIEW=false )
    set( build_options ${build_options} -DPXR_ENABLE_PYTHON_SUPPORT=false )

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir}
              -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
              ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    set( build_output ${bin_output} )

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

    # run
    add_custom_command( 
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )     

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${include_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} alembic draco materialx onetbb opensubdiv ptex pybind pyside pyside2-tools )
