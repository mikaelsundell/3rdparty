##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr-images CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# openexr-images Copyright
# Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

# openexr-images from openexr.com 1.0.2 2011-10-16
# http://www.openexr.com/downloads.html

build_info( " Adding openexr-images images" )

# media configuration

# media name
set( media_name "openexr-images" )

# media pkg
set( media_pkg ${media_name}-1.7.0 )

# project archive
set( media_arc ${project_pkg}.tar.gz )

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

IF( UNIX )

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
