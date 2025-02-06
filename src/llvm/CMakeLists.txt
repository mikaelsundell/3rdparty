# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# LLVM Copyright
# Copyright (C) 2024 The llvm project.

# llvm from github 2025-01-28
# https://github.com/llvm/llvm-project/releases/tag/llvmorg-16.0.6

build_info( " Adding llvm project" )

# project configuration

# project name
set( project_name "llvm" )

# project pkg
set( project_pkg ${project_name}-project-16.0.6.src )

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
    llvm-as
    llvm-bcanalyzer
    llvm-bitcode-strip
    llvm-c-test
    llvm-cat
    llvm-cfi-verify
    llvm-config
    llvm-cov
    llvm-cvtres
    llvm-cxxdump
    llvm-cxxfilt
    llvm-cxxmap
    llvm-debuginfo-analyzer
    llvm-debuginfod
    llvm-debuginfod-find
    llvm-diff
    llvm-dis
    llvm-dlltool
    llvm-dwarfdump
    llvm-dwarfutil
    llvm-dwp
    llvm-exegesis
    llvm-extract
    llvm-gsymutil
    llvm-ifs
    llvm-install-name-tool
    llvm-jitlink
    llvm-lib
    llvm-libtool-darwin
    llvm-link
    llvm-lipo
    llvm-lto
    llvm-lto2
    llvm-mc
    llvm-mca
    llvm-ml
    llvm-modextract
    llvm-mt
    llvm-nm
    llvm-objcopy
    llvm-objdump
    llvm-opt-report
    llvm-otool
    llvm-pdbutil
    llvm-profdata
    llvm-profgen
    llvm-ranlib
    llvm-rc
    llvm-readelf
    llvm-readobj
    llvm-reduce
    llvm-remark-size-diff
    llvm-remarkutil
    llvm-rtdyld
    llvm-sim
    llvm-size
    llvm-split
    llvm-stress
    llvm-strings
    llvm-strip
    llvm-symbolizer
    llvm-tapi-diff
    llvm-tblgen
    llvm-tli-checker
    llvm-undname
    llvm-windres
    llvm-xray    
    clang-16
    clang-check
    clang-cl
    clang-cpp
    clang-extdef-mapping
    clang-format
    clang-linker-wrapper
    clang-offload-bundler
    clang-offload-packager
    clang-refactor
    clang-rename
    clang-repl
    clang-scan-deps
    clang-tblgen
)

# inc dir
SET( inc_dir
    llvm
    llvm-c
    clang
    clang-c
)

