# SPDX-License-Identifier: BSD-3-Clause

# Find the Python that hosts the build driver, then select the SDK for the
# configuration. Only recipes that consume Python run the SDK check.
find_package( Python3 3.9 EXACT REQUIRED COMPONENTS Interpreter )
if( NOT build_python_root )
    execute_process(
        COMMAND "${Python3_EXECUTABLE}" -B -I -c "import sys; print(sys.base_prefix)"
        OUTPUT_VARIABLE build_python_root
        OUTPUT_STRIP_TRAILING_WHITESPACE
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()
file( TO_CMAKE_PATH "${build_python_root}" build_python_root )

set( build_python3_version "${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}" )
set( build_python3_versiontag "${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}" )
set( build_python3_debugging off )
set( build_python3_postfix "" )
if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
    set( build_python3_debugging on )
    set( build_python3_postfix "_d" )
endif()
set( build_python3 "${build_python_root}/python${build_python3_postfix}.exe" )
set( build_python3_include_dir "${build_python_root}/include" )
set( build_python3_library_dir "${build_python_root}/libs" )
set( build_python3_library "${build_python3_library_dir}/python${build_python3_versiontag}${build_python3_postfix}.lib" )
set( build_python3_dll "${build_python_root}/python${build_python3_versiontag}${build_python3_postfix}.dll" )
set( build_python3_extension "${build_python3_postfix}.cp${build_python3_versiontag}-win_amd64" )
set( build_python_check
    COMMAND "${CMAKE_COMMAND}"
        "-Dpython_executable=${build_python3}"
        "-Dpython_header=${build_python3_include_dir}/Python.h"
        "-Dpython_library=${build_python3_library}"
        "-Dpython_dll=${build_python3_dll}"
        "-Dpython_version=${build_python3_version}"
        "-Dpython_debugging=${build_python3_debugging}"
        -P "${build_scripts_dir}/check_windows_python.cmake"
)

set( build_python_options
    "-DPython3_EXECUTABLE=${build_python3}"
    "-DPython3_INCLUDE_DIR=${build_python3_include_dir}"
    "-DPython3_LIBRARY=${build_python3_library}"
)
if( build_python3_debugging )
    list( APPEND build_python_options "-DPython3_LIBRARY_DEBUG=${build_python3_library}" )
else()
    list( APPEND build_python_options "-DPython3_LIBRARY_RELEASE=${build_python3_library}" )
endif()

# Several upstream packages use FindPython rather than FindPython3.
set( build_python_find_options ${build_python_options} )
list( TRANSFORM build_python_find_options REPLACE "^-DPython3_" "-DPython_" )
