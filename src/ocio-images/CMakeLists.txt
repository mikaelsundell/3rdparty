##-*****************************************************************************
##  Copyright 2012-2014 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  OCIO CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# OCIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# ocio images from opencolorio.org 1.0v1 2011-11-24
# http://opencolorio.org/downloads.html

build_info( " Adding ocio-images images" )

# media configuration

# media name
set( media_name "ocio-images" )

# media pkg
set( media_pkg ${media_name}.1.0v1 )

# project archive
set( media_arc ${project_pkg}.tgz)

# media url
set( media_url ${repo_url}/${media_arc} )

# media src dir
set( media_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# media bin dir
set( media_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# media files
set( media_files
    ${media_name}
)

if( UNIX )

    # media files
    build_add_files( 
        "${media_files}" "${build_media_dir}" media_output
    )
    
endif()

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${media_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${media_bin_dir}/${media_arc} -C ${media_bin_dir}
    )

    # copy images          
    set( build_media
        cd _tmp &&
        ${make_dir} ${build_media_dir}/${media_name} &&
        ${copy_dir} ./ ${build_media_dir}/${media_name}
    )

    # run
    add_custom_command( 
        OUTPUT ${media_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_media}
    )

endif()

# custom target, always build
add_custom_target(
    ${media_name} ALL
    DEPENDS ${media_output}
)
