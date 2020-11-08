##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  Boost CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# Boost Copyright
# Copyright Beman Dawes, David Abrahams, 1998-2005.
# Copyright Rene Rivera 2004-2007.

# boost from sourceforge.net 1.73.0 2020-08-04
# https://www.boost.org/users/download/

build_info( " Adding boost project" )

# project configuration

# project name
set( project_name "boost" )

# project pkg
set( project_pkg ${project_name}_1_73_0 )

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

# project config
set( project_cfg_without_mpi TRUE )

# project src dir
set( project_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# project bin dir
set( project_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# inc dir
set( inc_dir
    boost
)

# lib files
set( lib_files
    boost_atomic
    boost_chrono
    boost_container
    boost_context
    boost_contract
    boost_coroutine
    boost_date_time
    boost_exception
    boost_filesystem
    boost_graph
    boost_iostreams
    boost_math_c99
    boost_math_c99f
    boost_math_c99l
    boost_math_tr1
    boost_math_tr1f
    boost_math_tr1l
    boost_prg_exec_monitor
    boost_program_options
    boost_python27
    boost_random
    boost_regex
    boost_serialization
    boost_stacktrace_addr2line
    boost_stacktrace_basic
    boost_stacktrace_noop
    boost_system
    boost_test_exec_monitor
    boost_thread
    boost_timer
    boost_type_erasure
    boost_unit_test_framework
    boost_wave
    boost_wserialization
)

if( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )
    
    # lib files
    set( lib_mttag "-mt" )

    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( lib_dtag "-d" )
    endif()

    foreach( lib_file ${lib_files} )
    
        if ( APPLE )
            # boost_exception and boost_test_exec_monitor are static, see below
            if( NOT ${lib_file} STREQUAL "boost_exception" AND
                NOT ${lib_file} STREQUAL "boost_test_exec_monitor" )

                LIST( APPEND lib_output 
                    ${build_lib_dir}/${lib_prefix}${lib_file}${lib_mttag}${lib_dtag}-x64${lib_suffix}
                )
            endif()

        else()

            # INFO: on UNIX lib files appends version after suffix
            if( NOT ${lib_file} STREQUAL "boost_thread" )
                STRING( REGEX REPLACE 
                    "^([^.]+)([.]*)(.*)" 
                    "${lib_prefix}\\1${lib_dtag}${lib_suffix}.1.73.0\\2\\3" 
                    st_file "${lib_file}"
                )

                LIST( APPEND lib_output 
                    ${build_lib_dir}/${st_file}
                )
            endif()

            string( REGEX REPLACE 
                "^([^.]+)([.]*)(.*)" 
                "${lib_prefix}\\1${lib_mttag}${lib_dtag}${lib_suffix}.1.73.0\\2\\3" 
                mt_file "${lib_file}"
            )

            list( APPEND lib_output 
                ${build_lib_dir}/${mt_file}
            )

        endif()
    
    endforeach()
    
endif()

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( build_options variant=debug )
    else()
        set( build_options variant=release )
    endif()

    if( CMAKE_SHARED_LIBS )
        set( build_options ${build_options} link=shared )
    else()
        set( build_options ${build_options} link=static )
    endif()
    
    # config    
    if( project_cfg_without_mpi )
        set( build_config --without-mpi )
    endif()

    # bootstrap, b2 install
    set( build_b2
        ${build_env} &&
        cd ${project_pkg} &&
        ./bootstrap.sh &&
        ./b2 install 
            --prefix=${build_dir}
            --build-type=complete 
            --layout=tagged
            ${build_config}
            ${build_options}
    )
    
    # scripts    
    if ( APPLE )    
        # build output        
        set( build_output ${bin_output} )

        if ( CMAKE_SHARED_LIBS )
            set( build_output ${build_output} ${lib_output} )
            
            # remove static boost_exception
            
            list( REMOVE_ITEM build_output
                ${build_lib_dir}/${lib_prefix}boost_exception${static_lib_suffix}
            )
        endif()
    
        set( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    endif()

    build_add_check( 
        "${build_output}" 
        build_check
    )

    # run
    add_custom_command( 
        OUTPUT ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_b2}
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
add_dependencies( ${project_name} bzip2 zlib )
