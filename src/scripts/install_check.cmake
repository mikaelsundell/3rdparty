# SPDX-License-Identifier: BSD-3-Clause

file( STRINGS "${install_list}" files )
foreach( file IN LISTS files )
    if( NOT EXISTS "${file}" OR IS_DIRECTORY "${file}" )
        message( FATAL_ERROR "Install check failed for file '${file}'" )
    endif()
endforeach()
