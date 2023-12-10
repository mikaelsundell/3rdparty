##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  ffmpeg CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# ffmpeg Copyright
# Copyright (c) Fabrice Bellard

# ffmpeg from www.ffmpeg.org snapshot 2014-02-03
# http://www.ffmpeg.org/releases

build_info( " Adding ffmpeg project" )

# project configuration*

# project name
set( project_name "ffmpeg" )

# project pkg
set( project_pkg ${project_name}-4.3)

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
    ffmpeg
    ffprobe
)

# inc dirs
set( inc_dirs
    libavcodec
    libavdevice
    libavfilter
    libavformat
    libavutil
    libswresample
    libswscale
)

# lib files
set( lib_files
    avcodec.58.91.100
    avdevice.58.10.100
    avfilter.7.85.100
    avformat.58.45.100
    avutil.56.51.100
    swresample.3.7.100
    swscale.5.7.100
    postproc.55.7.100
)

# pkgfiles
set( pkg_files
    libavcodec.pc
    libavdevice.pc
    libavfilter.pc
    libavformat.pc
    libavutil.pc
    libswresample.pc
    libswscale.pc
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
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
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
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    # configure, make and install
    SET( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$$PATH &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            --extra-cflags=-I${build_inc_dir}
            --extra-cxxflags=-I${build_inc_dir}
            --extra-ldflags=-L${build_lib_dir}
            --enable-gpl
            --enable-libx264
            ${build_options} &&
        make ${build_flags} &&
        make install
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

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} jpeg libpng yasm x264 )
