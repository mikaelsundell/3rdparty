# Copyright 2010-present Mikael Sundell and the other authors and contributors.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream media package: OpenImageIO-oiio-images-3819677
# Upstream licensing: see THIRD_PARTY_NOTICES.md (archive not verified locally).

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

# Custom target builds missing installed outputs.
add_custom_target(
    ${media_name} ALL
    DEPENDS ${media_output}
)
