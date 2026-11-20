# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: llvm-project-20.1.3.src
# Archive: llvm-project-20.1.3.src.tar.xz
# Upstream copyright and license notices: licenses/third-party/llvm/

build_info( " Adding llvm project" )

# project configuration

# project name
set( project_name "llvm" )

# project pkg
set( project_pkg ${project_name}-project-20.1.3.src )

# project archive
set( project_arc ${project_pkg}.tar.xz )

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

# platform-specific outputs
if( WIN32 )
    set( bin_files libclang.dll )
    set( inc_files clang-c/Index.h )
    build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
    build_add_files( "stddef.h" "${build_lib_dir}/clang/20/include" resource_output )
    build_add_files( "libclang.lib" "${build_lib_dir}" lib_output )
    build_add_files( "LLVMConfig.cmake" "${build_lib_dir}/cmake/llvm" cmake_output )
    build_add_files( "ClangConfig.cmake" "${build_lib_dir}/cmake/clang" clang_output )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/rdf-comparators.patch"
    )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=OFF
        -DLLVM_ENABLE_PROJECTS=clang
        -DLLVM_TARGETS_TO_BUILD=X86
        -DLLVM_PARALLEL_COMPILE_JOBS=4
        -DLLVM_PARALLEL_LINK_JOBS=1
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_BENCHMARKS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DCLANG_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TOOLS=OFF
        -DCLANG_BUILD_TOOLS=OFF
        -DLLVM_ENABLE_ZLIB=OFF
        -DLLVM_ENABLE_ZSTD=OFF
        -DLLVM_ENABLE_LIBXML2=OFF
        -DLIBCLANG_BUILD_STATIC=OFF
    )

    # configure, make and install
    build_cmake_commands( "${project_bin_dir}/${project_pkg}/llvm" build_make ${build_options} )

    set( build_output ${bin_output} ${lib_output} ${inc_output} ${cmake_output} ${clang_output} ${resource_output} )
else()
    # patch
    set( build_patch
        COMMAND patch -p1 -d ${project_bin_dir}/${project_pkg}
              -i ${project_src_dir}/rdf-comparators.patch
    )

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=true )
    else()
        set( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    # config
    set( build_config ${build_config} -DLLVM_ENABLE_PROJECTS=clang )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../llvm -DCMAKE_INSTALL_PREFIX=${build_dir}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            ${build_options}
            ${build_config} &&
        make ${build_flags} &&
        make install
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
