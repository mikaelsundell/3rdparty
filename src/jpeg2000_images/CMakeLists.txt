##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  jpeg2000_images CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# jpeg Copyright
# Copyright (C) 1991-1997, Thomas G. Lane.

# jpeg images from ijg.org 8c 2011-11-18
# http://www.ijg.org/files/

build_info( " Adding jpeg2000_images images" )

# media configuration

# media name
set( media_name "jpeg2000_images" )

# media pkg
set( media_pkg ${media_name} )

# project archive
set( media_arc ${project_pkg}.tar.gz )

# media url
set( media_url ${repo_url}/${media_pkg})

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

IF( UNIX )

    # media files
    build_add_files( 
        "${media_files}" "${build_media_dir}" media_output
    )
    
ENDIF()

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
