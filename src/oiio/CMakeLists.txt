# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# OIIO Copyright
# Copyright 2008 Larry Gritz and the other authors and contributors.
# All Rights Reserved.

# oiio from github.com master 2025-02-08
# https://github.com/AcademySoftwareFoundation/OpenImageIO/releases

build_info( " Adding oiio project" )

# project configuration

# project name
set( project_name "oiio" )

# project pkg
set( project_pkg "OpenImageIO-3.0.3.1" )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_pkg}.tar.gz )

# project config
set( project_cfg_verbose TRUE )

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
    idiff
    igrep
    iinfo
    iv
    maketx
    oiiotool
)

# inc dir
SET( inc_dir
    OpenImageIO
)

# lib files
set( lib_files
    OpenImageIO
    OpenImageIO_Util
)

# site-packages
set( sitepackages_files
    OpenImageIO
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_d" )
    endif()

    set( lib_version "3.0.3" )

    foreach( lib_file ${lib_files} )
        list( APPEND lib_output 
            ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.${lib_version}${lib_suffix}
        )
    endforeach()

    # site packages files
    foreach( lib_file ${sitepackages_files} )
        if ( APPLE )
            list( APPEND lib_output 
                ${build_sitepackages_dir}/OpenImageIO/${lib_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
            )
        endif()    
    endforeach()

endif()

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options debug )
    endif()

    # cmake flags

    # Boost - use non cmake
    set( build_cmakeflags ${build_cmakeflags} -DBoost_NO_BOOST_CMAKE:BOOL=OFF )

    # python site dir
    set( build_cmakeflags ${build_cmakeflags} -DPYTHON_SITE_DIR=${build_sitepackages_dir}/OpenImageIO )

    # cmake prefix path
    set( build_cmakeflags ${build_cmakeflags} -DCMAKE_PREFIX_PATH=${build_dir} )

    # dependencies
    # JPEGTurbo = Not used
    # OpenColorIO = Not used
    # Rebuild after oiio build as OpenColorIO requires oiio
    # OpenCV = Not used
    # LibHeif = Not used
    # OpenVDB = Not used
    # PTex = Not used
    # R3DSDK = Not used
    # Nuke = Not used
    # Qt = Not used
    # Libsquish = Not used

    set( build_config ${build_config} Boost_ROOT=${build_dir} )
    set( build_config ${build_config} FFmpeg_ROOT=${build_dir} )
    set( build_config ${build_config} JPEG_ROOT=${build_dir} )
    set( build_config ${build_config} OpenEXR_ROOT=${build_dir} )
    set( build_config ${build_config} OpenJpeg_ROOT=${build_dir} )
    set( build_config ${build_config} PNG_ROOT=${build_dir} )
    set( build_config ${build_config} PTex_ROOT=${build_dir} )
    set( build_config ${build_config} TIFF_ROOT=${build_dir} )
    set( build_config ${build_config} Qt5_ROOT=${build_dir} )

    # TBB - Use internal
    set( build_config ${build_config} USE_TBB=0 )

    # make and install
    set( build_make
    	cd ${project_pkg} &&
    )

    # enable in build Qt support using cmake
    set( build_make
        ${build_make}
        export CMAKE_PREFIX_PATH=${build_dir}:${build_cmake_dir} &&
    )
    
    set( build_make
        ${build_make}
        export PATH=${build_bin_dir}:$$PATH &&
        export PKG_CONFIG_PATH=${build_pkgconfig_dir}:$$PKG_CONFIG_PATH &&
        make clean &&
        make
            INSTALL_PREFIX=${build_dir}
            MY_CMAKE_FLAGS="${build_cmakeflags}"
            ${build_options}
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

# custom target, always run
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} boost freetype glew jasper giflib jpeg libpng libraw libwebp ocio openjpeg openexr pkg-config ptex pybind tiff ffmpeg zlib )
