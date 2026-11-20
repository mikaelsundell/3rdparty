# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( giflib VERSION 5.1.4 LANGUAGES C )

# Match the sources and installed programs in lib/Makefile.am and util/Makefile.am.
add_library( gif
    lib/dgif_lib.c lib/egif_lib.c lib/gif_font.c lib/gif_hash.c
    lib/gifalloc.c lib/openbsd-reallocarray.c lib/gif_err.c lib/quantize.c
)
set_target_properties( gif PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON )
if( BUILD_SHARED_LIBS )
    target_compile_definitions( gif PUBLIC GIFLIB_SHARED )
endif()

add_library( gif_getarg STATIC util/getarg.c util/qprintf.c )
target_include_directories( gif PUBLIC lib PRIVATE "${GIFLIB_COMPAT_DIR}" )
target_include_directories( gif_getarg PUBLIC util PRIVATE lib )

set( tools gif2rgb gifbuild gifclrmp gifecho giffix gifinto giftext giftool )
foreach( tool IN LISTS tools )
    add_executable( ${tool} "util/${tool}.c" )
    target_include_directories( ${tool} PRIVATE "${GIFLIB_COMPAT_DIR}" )
    target_link_libraries( ${tool} PRIVATE gif gif_getarg )
endforeach()
target_sources( giftool PRIVATE "${GIFLIB_COMPAT_DIR}/getopt.c" )

install( TARGETS gif ${tools} )
install( FILES lib/gif_lib.h DESTINATION include )
