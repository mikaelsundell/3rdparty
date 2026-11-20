# SPDX-License-Identifier: BSD-3-Clause

foreach( module Qt6 Qt6Core Qt6Multimedia )
    set( config "${qt_prefix}/lib/cmake/${module}/${module}Config.cmake" )
    if( NOT EXISTS "${config}" )
        message( FATAL_ERROR "Build Qt in the selected prefix first. Missing '${config}'" )
    endif()
endforeach()

set( runtime_files moc.exe Qt6Core.dll )
if( qt_configuration STREQUAL "Debug" )
    list( APPEND runtime_files Qt6Cored.dll )
endif()
foreach( file IN LISTS runtime_files )
    set( runtime "${qt_prefix}/bin/${file}" )
    if( NOT EXISTS "${runtime}" )
        message( FATAL_ERROR "Build Qt in the selected prefix first. Missing '${runtime}'" )
    endif()
endforeach()
