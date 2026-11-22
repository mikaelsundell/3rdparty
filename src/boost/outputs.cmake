# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

if( WIN32 )
    set( lib_files
        boost_atomic boost_charconv boost_chrono boost_container boost_context
        boost_contract boost_coroutine boost_fiber boost_filesystem boost_graph
        boost_iostreams boost_json boost_locale boost_log boost_log_setup
        boost_math_c99 boost_math_c99f boost_math_c99l boost_math_tr1 boost_math_tr1f boost_math_tr1l
        boost_nowide boost_prg_exec_monitor boost_process boost_program_options
        boost_python${build_python3_versiontag} boost_random boost_regex
        boost_serialization boost_stacktrace_from_exception boost_stacktrace_noop
        boost_stacktrace_windbg boost_stacktrace_windbg_cached boost_system boost_thread boost_timer
        boost_type_erasure boost_unit_test_framework boost_wave boost_wserialization
    )
else()
    # lib files
    set( lib_files
        boost_atomic
        boost_charconv
        boost_chrono
        boost_container
        boost_context
        boost_contract
        boost_coroutine
        boost_date_time
        boost_exception
        boost_fiber
        boost_filesystem
        boost_graph
        boost_iostreams
        boost_json
        boost_locale
        boost_log_setup
        boost_log
        boost_nowide
        boost_numpy${build_python3_versiontag}
        boost_prg_exec_monitor
        boost_process
        boost_program_options
        boost_python${build_python3_versiontag}
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
        boost_url
        boost_wave
        boost_wserialization
    )
endif()
