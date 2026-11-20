# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( jpeg VERSION 9.6 LANGUAGES C )

# Match upstream makefile.vc, using its virtual-memory backend and config.
configure_file( jconfig.vc jconfig.h COPYONLY )
include_directories( "${CMAKE_CURRENT_BINARY_DIR}" )

add_library( jpeg
    jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c
    jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c
    jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c
    jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c
    jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c
    jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c
    jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jquant1.c
    jquant2.c jutils.c jmemmgr.c jmemnobs.c
)
set_target_properties( jpeg PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON )

add_executable( cjpeg cjpeg.c rdppm.c rdgif.c rdtarga.c rdrle.c rdbmp.c rdswitch.c cdjpeg.c )
add_executable( djpeg djpeg.c wrppm.c wrgif.c wrtarga.c wrrle.c wrbmp.c rdcolmap.c cdjpeg.c )
add_executable( jpegtran jpegtran.c rdswitch.c cdjpeg.c transupp.c )
foreach( tool cjpeg djpeg jpegtran )
    target_link_libraries( ${tool} PRIVATE jpeg )
endforeach()
add_executable( rdjpgcom rdjpgcom.c )
add_executable( wrjpgcom wrjpgcom.c )

install( TARGETS jpeg cjpeg djpeg jpegtran rdjpgcom wrjpgcom )
install( FILES "${CMAKE_CURRENT_BINARY_DIR}/jconfig.h" jerror.h jmorecfg.h jpeglib.h DESTINATION include )
