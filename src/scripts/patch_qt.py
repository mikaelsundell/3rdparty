#!/usr/bin/env python3
# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

"""Apply the Qt 6.10.1 ARM compiler compatibility fix, idempotently."""
from pathlib import Path
import sys


def patch_qt(source):
    header = Path(source) / 'qtbase/src/corelib/thread/qyieldcpu.h'
    original = '#include <QtCore/qtconfigmacros.h>\n'
    patched = original + '''
#if defined(Q_PROCESSOR_ARM) && __has_include(<arm_acle.h>)
#  include <arm_acle.h>
#endif
'''
    text = header.read_text()
    if patched in text:
        return
    if text.count(original) != 1:
        raise RuntimeError('Unexpected Qt qyieldcpu.h layout; review the ARM header patch')
    header.write_text(text.replace(original, patched, 1))
    print('Patched Qt qyieldcpu.h to include ARM intrinsic declarations')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('Usage: patch_qt.py <qt-source-directory>')
    patch_qt(sys.argv[1])