# lib files
set( lib_files
    LLVMAArch64AsmParser
    LLVMAArch64CodeGen
    LLVMAArch64Desc
    LLVMAArch64Disassembler
    LLVMAArch64Info
    LLVMAArch64Utils
    LLVMAMDGPUAsmParser
    LLVMAMDGPUCodeGen
    LLVMAMDGPUDesc
    LLVMAMDGPUDisassembler
    LLVMAMDGPUInfo
    LLVMAMDGPUTargetMCA
    LLVMAMDGPUUtils
    LLVMARMAsmParser
    LLVMARMCodeGen
    LLVMARMDesc
    LLVMARMDisassembler
    LLVMARMInfo
    LLVMARMUtils
    LLVMAVRAsmParser
    LLVMAVRCodeGen
    LLVMAVRDesc
    LLVMAVRDisassembler
    LLVMAVRInfo
    LLVMAggressiveInstCombine
    LLVMAnalysis
    LLVMAsmParser
    LLVMAsmPrinter
    LLVMBPFAsmParser
    LLVMBPFCodeGen
    LLVMBPFDesc
    LLVMBPFDisassembler
    LLVMBPFInfo
    LLVMBinaryFormat
    LLVMBitReader
    LLVMBitWriter
    LLVMBitstreamReader
    LLVMCFGuard
    LLVMCFIVerify
    LLVMCodeGen
    LLVMCore
    LLVMCoroutines
    LLVMCoverage
    LLVMDWARFLinker
    LLVMDWARFLinkerParallel
    LLVMDWP
    LLVMDebugInfoCodeView
    LLVMDebugInfoDWARF
    LLVMDebugInfoGSYM
    LLVMDebugInfoLogicalView
    LLVMDebugInfoMSF
    LLVMDebugInfoPDB
    LLVMDebuginfod
    LLVMDemangle
    LLVMDiff
    LLVMExecutionEngine
    LLVMExegesis
    LLVMExegesisAArch64
    LLVMExegesisMips
    LLVMExegesisPowerPC
    LLVMExegesisX86
    LLVMExtensions
    LLVMFileCheck
    LLVMFrontendHLSL
    LLVMFrontendOpenACC
    LLVMFrontendOpenMP
    LLVMFuzzMutate
    LLVMFuzzerCLI
    LLVMGlobalISel
    LLVMHexagonAsmParser
    LLVMHexagonCodeGen
    LLVMHexagonDesc
    LLVMHexagonDisassembler
    LLVMHexagonInfo
    LLVMIRPrinter
    LLVMIRReader
    LLVMInstCombine
    LLVMInstrumentation
    LLVMInterfaceStub
    LLVMInterpreter
    LLVMJITLink
    LLVMLTO
    LLVMLanaiAsmParser
    LLVMLanaiCodeGen
    LLVMLanaiDesc
    LLVMLanaiDisassembler
    LLVMLanaiInfo
    LLVMLibDriver
    LLVMLineEditor
    LLVMLinker
    LLVMLoongArchAsmParser
    LLVMLoongArchCodeGen
    LLVMLoongArchDesc
    LLVMLoongArchDisassembler
    LLVMLoongArchInfo
    LLVMMC
    LLVMMCA
    LLVMMCDisassembler
    LLVMMCJIT
    LLVMMCParser
    LLVMMIRParser
    LLVMMSP430AsmParser
    LLVMMSP430CodeGen
    LLVMMSP430Desc
    LLVMMSP430Disassembler
    LLVMMSP430Info
    LLVMMipsAsmParser
    LLVMMipsCodeGen
    LLVMMipsDesc
    LLVMMipsDisassembler
    LLVMMipsInfo
    LLVMNVPTXCodeGen
    LLVMNVPTXDesc
    LLVMNVPTXInfo
    LLVMObjCARCOpts
    LLVMObjCopy
    LLVMObject
    LLVMObjectYAML
    LLVMOption
    LLVMOrcJIT
    LLVMOrcShared
    LLVMOrcTargetProcess
    LLVMPasses
    LLVMPowerPCAsmParser
    LLVMPowerPCCodeGen
    LLVMPowerPCDesc
    LLVMPowerPCDisassembler
    LLVMPowerPCInfo
    LLVMProfileData
    LLVMRISCVAsmParser
    LLVMRISCVCodeGen
    LLVMRISCVDesc
    LLVMRISCVDisassembler
    LLVMRISCVInfo
    LLVMRISCVTargetMCA
    LLVMRemarks
    LLVMRuntimeDyld
    LLVMScalarOpts
    LLVMSelectionDAG
    LLVMSparcAsmParser
    LLVMSparcCodeGen
    LLVMSparcDesc
    LLVMSparcDisassembler
    LLVMSparcInfo
    LLVMSupport
    LLVMSymbolize
    LLVMSystemZAsmParser
    LLVMSystemZCodeGen
    LLVMSystemZDesc
    LLVMSystemZDisassembler
    LLVMSystemZInfo
    LLVMTableGen
    LLVMTableGenGlobalISel
    LLVMTarget
    LLVMTargetParser
    LLVMTextAPI
    LLVMTransformUtils
    LLVMVEAsmParser
    LLVMVECodeGen
    LLVMVEDesc
    LLVMVEDisassembler
    LLVMVEInfo
    LLVMVectorize
    LLVMWebAssemblyAsmParser
    LLVMWebAssemblyCodeGen
    LLVMWebAssemblyDesc
    LLVMWebAssemblyDisassembler
    LLVMWebAssemblyInfo
    LLVMWebAssemblyUtils
    LLVMWindowsDriver
    LLVMWindowsManifest
    LLVMX86AsmParser
    LLVMX86CodeGen
    LLVMX86Desc
    LLVMX86Disassembler
    LLVMX86Info
    LLVMX86TargetMCA
    LLVMXCoreCodeGen
    LLVMXCoreDesc
    LLVMXCoreDisassembler
    LLVMXCoreInfo
    LLVMXRay
    LLVMipo
    clang-cpp
    clang
    clangAPINotes
    clangARCMigrate
    clangAST
    clangASTMatchers
    clangAnalysis
    clangAnalysisFlowSensitive
    clangAnalysisFlowSensitiveModels
    clangBasic
    clangCodeGen
    clangCrossTU
    clangDependencyScanning
    clangDirectoryWatcher
    clangDriver
    clangDynamicASTMatchers
    clangEdit
    clangExtractAPI
    clangFormat
    clangFrontend
    clangFrontendTool
    clangHandleCXX
    clangHandleLLVM
    clangIndex
    clangIndexSerialization
    clangInterpreter
    clangLex
    clangParse
    clangRewrite
    clangRewriteFrontend
    clangSema
    clangSerialization
    clangStaticAnalyzerCheckers
    clangStaticAnalyzerCore
    clangStaticAnalyzerFrontend
    clangSupport
    clangTooling
    clangToolingASTDiff
    clangToolingCore
    clangToolingInclusions
    clangToolingRefactoring
    clangToolingSyntax
    clangTransformer
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
    DEPENDS ${lib_output}
)

# dependencies
add_dependencies( ${project_name} llvm )
