# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( LibRaw VERSION 0.21.1 LANGUAGES C CXX )

find_package( JPEG REQUIRED )
find_package( Jasper REQUIRED )
find_library( lcms2_LIBRARY NAMES lcms2 PATHS "${CMAKE_INSTALL_PREFIX}/lib" NO_DEFAULT_PATH REQUIRED )

# Core sources from upstream Makefile.am and Makefile.msvc.
add_library( raw
    src/libraw_c_api.cpp src/libraw_datastream.cpp
    src/decoders/canon_600.cpp src/decoders/crx.cpp src/decoders/decoders_dcraw.cpp
    src/decoders/decoders_libraw_dcrdefs.cpp src/decoders/decoders_libraw.cpp
    src/decoders/dng.cpp src/decoders/fp_dng.cpp src/decoders/fuji_compressed.cpp
    src/decoders/generic.cpp src/decoders/kodak_decoders.cpp src/decoders/load_mfbacks.cpp
    src/decoders/smal.cpp src/decoders/unpack_thumb.cpp src/decoders/unpack.cpp
    src/demosaic/aahd_demosaic.cpp src/demosaic/ahd_demosaic.cpp
    src/demosaic/dcb_demosaic.cpp src/demosaic/dht_demosaic.cpp
    src/demosaic/misc_demosaic.cpp src/demosaic/xtrans_demosaic.cpp
    src/integration/dngsdk_glue.cpp src/integration/rawspeed_glue.cpp
    src/metadata/adobepano.cpp src/metadata/canon.cpp src/metadata/ciff.cpp
    src/metadata/cr3_parser.cpp src/metadata/epson.cpp src/metadata/exif_gps.cpp
    src/metadata/fuji.cpp src/metadata/hasselblad_model.cpp src/metadata/identify_tools.cpp
    src/metadata/identify.cpp src/metadata/kodak.cpp src/metadata/leica.cpp
    src/metadata/makernotes.cpp src/metadata/mediumformat.cpp src/metadata/minolta.cpp
    src/metadata/misc_parsers.cpp src/metadata/nikon.cpp src/metadata/normalize_model.cpp
    src/metadata/olympus.cpp src/metadata/p1.cpp src/metadata/pentax.cpp
    src/metadata/samsung.cpp src/metadata/sony.cpp src/metadata/tiff.cpp
    src/postprocessing/aspect_ratio.cpp src/postprocessing/dcraw_process.cpp
    src/postprocessing/mem_image.cpp src/postprocessing/postprocessing_aux.cpp
    src/postprocessing/postprocessing_utils_dcrdefs.cpp src/postprocessing/postprocessing_utils.cpp
    src/preprocessing/ext_preprocess.cpp src/preprocessing/raw2image.cpp src/preprocessing/subtract_black.cpp
    src/tables/cameralist.cpp src/tables/colorconst.cpp src/tables/colordata.cpp src/tables/wblists.cpp
    src/utils/curves.cpp src/utils/decoder_info.cpp src/utils/init_close_utils.cpp src/utils/open.cpp
    src/utils/phaseone_processing.cpp src/utils/read_utils.cpp src/utils/thumb_utils.cpp
    src/utils/utils_dcraw.cpp src/utils/utils_libraw.cpp
    src/write/apply_profile.cpp src/write/file_write.cpp src/write/tiff_writer.cpp
    src/x3f/x3f_parse_process.cpp src/x3f/x3f_utils_patched.cpp
)
target_include_directories( raw PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" PRIVATE "${CMAKE_INSTALL_PREFIX}/include" )
target_compile_definitions( raw PRIVATE LIBRAW_BUILDLIB USE_JPEG USE_JASPER USE_LCMS2 _CRT_SECURE_NO_WARNINGS )
target_link_libraries( raw PRIVATE JPEG::JPEG Jasper::Jasper "${lcms2_LIBRARY}" ws2_32 )
if( NOT BUILD_SHARED_LIBS )
    target_compile_definitions( raw PUBLIC LIBRAW_NODLL )
endif()

set( tools 4channels dcraw_emu multirender_test postprocessing_benchmark raw-identify rawtextdump simple_dcraw unprocessed_raw )
foreach( tool IN LISTS tools )
    add_executable( ${tool} "samples/${tool}.cpp" )
    target_link_libraries( ${tool} PRIVATE raw )
endforeach()
target_link_libraries( unprocessed_raw PRIVATE ws2_32 )
add_executable( mem_image samples/mem_image_sample.cpp )
add_executable( dcraw_half samples/dcraw_half.c )
add_executable( half_mt samples/half_mt_win32.c )
foreach( tool mem_image dcraw_half half_mt )
    target_link_libraries( ${tool} PRIVATE raw )
endforeach()

install( TARGETS raw ${tools} mem_image dcraw_half half_mt )
install( DIRECTORY libraw/ DESTINATION include/libraw FILES_MATCHING PATTERN "*.h" )
