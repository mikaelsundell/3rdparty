# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# OpenCV Copyright
# Copyright © 2024 , OpenCV team

# opencv from github 2024-01-08
# https://github.com/opencv/opencv

build_info( " Adding opencv project" )

# project configuration

# project name
set( project_name "opencv" )

# project pkg
set( project_pkg ${project_name}-4.x )

# project archive
set( project_arc ${project_pkg}.zip )

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
    opencv_annotation
    opencv_interactive-calibration
    opencv_model_diagnostics
    opencv_version
    opencv_visualisation
)

# inc dir
SET( inc_dir
    opencv4
)

# lib files
set( lib_files
    opencv_calib3d
    opencv_core
    opencv_dnn
    opencv_features2d
    opencv_flann
    opencv_gapi
    opencv_highgui
    opencv_imgcodecs
    opencv_imgproc
    opencv_ml
    opencv_objdetect
    opencv_photo
    opencv_stitching
    opencv_ts
    opencv_video
    opencv_videoio
)


# site-packages
set( opencv_files
    cv2
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
    set( lib_version "4.9.0" )
    
    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            # opencv_ts is static
            if( NOT ${lib_file} STREQUAL "opencv_ts" )

                list( APPEND lib_output 
                    ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
                )
            endif()
        endif()
    endforeach()

    # site packages files
    foreach( opencv_file ${opencv_files} )
    
        if ( APPLE )
            list( APPEND lib_output 
                ${build_sitepackages_dir}/cv2/python-${build_python3_version}/${opencv_file}.cpython-${build_python3_versiontag}-darwin${sitepackage_suffix}
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
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=true )
    else()
        set( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    # dependencies
    set( build_config ${build_config} -DBUILD_JPEG=OFF )
    set( build_config ${build_config} -DWITH_JPEG=ON )
    set( build_config ${build_config} -DBUILD_OPENEXR=OFF )
    set( build_config ${build_config} -DWITH_OPENEXR=ON )
    set( build_config ${build_config} -DBUILD_PNG=OFF )
    set( build_config ${build_config} -DWITH_PNG=ON )
    set( build_config ${build_config} -DBUILD_TIFF=OFF )
    set( build_config ${build_config} -DWITH_TIFF=ON )
    set( build_config ${build_config} -DBUILD_WEBP=OFF )
    set( build_config ${build_config} -DWITH_WEBP=ON )
    set( build_config ${build_config} -DBUILD_ZLIB=OFF )
    set( build_config ${build_config} -DWITH_ZLIB=ON )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir} 
            -DCMAKE_INSTALL_PREFIX=${build_dir} 
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DPYTHON_EXECUTABLE=${build_python3}
            -DPYTHON_INCLUDE_DIR=${build_python3_include_dir}
            -DPYTHON_LIBRARY=${build_python3_library_dir}
            -DPYTHON3_PACKAGES_PATH=${build_sitepackages_dir}
            -DCMAKE_CXX_FLAGS=-stdlib=libc++
            -DCMAKE_CXX_STANDARD=17
            ${build_options}
            ${build_config} &&
        cmake --build . --parallel &&
        make install
    )

    # scripts
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
        COMMAND ${sitepackage_script}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${include_output} ${lib_output} 
)

# dependencies
add_dependencies( ${project_name} jpeg libpng libwebp openexr tiff zlib  )
