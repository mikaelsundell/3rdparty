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

# required headers and compiler resources
set( inc_files clang-c/Index.h )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "stddef.h" "${build_lib_dir}/clang/20/include" resource_output )

# platform-specific outputs
if( WIN32 )
    set( bin_files libclang.dll )
    build_add_files( "libclang.lib" "${build_lib_dir}" lib_output )
    build_add_files( "LLVMConfig.cmake" "${build_lib_dir}/cmake/llvm" cmake_output )
    build_add_files( "ClangConfig.cmake" "${build_lib_dir}/cmake/clang" clang_output )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/outputs-unix.cmake" )
    build_add_libs( "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output )

    string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
    set( cmake_files LLVMConfig.cmake LLVMConfigVersion.cmake LLVMExports.cmake "LLVMExports-${build_variant}.cmake" )
    build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/llvm" cmake_output )
    set( cmake_files ClangConfig.cmake ClangConfigVersion.cmake ClangTargets.cmake "ClangTargets-${build_variant}.cmake" )
    build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/clang" clang_output )
    build_add_dir( "include/llvm;include/llvm-c;include/clang;include/clang-c;lib/clang/20/include" "${build_dir}" dir_output )
    build_add_files( "hmaptool" "${build_bin_dir}" script_output )
endif()
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

# patches
build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
    "${project_src_dir}/rdf-comparators.patch"
)

# options
set( build_options
    -DLLVM_ENABLE_PROJECTS=clang
    -DLLVM_PARALLEL_COMPILE_JOBS=4
    -DLLVM_PARALLEL_LINK_JOBS=1
    -DLLVM_INCLUDE_TESTS=OFF
    -DLLVM_INCLUDE_BENCHMARKS=OFF
    -DLLVM_INCLUDE_EXAMPLES=OFF
    -DCLANG_INCLUDE_TESTS=OFF
    -DLLVM_BUILD_TOOLS=OFF
    -DLLVM_ENABLE_ZLIB=OFF
    -DLLVM_ENABLE_ZSTD=OFF
    -DLLVM_ENABLE_LIBXML2=OFF
    -DLIBCLANG_BUILD_STATIC=OFF
)
if( WIN32 )
    list( APPEND build_options
        -DBUILD_SHARED_LIBS=OFF
        -DLLVM_TARGETS_TO_BUILD=X86
        -DCLANG_BUILD_TOOLS=OFF
    )
else()
    list( APPEND build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DLLVM_TARGETS_TO_BUILD=Native
        -DCLANG_BUILD_TOOLS=ON
        -DCLANG_TOOL_AMDGPU_ARCH_BUILD=OFF
        -DCLANG_TOOL_APINOTES_TEST_BUILD=OFF
        -DCLANG_TOOL_ARCMT_TEST_BUILD=OFF
        -DCLANG_TOOL_C_ARCMT_TEST_BUILD=OFF
        -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF
        -DCLANG_TOOL_CLANG_CHECK_BUILD=OFF
        -DCLANG_TOOL_CLANG_DIFF_BUILD=OFF
        -DCLANG_TOOL_CLANG_EXTDEF_MAPPING_BUILD=OFF
        -DCLANG_TOOL_CLANG_FORMAT_BUILD=OFF
        -DCLANG_TOOL_CLANG_FUZZER_BUILD=OFF
        -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF
        -DCLANG_TOOL_CLANG_INSTALLAPI_BUILD=OFF
        -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF
        -DCLANG_TOOL_CLANG_NVLINK_WRAPPER_BUILD=OFF
        -DCLANG_TOOL_CLANG_OFFLOAD_BUNDLER_BUILD=OFF
        -DCLANG_TOOL_CLANG_OFFLOAD_PACKAGER_BUILD=OFF
        -DCLANG_TOOL_CLANG_REFACTOR_BUILD=OFF
        -DCLANG_TOOL_CLANG_REPL_BUILD=OFF
        -DCLANG_TOOL_CLANG_SCAN_DEPS_BUILD=OFF
        -DCLANG_TOOL_CLANG_SHLIB_BUILD=OFF
        -DCLANG_TOOL_CLANG_SYCL_LINKER_BUILD=OFF
        -DCLANG_TOOL_DIAGTOOL_BUILD=OFF
        -DCLANG_TOOL_NVPTX_ARCH_BUILD=OFF
        -DCLANG_TOOL_SCAN_BUILD_BUILD=OFF
        -DCLANG_TOOL_SCAN_BUILD_PY_BUILD=OFF
        -DCLANG_TOOL_SCAN_VIEW_BUILD=OFF
    )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}/llvm" build_make ${build_options} )

# scripts
if( UNIX )
    build_install_script(
        "${bin_output};${lib_output}"
        ${build_dir}
        ${build_prefix_lib}
        ${build_prefix_framework}
        build_script
    )
endif()
set( build_output ${bin_output} ${lib_output} ${inc_output} ${resource_output} ${cmake_output} ${clang_output} ${script_output} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
