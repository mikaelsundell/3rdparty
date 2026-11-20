# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( bzip2 VERSION 1.0.6 LANGUAGES C )

# Match the source list in upstream makefile.msc.
add_library( bz2 blocksort.c huffman.c crctable.c randtable.c compress.c decompress.c bzlib.c )
if( BUILD_SHARED_LIBS )
    # The upstream definition file supplies the public BZ2_* exports.
    target_sources( bz2 PRIVATE libbz2.def )
    set_target_properties( bz2 PROPERTIES RUNTIME_OUTPUT_NAME libbz2 )
endif()

add_executable( bzip2 bzip2.c )
target_link_libraries( bzip2 PRIVATE bz2 )
add_executable( bzip2recover bzip2recover.c )

install( TARGETS bz2 bzip2 bzip2recover )
install( FILES bzlib.h DESTINATION include )
