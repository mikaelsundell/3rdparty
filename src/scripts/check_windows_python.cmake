# SPDX-License-Identifier: BSD-3-Clause

foreach( file IN ITEMS "${python_executable}" "${python_header}" "${python_library}" "${python_dll}" )
    if( NOT EXISTS "${file}" OR IS_DIRECTORY "${file}" )
        message( FATAL_ERROR "The selected Windows Python SDK is missing '${file}'" )
    endif()
endforeach()

execute_process(
    COMMAND "${python_executable}" -B -I -c
        "import struct, sys; sys.exit(not (sys.version.split()[0].rsplit('.', 1)[0] == sys.argv[1] and struct.calcsize('P') == 8 and hasattr(sys, 'gettotalrefcount') == (sys.argv[2] == 'on')))"
        "${python_version}" "${python_debugging}"
    RESULT_VARIABLE result
)
if( NOT result STREQUAL "0" )
    message( FATAL_ERROR "Python '${python_executable}' must be x64 Python ${python_version} with debug ABI ${python_debugging}" )
endif()
