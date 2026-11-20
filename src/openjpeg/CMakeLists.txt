# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: openjpeg-2.5.4
# Archive: openjpeg-2.5.4.zip
# Upstream copyright and license notices: licenses/third-party/openjpeg/

build_info( " Adding openjpeg project" )

# project configuration

# project name
set( project_name "openjpeg" )

# project pkg
set( project_pkg "openjpeg-2.5.4" )

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

# installed files
set( bin_files opj_compress opj_decompress opj_dump )
list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
set( inc_files OPENJPEG-2.5/openjpeg.h OPENJPEG-2.5/opj_config.h )
string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
set( cmake_files
    OpenJPEGConfig.cmake OpenJPEGConfigVersion.cmake
    OpenJPEGTargets.cmake "OpenJPEGTargets-${build_variant}.cmake"
)
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_versioned_lib( openjp2 2.5.4 7 lib_output shared_output )
build_add_files( libopenjp2.pc "${build_lib_dir}/pkgconfig" pkg_output )
build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/OPENJPEG-2.5" cmake_output )

# configure, make and install
set( build_static_libs ON )
if( WIN32 AND CMAKE_SHARED_LIBS )
    set( build_static_libs OFF )
endif()
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
    -DBUILD_TESTING=OFF -DBUILD_STATIC_LIBS=${build_static_libs}
)
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# scripts
if( shared_output )
    build_install_script(
        "${shared_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
    )
endif()

# run
set( build_output ${lib_output} ${bin_output} ${inc_output} ${pkg_output} ${cmake_output} )
build_add_archive_rule()
add_custom_target( ${project_name} ALL DEPENDS ${build_output} )

if( WIN32 )
    build_add_dependencies( ${project_name} libpng tiff )
endif()
