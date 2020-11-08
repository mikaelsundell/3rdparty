##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  3rdparty_macros.cnake for 3rdparty
##  
##  Macros and helpful tools.
##
##-*****************************************************************************

function (build_info message)
    message( STATUS ${message} )
endfunction()

function (build_warning message)
    message( WARNING ${message} )
endfunction()

function (build_debug message)
    message( AUTHOR_WARNING "${message}" )
endfunction()

function (build_error message)
    message( FATAL_ERROR "${message}" )
endfunction()

##-*****************************************************************************

function ( build_add_project NAME )
    cmake_parse_arguments (args "" "DIR;DESCRIPTION;BUILD" "" ${ARGN})
    # Arguments: <prefix> <options> <one_value_keywords> <multi_value_keywords> args...
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

function( build_add_files files dir output_files )
    foreach( file ${files} )
        list( 
            APPEND dir_files
            ${dir}/${file}
        )
    endforeach()
    set(${output_files} ${dir_files} PARENT_SCOPE)
endfunction()

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

function( build_add_script files dir prefix prefix_framework output_script )
    if ( APPLE )
        set( install_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
            --prefix-lib ${prefix}
            --prefix-framework ${prefix_framework}
            --absolute-path ${dir}
            ${files}
        )
        set(${output_script} ${install_script} PARENT_SCOPE)
    endif()
endfunction()

function( build_add_check files output_script )
      set( check_script 
          ${PROJECT_SOURCE_DIR}/src/scripts/install_check.sh 
          ${files}
      )
      set(${output_script} ${check_script} PARENT_SCOPE)
endfunction()


##-*****************************************************************************






