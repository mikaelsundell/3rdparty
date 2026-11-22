# SPDX-License-Identifier: BSD-3-Clause

import importlib
import sys


def main():
    sys.path.insert(0, sys.argv[1])
    missing = []
    for module, package in (("OpenGL", "PyOpenGL"), ("jinja2", "Jinja2")):
        try:
            importlib.import_module(module)
        except (ImportError, OSError) as error:
            print(f"OpenUSD requires {package} for {sys.executable}: {error}", file=sys.stderr)
            missing.append(package)

    if missing:
        executable = sys.executable.replace("'", "''")
        print(f"Install the missing packages in PowerShell with:\n"
              f"  & '{executable}' -m pip install {' '.join(missing)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
