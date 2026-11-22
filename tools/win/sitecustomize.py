# SPDX-License-Identifier: BSD-3-Clause
"""Register the SDK DLL directories in Python subprocesses of the shell."""

import os


# CPython removes a directory from its DLL search path when its handle closes.
_dll_directory_handles = [
    os.add_dll_directory(directory)
    for directory in os.environ.get("THIRDPARTY_DLL_DIRS", "").split(os.pathsep)
    if os.name == "nt" and os.path.isdir(directory)
]
