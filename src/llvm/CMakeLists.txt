##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  llvm CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# LLVM Copyright
# Copyright (C) 2022 The llvm project.

# llvm from github 2022-03-26
# https://github.com/llvm/llvm-project/releases/tag/llvmorg-13.0.1

build_info( " Adding llvm project" )

# project configuration

# project name
set( project_name "llvm" )

# project pkg
set( project_pkg ${project_name}-project-llvmorg-13.0.1 )

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
    llvm-ar
    llvm-as
    llvm-bcanalyzer
    llvm-c-test
    llvm-cat
    llvm-cfi-verify
    llvm-config
    llvm-cov
    llvm-cvtres
    llvm-cxxdump
    llvm-cxxfilt
    llvm-cxxmap
    llvm-diff
    llvm-dis
    llvm-dwarfdump
    llvm-dwp
    llvm-exegesis
    llvm-extract
    llvm-gsymutil
    llvm-ifs
    llvm-jitlink
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
    llvm-pdbutil
    llvm-profdata
    llvm-profgen
    llvm-rc
    llvm-readobj
    llvm-reduce
    llvm-rtdyld
    llvm-sim
    llvm-size
    llvm-split
    llvm-stress
    llvm-strings
    llvm-symbolizer
    llvm-tapi-diff
    llvm-tblgen
    llvm-undname
    llvm-xray
    clang-scan-deps
    clang-13
    clang-repl
    clang-check
    clang-extdef-mapping
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
    LLVMAggressiveInstCombine
    LLVMAMDGPUAsmParser
    LLVMAMDGPUCodeGen
    LLVMAMDGPUDesc
    LLVMAMDGPUDisassembler
    LLVMAMDGPUInfo
    LLVMAMDGPUUtils
    LLVMAnalysis
    LLVMARMAsmParser
    LLVMARMCodeGen
    LLVMARMDesc
    LLVMARMDisassembler
    LLVMARMInfo
    LLVMARMUtils
    LLVMAsmParser
    LLVMAsmPrinter
    LLVMAVRAsmParser
    LLVMAVRCodeGen
    LLVMAVRDesc
    LLVMAVRDisassembler
    LLVMAVRInfo
    LLVMBinaryFormat
    LLVMBitReader
    LLVMBitstreamReader
    LLVMBitWriter
    LLVMBPFAsmParser
    LLVMBPFCodeGen
    LLVMBPFDesc
    LLVMBPFDisassembler
    LLVMBPFInfo
    LLVMCFGuard
    LLVMCFIVerify
    LLVMCodeGen
    LLVMCore
    LLVMCoroutines
    LLVMCoverage
    LLVMDebugInfoCodeView
    LLVMDebugInfoDWARF
    LLVMDebugInfoGSYM
    LLVMDebugInfoMSF
    LLVMDebugInfoPDB
    LLVMDemangle
    LLVMDlltoolDriver
    LLVMDWARFLinker
    LLVMDWP
    LLVMExecutionEngine
    LLVMExegesis
    LLVMExegesisAArch64
    LLVMExegesisMips
    LLVMExegesisPowerPC
    LLVMExegesisX86
    LLVMExtensions
    LLVMFileCheck
    LLVMFrontendOpenACC
    LLVMFrontendOpenMP
    LLVMFuzzMutate
    LLVMGlobalISel
    LLVMHexagonAsmParser
    LLVMHexagonCodeGen
    LLVMHexagonDesc
    LLVMHexagonDisassembler
    LLVMHexagonInfo
    LLVMInstCombine
    LLVMInstrumentation
    LLVMInterfaceStub
    LLVMInterpreter
    LLVMipo
    LLVMIRReader
    LLVMJITLink
    LLVMLanaiAsmParser
    LLVMLanaiCodeGen
    LLVMLanaiDesc
    LLVMLanaiDisassembler
    LLVMLanaiInfo
    LLVMLibDriver
    LLVMLineEditor
    LLVMLinker
    LLVMLTO
    LLVMMC
    LLVMMCA
    LLVMMCACustomBehaviourAMDGPU
    LLVMMCDisassembler
    LLVMMCJIT
    LLVMMCParser
    LLVMMipsAsmParser
    LLVMMipsCodeGen
    LLVMMipsDesc
    LLVMMipsDisassembler
    LLVMMipsInfo
    LLVMMIRParser
    LLVMMSP430AsmParser
    LLVMMSP430CodeGen
    LLVMMSP430Desc
    LLVMMSP430Disassembler
    LLVMMSP430Info
    LLVMNVPTXCodeGen
    LLVMNVPTXDesc
    LLVMNVPTXInfo
    LLVMObjCARCOpts
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
    LLVMRemarks
    LLVMRISCVAsmParser
    LLVMRISCVCodeGen
    LLVMRISCVDesc
    LLVMRISCVDisassembler
    LLVMRISCVInfo
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
    LLVMTextAPI
    LLVMTransformUtils
    LLVMVectorize
    LLVMWebAssemblyAsmParser
    LLVMWebAssemblyCodeGen
    LLVMWebAssemblyDesc
    LLVMWebAssemblyDisassembler
    LLVMWebAssemblyInfo
    LLVMWebAssemblyUtils
    LLVMWindowsManifest
    LLVMX86AsmParser
    LLVMX86CodeGen
    LLVMX86Desc
    LLVMX86Disassembler
    LLVMX86Info
    LLVMXCoreCodeGen
    LLVMXCoreDesc
    LLVMXCoreDisassembler
    LLVMXCoreInfo
    LLVMXRay
    clang-cpp
    clang
    clangAnalysis
    clangAPINotes
    clangARCMigrate
    clangAST
    clangASTMatchers
    clangBasic
    clangCodeGen
    clangCrossTU
    clangDependencyScanning
    clangDirectoryWatcher
    clangDriver
    clangDynamicASTMatchers
    clangEdit
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
    clangTesting
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
