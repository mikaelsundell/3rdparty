# <img src="images/icon.png" valign="middle" alt="Icon" width="50" height="50"> 3rdparty #

3rdparty library for development and packaging of color, film, and 3D applications, including pipelines and tools for OpenUSD, MaterialX, rendering, visualization, and digital content workflows.

![3rdparty.](images/image.png '3rdparty')

## 3rdparty consists of ##

3rdparty is a collection of scripts, configurations, and reference builds designed to simplify compiling third-party libraries on macOS from scratch. It focuses on providing:

* A curated set of libraries and tools commonly used in film, color science, and image processing.

* Build scripts and configuration presets that remove the need to understand each individual library’s build system in depth.

* Full control over each dependency, its version, and its configuration flags.

* Explicit macOS deployment targets and documented toolchain compatibility fixes.

## 3rdparty enables ##

With 3rdparty, you can:

* Build and manage only the libraries you need, with default or custom configurations.

* Reproduce consistent, isolated, and debuggable builds for development or production.

* Test new library versions ahead of official releases or platform adoption.

* Understand and customize the build process rather than relying on binaries.

## 3rdparty is not ##

3rdparty is not a package manager. It does not replace tools like Homebrew or MacPorts.

Instead, it complements them by offering a controlled, transparent, and reproducible build environment for developers who need to understand and influence how their dependencies are built.

It is intended for environments where reproducibility, version control, and configuration transparency matter—such as VFX pipelines, color workflows, and specialized media tools.

## 3rdparty build ##

### Install CMake ###

CMake version 3.27 or newer is required.

