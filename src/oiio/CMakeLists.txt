# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: OpenImageIO-3.1.8.0
# Archive: OpenImageIO-3.1.8.0.tar.gz
# Upstream copyright and license notices: licenses/third-party/oiio/

build_info( " Adding oiio project" )

# project configuration

# project name
set( project_name "oiio" )

# project pkg
set( project_pkg "OpenImageIO-3.1.8.0" )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

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

# lib files
set( lib_files OpenImageIO OpenImageIO_Util )

# platform-specific outputs
if( WIN32 )
    list( TRANSFORM lib_files APPEND "${build_python3_postfix}" )
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    build_add_files( "OpenImageIO/imageio.h" "${build_inc_dir}" inc_output )
    build_add_files( "OpenImageIOConfig.cmake" "${build_lib_dir}/cmake/OpenImageIO" cmake_output )
    build_add_files( "OpenImageIO${build_python3_postfix}.pyd;__init__.py" "${build_sitepackages_dir}/OpenImageIO" sitepackages_output )
else()
    # bin files
    set( bin_files
        idiff
        igrep
        iinfo
        iv
        maketx
        oiiotool
    )

    # site-packages
    set( sitepackages_files
        OpenImageIO
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_d" )
    endif()

    set( lib_version "3.1.8" )

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

if( WIN32 )
    set( build_prepare ${build_python_check} )
    # patches
    set( patch "${project_src_dir}/msvc/python-debug-postfix.patch" )
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch "${patch}" )
    set( build_runtime_path "${build_dir}/bin" "${build_lib_dir}" )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        "-DPYTHON_SITE_DIR=${build_sitepackages_dir}/OpenImageIO"
        -DUSE_PYTHON=ON
        -DOIIO_BUILD_TESTS=OFF
        -DUSE_FFMPEG=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_libjpeg-turbo=ON
        -DPYBIND11_FINDPYTHON=ON
        ${build_python_options}
        ${build_python_find_options}
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

    set( build_output ${lib_output} ${runtime_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
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
    # Libsquish = Not used

    set( build_config ${build_config} Boost_ROOT=${build_dir} )
    set( build_config ${build_config} FFmpeg_ROOT=${build_dir} )
    set( build_config ${build_config} JPEG_ROOT=${build_dir} )
    set( build_config ${build_config} OpenEXR_ROOT=${build_dir} )
    set( build_config ${build_config} OpenJpeg_ROOT=${build_dir} )
    set( build_config ${build_config} PNG_ROOT=${build_dir} )
    set( build_config ${build_config} PTex_ROOT=${build_dir} )
    set( build_config ${build_config} TIFF_ROOT=${build_dir} )

    # TBB - Use internal
    set( build_config ${build_config} USE_TBB=0 )

    # make and install
    string( JOIN " " build_cmakeflags ${build_cmakeflags} )
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
        export PATH=${build_bin_dir}:$PATH &&
        export PKG_CONFIG_PATH=${build_pkgconfig_dir}:$PKG_CONFIG_PATH &&
        make clean &&
        make
            INSTALL_PREFIX=${build_dir}
            "MY_CMAKE_FLAGS=\"${build_cmakeflags}\""
            ${build_options}
            ${build_config}
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )

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

    set( build_output ${bin_output} ${lib_output} )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} boost freetype glew jasper giflib jpeg libpng libraw libwebp ocio openjpeg openexr ptex pybind tiff zlib-ng )

if( WIN32 )
    build_add_dependencies( ${project_name} onetbb )
else()
    build_add_dependencies( ${project_name} pkg-config ffmpeg )
endif()
