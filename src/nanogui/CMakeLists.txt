##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  nanogui CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# nanogui Copyright
# NanoGUI was developed by Wenzel Jakob <wenzel.jakob@epfl.ch>.

# nanogui from github 2022-03-26
# https://github.com/wjakob/nanogui

build_info( " Adding nanogui project" )

# project configuration

# project name
set( project_name "nanogui" )

# project pkg
set( project_pkg ${project_name}-master-220326 )

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
# inc dir
SET( inc_dir
    nanogui
)

# lib files
set( lib_files
    nanogui
)

if( UNIX )

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

IF( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=true )
    else()
        SET( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    set( build_options ${build_options} -DCMAKE_MODULE_PATH=${build_dir}/share/cmake/pybind11 )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        export CPLUS_INCLUDE_PATH=${build_inc_dir} &&
        export LD_LIBRARY_PATH=${build_lib_dir} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_INSTALL_PREFIX=${build_dir} 
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # copy include
    set( build_include
        cd ${project_pkg} &&
        ${copy_dir} ./ext/eigen/Eigen ${build_dir}/include/Eigen &&
        ${copy_dir} ./ext/glfw/include/GLFW ${build_dir}/include/GLFW &&
        ${copy} ./ext/nanovg/src/fontstash.h ${build_dir}/include/fontstash.h &&
        ${copy} ./ext/nanovg/src/nanovg_gl_utils.h ${build_dir}/include/nanovg_gl_utils.h &&
        ${copy} ./ext/nanovg/src/nanovg_gl.h ${build_dir}/include/nanovg_gl.h &&
        ${copy} ./ext/nanovg/src/nanovg.h ${build_dir}/include/nanovg.h &&
        ${copy} ./ext/nanovg/src/stb_image.h ${build_dir}/include/stb_image.h &&
        ${copy} ./ext/nanovg/src/stb_truetype.h ${build_dir}/include/stb_truetype.h
    )

    # scripts
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
        COMMAND ${build_include}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${lib_output}
)

# dependencies
add_dependencies( ${project_name} pybind )
