##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  oiio-images CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# OIIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# oiio images from github.com 2011-11-24
# https://github.com/OpenImageIO/oiio-images/downloads

build_info( " Adding oiio-images images" )

# media configuration

# media name
set( media_name "oiio-images" )

# media pkg
set( media_pkg OpenImageIO-oiio-images-3819677 )

# project archive
set( media_arc ${project_pkg}.tgz)

# media url
set( media_url ${repo_url}/${media_pkg}.tar.gz )

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
        ${untar} ${media_bin_dir}/${media_pkg}.tar.gz -C ${media_bin_dir}
    )

    # copy images          
    set( build_media
        cd ${media_pkg} &&
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
