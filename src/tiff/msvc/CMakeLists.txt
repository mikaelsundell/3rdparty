# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( TIFF VERSION 4.0.3 LANGUAGES C CXX )

find_package( JPEG REQUIRED )
find_package( ZLIB REQUIRED )

configure_file( libtiff/tiffconf.vc.h tiffconf.h COPYONLY )
configure_file( libtiff/tif_config.vc.h tif_config.h COPYONLY )

# Match the source lists in upstream libtiff/Makefile.vc and tools/Makefile.vc.
add_library( tiff
    libtiff/tif_aux.c libtiff/tif_close.c libtiff/tif_codec.c
    libtiff/tif_color.c libtiff/tif_compress.c libtiff/tif_dir.c
    libtiff/tif_dirinfo.c libtiff/tif_dirread.c libtiff/tif_dirwrite.c
    libtiff/tif_dumpmode.c libtiff/tif_error.c libtiff/tif_extension.c
    libtiff/tif_fax3.c libtiff/tif_fax3sm.c libtiff/tif_flush.c
    libtiff/tif_getimage.c libtiff/tif_jbig.c libtiff/tif_jpeg.c
    libtiff/tif_jpeg_12.c libtiff/tif_luv.c libtiff/tif_lzw.c
    libtiff/tif_next.c libtiff/tif_ojpeg.c libtiff/tif_open.c
    libtiff/tif_packbits.c libtiff/tif_pixarlog.c libtiff/tif_predict.c
    libtiff/tif_print.c libtiff/tif_read.c libtiff/tif_strip.c
    libtiff/tif_swab.c libtiff/tif_thunder.c libtiff/tif_tile.c
    libtiff/tif_unix.c libtiff/tif_version.c libtiff/tif_warning.c
    libtiff/tif_write.c libtiff/tif_zip.c
)
target_include_directories( tiff PUBLIC libtiff "${CMAKE_CURRENT_BINARY_DIR}" )
target_compile_definitions( tiff PRIVATE AVOID_WIN32_FILEIO JPEG_SUPPORT OJPEG_SUPPORT ZIP_SUPPORT PIXARLOG_SUPPORT )
target_link_libraries( tiff PRIVATE JPEG::JPEG ZLIB::ZLIB )
if( BUILD_SHARED_LIBS )
    target_sources( tiff PRIVATE libtiff/libtiff.def )
endif()

add_library( tiffxx libtiff/tif_stream.cxx )
target_link_libraries( tiffxx PUBLIC tiff )
set_target_properties( tiffxx PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON )

add_library( tiff_port STATIC port/getopt.c port/strcasecmp.c )
target_include_directories( tiff_port PUBLIC port )

set( tools
    bmp2tiff fax2tiff fax2ps gif2tiff pal2rgb ppm2tiff ras2tiff
    raw2tiff rgb2ycbcr thumbnail tiff2bw tiff2pdf tiff2ps tiff2rgba
    tiffcmp tiffcp tiffcrop tiffdither tiffdump tiffinfo tiffmedian
    tiffset tiffsplit
)
foreach( tool IN LISTS tools )
    add_executable( ${tool} "tools/${tool}.c" )
    target_compile_definitions( ${tool} PRIVATE NEED_LIBPORT )
    target_link_libraries( ${tool} PRIVATE tiff tiff_port )
endforeach()

install( TARGETS tiff tiffxx ${tools} )
install( FILES libtiff/tiff.h libtiff/tiffio.h libtiff/tiffio.hxx libtiff/tiffvers.h
    "${CMAKE_CURRENT_BINARY_DIR}/tiffconf.h" DESTINATION include
)
