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
    cmake_parse_arguments (args "WIN32" "DIR;DESCRIPTION;BUILD" "" ${ARGN})
    if( WIN32 AND NOT args_WIN32 )
        return()
    endif()
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
        if( WIN32 AND "${suffix}" STREQUAL "${CMAKE_SHARED_LIBRARY_SUFFIX}" )
            list( APPEND dir_files
                "${build_bin_dir}/${prefix}${file}${suffix}"
                "${dir}/${CMAKE_IMPORT_LIBRARY_PREFIX}${file}${CMAKE_IMPORT_LIBRARY_SUFFIX}"
            )
        elseif( APPLE OR WIN32 )
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

function( build_add_versioned_lib name version soversion output_libs output_shared )
    if( NOT CMAKE_SHARED_LIBS )
        build_add_libs( "${name}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" libs )
    elseif( WIN32 )
        build_add_files( "${lib_prefix}${name}${lib_suffix}" "${build_bin_dir}" shared )
        build_add_files(
            "${CMAKE_IMPORT_LIBRARY_PREFIX}${name}${CMAKE_IMPORT_LIBRARY_SUFFIX}"
            "${build_lib_dir}" libs
        )
    else()
        build_add_libs(
            "${name}.${version}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" shared
        )
        build_add_libs(
            "${name}.${soversion};${name}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" libs
        )
    endif()
    set( ${output_libs} ${shared} ${libs} PARENT_SCOPE )
    set( ${output_shared} ${shared} PARENT_SCOPE )
endfunction()

##-*****************************************************************************

function( build_cmake_commands source_dir output_make )
    set( configure_options
        "-DCMAKE_INSTALL_PREFIX=${build_dir}"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
        ${ARGN}
    )

    if( UNIX )
        string( JOIN " " cmake_env ${build_env} )
        string( JOIN " " make_flags ${build_flags} )
        set( commands
            COMMAND sh -c
                "${cmake_env} && cd \"$1\" && mkdir -p \"$2\" && cd \"$2\" && shift 2 && \"$@\" && make ${make_flags} && make install"
                sh "${source_dir}" "${build_cmake}" "${CMAKE_COMMAND}" ../ ${configure_options}
        )
    else()
        set( cmake_dir "${source_dir}/${build_cmake}" )
        set( env_command )
        if( build_runtime_path OR build_python_path OR build_env )
            set( env_command ${CMAKE_COMMAND} -E env )
            foreach( directory IN LISTS build_runtime_path )
                list( APPEND env_command --modify "PATH=path_list_prepend:${directory}" )
            endforeach()
            foreach( directory IN LISTS build_python_path )
                list( APPEND env_command --modify "PYTHONPATH=path_list_prepend:${directory}" )
            endforeach()
            list( APPEND env_command ${build_env} )
        endif()
        set( commands
            COMMAND ${env_command} ${CMAKE_COMMAND} -S "${source_dir}" -B "${cmake_dir}" -G "${CMAKE_GENERATOR}" ${configure_options}
            COMMAND ${env_command} ${CMAKE_COMMAND} --build "${cmake_dir}"
            COMMAND ${env_command} ${CMAKE_COMMAND} --install "${cmake_dir}"
        )
    endif()
    set( ${output_make} ${commands} PARENT_SCOPE )
endfunction()

##-*****************************************************************************

function( build_add_archive_rule )
    # Some recipes already select the files checked after install.
    if( NOT DEFINED build_check )
        build_install_check( "${build_output}" build_check )
    endif()
    add_custom_command(
        OUTPUT ${build_output} ${dir_output}
        DEPENDS ${build_inputs}
        ${build_prepare}
        COMMAND ${download} "${project_url}"
        COMMAND ${untar} "${project_bin_dir}/${project_arc}"
        ${build_patch}
        ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
        COMMAND ${sitepackage_script}
        WORKING_DIRECTORY "${project_bin_dir}"
        VERBATIM
    )
endfunction()

##-*****************************************************************************

function( build_patch_commands source_dir output )
    set( commands )
    foreach( patch IN LISTS ARGN )
        list( APPEND commands
            COMMAND ${CMAKE_COMMAND} -E chdir "${source_dir}" git apply --no-index "${patch}"
        )
    endforeach()
    set( ${output} ${commands} PARENT_SCOPE )
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
    if( WIN32 )
        # Keep the list out of the generated cmd.exe command line.
        set( install_list "${CMAKE_CURRENT_BINARY_DIR}/install-files.txt" )
        string( JOIN "\n" install_files ${files} )
        file( GENERATE OUTPUT "${install_list}" CONTENT "${install_files}\n" )
        set( check_script
            ${CMAKE_COMMAND} "-Dinstall_list=${install_list}"
            -P "${PROJECT_SOURCE_DIR}/src/scripts/install_check.cmake"
        )
    else()
        set( check_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_check.sh
            ${files}
        )
    endif()
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
