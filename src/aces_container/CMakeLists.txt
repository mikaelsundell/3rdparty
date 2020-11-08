##-*****************************************************************************
##  Copyright 2012-2014 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  aces_container CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# aces_container Copyright
# Copyright © 2006 Academy of Motion Picture Arts and Sciences

# aces_container from github.com 1.0 2014-12-29
# https://github.com/ampas/aces_container

MESSAGE( STATUS " Adding aces_container library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "aces_container" )

# lib pkg

SET( lib_pkg ${lib_name} )

# lib url

SET( lib_url ${repo_url}/${lib_pkg}-1.0.tar.gz )

# lib src dir

SET( lib_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# lib bin dir

SET( lib_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        AcesContainer
    )
ELSE()
    SET( lib_files
        AcesContainer
    )
ENDIF()

IF( UNIX )

    # lib files

    FOREACH( lib_file ${lib_files} )
    
        IF ( APPLE )

            LIST( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
            )

	    ELSE()

            # INFO: on UNIX lib files appends version after suffix

            STRING( REGEX REPLACE 
                "^([^.]+)([.]*)(.*)" 
                "${lib_prefix}\\1${lib_suffix}\\2\\3" 
                lib_file "${lib_file}"
            )

            LIST( APPEND lib_output 
                ${build_lib_dir}/${lib_file}
            )

	    ENDIF()
    
    ENDFOREACH()

ELSEIF( WIN32 )

    # FIXME(mikael.sundell@gmail.com): add build support for win32.
    
ENDIF()

##-*****************************************************************************
## build configuration
##-*****************************************************************************

# unix

IF( UNIX )

    # download

    SET( build_download 
        ${download} ${lib_url}
    )

    # tar uncompress

    SET( build_uncompress
        ${untar} ${lib_bin_dir}/${lib_pkg}-1.0.tar.gz -C ${lib_bin_dir}
    )
    
    # patch

    #SET( build_patch
    #    patch ${lib_bin_dir}/${lib_pkg}/IlmCtl/CtlLex.cpp ${lib_src_dir}/CtlLex.cpp.patch &&
    #    patch ${lib_bin_dir}/${lib_pkg}/IlmCtlSimd/CtlSimdReg.h ${lib_src_dir}/CtlSimdReg.h.patch
    #)

    # options

    IF( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
        cd ${lib_pkg} &&
        cmake -DCMAKE_INSTALL_PREFIX=${build_dir} 
              -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
              ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${lib_output} )
        ENDIF()
    
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    ENDIF()

    # run

    ADD_CUSTOM_COMMAND( 
        OUTPUT ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_patch}
        COMMAND ${build_make}
        COMMAND ${build_script}
    )

ELSEIF( WIN32 )

    # FIXME(mikael.sundell@gmail.com): add build support for win32

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} ilmbase )

