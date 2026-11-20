# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required( VERSION 3.27 )
project( lcms2 VERSION 2.14 LANGUAGES C )

find_package( JPEG REQUIRED )
find_package( TIFF REQUIRED )

# Core sources from upstream src/meson.build.
add_library( lcms2
    src/cmsalpha.c src/cmscam02.c src/cmscgats.c src/cmscnvrt.c
    src/cmserr.c src/cmsgamma.c src/cmsgmt.c src/cmshalf.c src/cmsintrp.c
    src/cmsio0.c src/cmsio1.c src/cmslut.c src/cmsmd5.c src/cmsmtrx.c
    src/cmsnamed.c src/cmsopt.c src/cmspack.c src/cmspcs.c src/cmsplugin.c
    src/cmsps2.c src/cmssamp.c src/cmssm.c src/cmstypes.c src/cmsvirt.c
    src/cmswtpnt.c src/cmsxform.c
)
target_include_directories( lcms2 PUBLIC include )
if( BUILD_SHARED_LIBS )
    target_sources( lcms2 PRIVATE src/lcms2.def )
    target_compile_definitions( lcms2 PRIVATE CMS_DLL_BUILD INTERFACE CMS_DLL )
endif()

add_library( lcms2_utils STATIC utils/common/vprf.c utils/common/xgetopt.c )
target_include_directories( lcms2_utils PUBLIC utils/common )
target_link_libraries( lcms2_utils PUBLIC lcms2 )
set( tools jpgicc linkicc psicc tificc transicc )
foreach( tool IN LISTS tools )
    add_executable( ${tool} "utils/${tool}/${tool}.c" )
    target_link_libraries( ${tool} PRIVATE lcms2_utils )
endforeach()
target_sources( jpgicc PRIVATE utils/jpgicc/iccjpeg.c )
target_link_libraries( jpgicc PRIVATE JPEG::JPEG )
target_link_libraries( tificc PRIVATE TIFF::TIFF )

install( TARGETS lcms2 ${tools} )
install( FILES include/lcms2.h include/lcms2_plugin.h DESTINATION include )
