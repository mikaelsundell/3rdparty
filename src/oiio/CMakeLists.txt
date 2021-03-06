##-*****************************************************************************
##  Copyright 2012-2014 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  oiio CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# OIIO Copyright
# Copyright 2008 Larry Gritz and the other authors and contributors.
# All Rights Reserved.

# oiio from github.com master 2020-08-04
# https://github.com/OpenImageIO/oiio/tree/master

build_info( " Adding oiio project" )

# project configuration

# project name
set( project_name "oiio" )

# project pkg
set( project_pkg "oiio-master-200805" )

# project archive
set( project_arc ${project_pkg}.zip )

# project url
set( project_url ${repo_url}/${project_pkg}.zip )

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
    maketx
    iv
    oiiotool
)

# inc dir
SET( inc_dir
    OpenImageIO
)

# lib files
if ( CMAKE_SHARED_LIBS )
    set( lib_files
        OpenImageIO.2.3.0
        OpenImageIO_Util.2.3.0
    )
else()
    set( lib_files
        OpenImageIO
        OpenImageIO_Util
    )
endif()

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
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
    
ENDIF()

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

    # patch
    set( build_patch
        patch ${project_bin_dir}/oiio-master/src/cmake/externalpackages.cmake ${project_src_dir}/externalpackages.cmake.patch
    )

    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options debug )
    endif()
    
    # config

    if( CMAKE_VERBOSE_MAKEFILE )
        set( build_config ${build_config} VERBOSE=1 )
    else()
        set( build_config ${build_config} VERBOSE=0 )
    endif()

    # dependencies

    # JPEGTurbo = Not used
    # Freetype = Not used
    # HDF5 = Not used
    # OpenCV = Not used
    # TBB = Not used
    # DCMTK = Not used
    # Field3D = Not used
    # LibHeif = Not used
    # LibRaw = Not used
    # OpenVDB = Not used
    # PTex = Not used
    # Nuke = Not used
    # Libsquish = Not used

    # Boost

    set( build_config ${build_config} Boost_ROOT=${build_dir} )
    set( build_config ${build_config} FFmpeg_ROOT=${build_dir} )
    set( build_config ${build_config} JPEG_ROOT=${build_dir} )
    set( build_config ${build_config} OpenEXR_ROOT=${build_dir} )
    set( build_config ${build_config} OpenJpeg_ROOT=${build_dir} )
    set( build_config ${build_config} PNG_ROOT=${build_dir} )
    set( build_config ${build_config} TIFF_ROOT=${build_dir} )
    set( build_config ${build_config} Qt5_ROOT=${build_dir} )

    # TBB - Use internal.

    set( build_config ${build_config} USE_TBB=0 )
    
    # THIRD_PARTY_TOOLS_HOME -> Finds OpenEXR
    # CMAKE_PREFIX_PATH -> Finds Png, JPEG and other dependencies
    
    # make and install

    set( build_make
    	cd oiio-master &&
    )

    set( build_make
        ${build_make}
        export THIRD_PARTY_TOOLS_HOME=${build_dir} &&
    )

    # enable in build Qt support using cmake
    set( build_make
        ${build_make}
        export CMAKE_PREFIX_PATH=${build_dir}:${build_cmake_dir} &&
    )
    
    set( build_make
        ${build_make}
        export PATH=${build_bin_dir}:$$PATH &&
        make
            INSTALL_PREFIX=${build_dir}
            ${build_options}
            ${build_config}
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
        COMMAND ${build_patch}
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
add_dependencies( ${project_name} boost freetype glew jasper giflib jpeg libpng libwebp openjpeg openexr pybind tiff ffmpeg )