Install [CMake](https://cmake.org/), Xcode with its command-line tools, and a
Python 3 installation with development headers and libraries. `build.sh` checks
for NumPy, PyOpenGL, and `typing_extensions` (for Python older than 3.11). CMake
uses `FindPython3` to select a matching interpreter and development files;
`-DPython3_EXECUTABLE=/path/to/python3` can select an interpreter when configuring
the dependency project directly.

### Build 3rdparty on macOS ###
  
3rdparty is built using the ```build.sh``` script, which automates the compilation of all supported dependencies from source, including qt-everywhere-src-6.10.1 for UI/Toolkit support.

To build everything (Qt, libraries, debug and release variants) targeting macOS 12 and newer:

```shell
./build.sh all --target 12
```

Qt will be downloaded and built in ```qt``` and 3rdparty in ```build```. The deployment target defaults to macOS 12 and can be changed with `--target`. Build using arguments ```debug``` or ```release``` individually will not clean the build before starting.

```shell
./build.sh debug --target 12
./build.sh release --target 12
```

The script builds base dependencies, then Qt, then libraries and extras. `all`
asks whether to remove the existing `build` directory before starting. That
removes installed dependencies too; Qt source and build trees under `qt` remain.
The install prefixes on Apple Silicon are `build/macosx/arm64.debug` and
`build/macosx/arm64.release`.

### Build a selected library ###

Use `--project` to build a library and its declared dependencies:

```shell
./build.sh debug --project <library> --target 12
./build.sh release --project <library> --target 12
./build.sh all --project <library> --target 12
```

Replace `<library>` with its CMake target name, such as `openexr`, `ocio`, or
`opentimelineio`. `all` builds both Debug and Release.

`build.sh` starts the shared `build.py` driver. On macOS, the driver passes the
selected target to the Makefile through `MY_MAKE_FLAGS`. CMake resolves the
declared dependencies. Selected builds skip Qt, unrelated library targets, and
the full-build clean prompt. They use the normal
`build/macosx/<architecture>.debug` and `.release` directories. Pass
`--build-dir` to use a different build root for a selected build.
Package versions and source-specific changes are documented in [packages.txt](packages.txt).

### Build on Windows ###

The Windows driver builds the base dependencies, Qt 6.10.1, and the Windows
libraries and extras for x64 MSVC. The autotools projects are only built on
Unix.

Download the **Windows x86-64 executable installer** from the
[Python 3.9.0 release page](https://www.python.org/downloads/release/python-390/).
Choose **Customize installation**, then enable **Download debugging symbols**
and **Download debug binaries (requires VS 2017 or later)** under
**Advanced Options**. Keep the developer headers and libraries enabled. The
debug binaries include `python_d.exe`, `python39_d.dll`, and the
`libs\python39_d.lib` import library needed for native Debug Python builds.

Run `build.bat` from a regular Command Prompt. It finds Visual Studio or
Visual Studio Build Tools with the MSVC x64 C++ tools installed and sets up
the x64 build environment before starting `build.py`. An existing x64
developer prompt also works.
The build needs CMake 3.27 or newer, Ninja, Git, and `curl.exe` on `PATH` after setup.
The launcher selects Python 3.9 through `py.exe -3.9`, the standard
per-user installation, or a Python 3.9 interpreter on `PATH`.

A full Windows build or an OpenUSD-only build checks for PyOpenGL (imported
as `OpenGL`) and Jinja2 (imported as `jinja2`) before starting. OpenUSD uses
PyOpenGL for `usdview` and Jinja2 for schema generation tools. Install the
packages with the interpreter for each configuration you plan to build. To
prepare both configurations in PowerShell, run these commands:

```powershell
$python39 = py.exe -3.9 -c "import sys; print(sys.base_prefix)"
& (Join-Path $python39 'python.exe') -m pip install PyOpenGL Jinja2
& (Join-Path $python39 'python_d.exe') -m pip install PyOpenGL Jinja2
```

If you use a Python installation without `py.exe`, set `$python39` to its
installation directory. Qt-only, base-only, and other selected library builds
can run without these two packages.

```bat
build.bat all
build.bat debug
build.bat release
build.bat all --base-only
build.bat debug --project qt
build.bat debug --project boost
```

The common SDK root is `build\win`, with separate `x64.debug` and
`x64.release` prefixes. `--project qt` builds the Qt prerequisites and Qt.
Other selected targets build only their CMake prerequisites. For PySide or
OpenUSD, install Qt with the same configuration and build root first.
The Debug Qt prefix includes the Release Qt tools, including `moc.exe`.
Windows Qt Multimedia uses the native Windows backend.
The Windows ports of FFmpeg, x264, OpenCV, and NanoGUI are pending.

The Windows LLVM build caps Ninja at four concurrent compile jobs and one
link job to limit memory pressure. To resume an interrupted Debug LLVM build
in the existing prefix, run `build.bat debug --project llvm`.

Use the selected prefix as `CMAKE_PREFIX_PATH` for consumers of
`find_package(Imath CONFIG REQUIRED)`, and add its `bin` directory to
`PATH` when running programs linked to the Imath DLL. Each prefix also
contains the headers, import libraries, and CMake and pkg-config metadata.
Boost, Ptex, and OpenUSD install DLLs under `lib`. Add that directory to
`PATH` when running programs linked to those DLLs. Use `python_d.exe` with extensions
from the Debug prefix and `python.exe` with extensions from the Release
prefix. OpenEXR's Python module requires NumPy for the selected interpreter.
When importing extensions directly from the prefix, use
`os.add_dll_directory()` with the absolute paths of the prefix's runtime DLL directories.
Use `--build-dir` to choose a different build root for a fresh build.

#### Windows SDK shell ####

Double-click `tools\3rdparty-shell.bat` to open a new Command Prompt for the
Debug SDK. For the Release SDK, run `tools\3rdparty-shell.bat release`.
The shell opens at the repository root with the selected prefix's executables
and DLLs on `PATH` and its Python modules registered. `python` starts the
matching Python 3.9 interpreter. For example:

```bat
python -c "from pxr import Tf; print(Tf.__file__)"
usdcat --help
ninja --version
```

Use `call python` inside batch files, or invoke `"%THIRDPARTY_PYTHON%"`
directly to use the selected Python executable. Commands and modules are
available once their packages have been built into that prefix.

### Qt compiler compatibility ###

`build.sh` applies `src/scripts/patch_qt.py` to fresh and reused Qt 6.10.1 source
trees. The patch includes `<arm_acle.h>` on ARM so AppleClang 21 can compile Qt's
`__yield()` intrinsic. It can also be run manually as shown above and is safe to
repeat.

Qt is configured with `FEATURE_dup3=OFF` so its child processes work on macOS
versions before 27. Reused Qt build trees are reconfigured. Qt's Ninja defaults
build and install both framework configurations, including its Release tools,
into the selected prefix. PySide uses the installed
Clang for header discovery; `build.sh` exports the active SDK as `SDKROOT`.

Qt 6.10.1 reports that SDK 27 exceeds its tested SDK version. The header patch
fixes the observed compiler error; it does not establish compatibility with the
entire SDK. The full Qt build with this toolchain still needs validation.

### Debug Qt with 3rdparty ###

When using a Qt framework containing a `_debug` binary, set `DYLD_IMAGE_SUFFIX`
to `_debug` to load it. The selected framework must actually contain that binary;
a directory named `arm64.debug` alone does not establish its build configuration.

```
DYLD_IMAGE_SUFFIX=_debug
```

### Deploy with 3rdparty ###

Each project is installed with absolute search paths for all names and dependent libraries. The 3rdparty project is not intended for instant deployment but instead requires a deployment step, such as macdeployqt or a similar tool, to correctly configure ```@rpath```, ```@executable_path```, and other runtime application dependencies.

## 3rdparty advanced ##

The 3rdparty project can be built from the top directory by typing 
make. Advanced users can use CMake directly, see CMakeLists.txt.

The build directory contains platform, architecture and debug or 
release versions of projects. After each successful
build binaries, libraries and related files will be installed with
absolute install names.

Each application using the 3rdparty project should have it's own
deployment process to remap install names before distribution.

## CMake configuration ##

Add cmake to path

```shell
export PATH=$PATH:/Applications/CMake.app/Contents/bin
```

## Build configuration ##

Useful make commands

```shell
make                      Build enabled dependency groups (base only in a fresh cache).
make debug                Build all projects with debugging symbols when possible.
make clean                Remove the entire build directory, including installed files.
make help                 Print all the make options
```

Additionally, a few helpful modifiers

```shell
make verbose=1 ...        Enable verbose CMake makefiles
make build_base=1 ...     Enable base dependencies
make build_libs=1 ...     Enable libraries
make build_extras=1 ...   Enable extras (also requires base and libraries)
```

Individual packages can be disabled with CMake cache options, for example
`-Dlibpng=OFF`. Enabled packages require their dependency targets: enable the
corresponding groups (`build_base`, `build_libs`, `build_extras`) and package
options, or disable the dependent package. Configuration reports missing targets.
The Eigen package option is named `eigen3`.

Dependency recipes normally build when their declared installed outputs are
missing; specific recipes may also declare explicit file dependencies.
Changing flags or recipe commands alone does not force a reinstall; rebuild
those outputs manually when required. The top-level project and most dependency
recipes still use Make;
Qt and PySide use Ninja. Static-library builds have not been repaired or validated
as part of these changes.


## Current release ##

MacOS Tahoe v26.0.1  

Release page:   
https://github.com/mikaelsundell/3rdparty/releases/tag/macOS_Tahoe_v26.0.1

System configuration for this published release (not the current build host):
```
Darwin Kernel Version 25.0.0: Wed Sep 17 21:41:45 PDT 2025; root:xnu-12377.1.9~141/RELEASE_ARM64_T6000 arm64
Apple clang version 17.0.0 (clang-1700.3.19.1)
Target: arm64-apple-darwin25.0.0

Xcode 26.0.1
Build version 17A400
```
Commands used:   
```shell
uname -a
clang --version
xcodebuild -version
```

Note: Earlier macOS builds were not tagged individually; version tagging began with macOS updates starting from v26.0.1.

## Github ##

  * Project  https://github.com/mikaelsundell/3rdparty
  * Issues   https://github.com/mikaelsundell/3rdparty/issues

## Contact ##

Mikael Sundell - mikael.sundell@gmail.com

## License ##

The build scripts and configuration files in this repository are licensed under
[BSD-3-Clause](LICENSE). Third-party dependencies and artwork retain their
own licenses and copyright notices.

See [Third-party notices](THIRD_PARTY_NOTICES.md) for the dependency source
snapshots, verbatim notice copies, and items that still need verification. The
[notice manifest](licenses/manifest.json) records provenance and checksums.
Upstream copyright years are preserved from the source distributions.
