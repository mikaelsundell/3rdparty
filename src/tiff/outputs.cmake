# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

if( WIN32 )
    set( bin_files
        bmp2tiff fax2tiff fax2ps gif2tiff pal2rgb ppm2tiff ras2tiff
        raw2tiff rgb2ycbcr thumbnail tiff2bw tiff2pdf tiff2ps tiff2rgba
        tiffcmp tiffcp tiffcrop tiffdither tiffdump tiffinfo tiffmedian tiffset tiffsplit
    )
else()
    # bin files
    set( bin_files
        bmp2tiff
        fax2tiff
        fax2ps
        gif2tiff
        pal2rgb
        ppm2tiff
        ras2tiff
        raw2tiff
        rgb2ycbcr
        tiff2bw
        tiff2pdf
        tiff2ps
        tiff2rgba
        tiffcmp
        tiffcp
        tiffdither
        tiffdump
        tiffinfo
        tiffmedian
        tiffset
        tiffsplit
        thumbnail
    )
endif()
