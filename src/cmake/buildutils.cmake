# Copyright 2022-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

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
    if( ${NAME} )
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

function(build_find_python3 output_python3 output_version output_versiontag output_include_dir output_library)
    find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
    set(${output_python3} "${Python3_EXECUTABLE}" PARENT_SCOPE)
    set(${output_version} "${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}" PARENT_SCOPE)
    set(${output_versiontag} "${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}" PARENT_SCOPE)
    list(GET Python3_INCLUDE_DIRS 0 python_include_dir)
    set(${output_include_dir} "${python_include_dir}" PARENT_SCOPE)
    set(${output_library} "${Python3_LIBRARIES}" PARENT_SCOPE)
endfunction()

# Record edges now; targets in later groups may not exist yet.
function(build_add_dependencies target)
    foreach(dependency IN LISTS ARGN)
        set_property(GLOBAL APPEND PROPERTY build_dependency_edges "${target}|${dependency}")
    endforeach()
endfunction()

function(build_validate_dependencies)
    get_property(edges GLOBAL PROPERTY build_dependency_edges)
    foreach(edge IN LISTS edges)
        string(REPLACE "|" ";" pair "${edge}")
        list(GET pair 0 target)
        list(GET pair 1 dependency)
        if(NOT TARGET "${dependency}")
            if(dependency STREQUAL "eigen")
                set(dependency_option eigen3)
            else()
                set(dependency_option "${dependency}")
            endif()
            message(FATAL_ERROR
                "${target} requires disabled or unavailable target '${dependency}'. "
                "Enable its build group (build_base, build_libs, or build_extras) "
                "and -D${dependency_option}=ON, or disable -D${target}=OFF.")
        endif()
        add_dependencies("${target}" "${dependency}")
    endforeach()
endfunction()

# Installed outputs are rebuilt when the recipe, flags, or support files change.
# file(CONFIGURE) preserves the timestamp when command arguments are unchanged.
function(build_add_custom_command)
    string(SHA256 recipe_hash "${ARGN}")
    list(FIND ARGN OUTPUT output_index)
    math(EXPR output_index "${output_index} + 1")
    list(GET ARGN ${output_index} first_output)
    string(SHA256 output_hash "${first_output}")
    set(recipe_file "${CMAKE_CURRENT_BINARY_DIR}/build-recipe-${output_hash}.txt")
    file(CONFIGURE OUTPUT "${recipe_file}" CONTENT "${recipe_hash}\n" @ONLY)
    file(GLOB support_files CONFIGURE_DEPENDS LIST_DIRECTORIES false
        "${CMAKE_CURRENT_SOURCE_DIR}/*"
        "${PROJECT_SOURCE_DIR}/src/scripts/*")
    add_custom_command(${ARGN}
        DEPENDS "${recipe_file}"
            "${PROJECT_SOURCE_DIR}/CMakeLists.txt"
            "${PROJECT_SOURCE_DIR}/src/cmake/buildutils.cmake"
            ${support_files})
endfunction()
