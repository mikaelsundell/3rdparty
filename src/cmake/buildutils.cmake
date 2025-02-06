##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

function( build_info message )
    message( STATUS ${message} )
endfunction()

function( build_warning message )
    message( WARNING ${message} )
endfunction()

function( build_debug message )
    message( AUTHOR_WARNING "${message}" )
endfunction()

function( build_error message )
    message( FATAL_ERROR "${message}" )
endfunction()

##-*****************************************************************************

function( build_add_project NAME )
    cmake_parse_arguments (args "" "DIR;DESCRIPTION;BUILD" "" ${ARGN})
    # arguments: <prefix> <options> <one_value_keywords> <multi_value_keywords> args...
    set( 
        "${NAME}" ${args_BUILD} CACHE BOOL ${args_DESCRIPTION}
    )
    if( ${args_BUILD} )
        add_subdirectory( ${args_DIR} )
    endif()
endfunction()

##-*****************************************************************************

function( build_add_dir dirs dir output_dirs )
    foreach( dirs_dir ${dirs} )
        list( 
            APPEND dir_dirs
            ${dir}/${dirs_dir}
        )
    endforeach()
    set(${output_dirs} ${dir_dirs} PARENT_SCOPE)
endfunction()

##-*****************************************************************************

function( build_add_files files dir output_files )
    foreach( file ${files} )
        list( 
            APPEND dir_files
            ${dir}/${file}
        )
    endforeach()
    set(${output_files} ${dir_files} PARENT_SCOPE)
endfunction()

##-*****************************************************************************

function( build_add_libs files dir prefix suffix output_files )
    foreach( file ${files} )
        if ( APPLE )
            list( 
                APPEND dir_files 
                ${dir}/${prefix}${file}${suffix}
            )
        else()
            # INFO: on UNIX lib files appends version after suffix
            string( 
                REGEX REPLACE 
                "^([^.]+)([.]*)(.*)" 
                "${prefix}\\1${suffix}\\2\\3" 
                file "${file}"
            )
            list( 
                APPEND dir_files
                ${dir}/${file}
            )
      endif()
    endforeach()
    set(${output_files} ${dir_files} PARENT_SCOPE)
endfunction()

##-*****************************************************************************

function( build_install_script files dir prefix prefix_framework output_script )
    if ( APPLE )
        set( install_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
            --prefix-lib ${prefix}
            --prefix-framework ${prefix_framework}
            --absolute-path ${dir}
            --suffix-debug _debug
            ${files}
        )
        set(${output_script} ${install_script} PARENT_SCOPE)
    endif()
endfunction()

##-*****************************************************************************

function( build_install_check files output_script )
      set( check_script 
          ${PROJECT_SOURCE_DIR}/src/scripts/install_check.sh 
          ${files}
      )
      set(${output_script} ${check_script} PARENT_SCOPE)
endfunction()

##-*****************************************************************************

function( build_find_python3 output_python3 output_version output_versiontag output_include_dir output_library_dir )
    execute_process( 
        COMMAND "${PROJECT_SOURCE_DIR}/src/scripts/find_python3.sh" "--python3" OUTPUT_VARIABLE python3
    )
    string(REGEX REPLACE "(\n)+" "" python3 ${python3})
    set(${output_python3} ${python3} PARENT_SCOPE)
    execute_process( 
        COMMAND "${PROJECT_SOURCE_DIR}/src/scripts/find_python3.sh" "--version" OUTPUT_VARIABLE version
    )
    string( REGEX REPLACE "^([0-9]+)\\.[0-9]+.*" "\\1" python_major "${version}" )
    string( REGEX REPLACE "^[0-9]+\\.([0-9])+.*" "\\1" python_minor "${version}" )
    set(${output_version} "${python_major}.${python_minor}" PARENT_SCOPE)
    set(${output_versiontag} "${python_major}${python_minor}" PARENT_SCOPE)    
    execute_process( 
        COMMAND "${PROJECT_SOURCE_DIR}/src/scripts/find_python3.sh" "--include-dir" OUTPUT_VARIABLE include_dir
    )
    string(REGEX REPLACE "(\n)+" "" include_dir ${include_dir})
    set(${output_include_dir} ${include_dir} PARENT_SCOPE)

    execute_process( 
        COMMAND "${PROJECT_SOURCE_DIR}/src/scripts/find_python3.sh" "--library-dir" OUTPUT_VARIABLE library_dir
    )
    string(REGEX REPLACE "(\n)+" "" library_dir ${library_dir})
    set(${output_library_dir} ${library_dir} PARENT_SCOPE)
endfunction()

##-*****************************************************************************
