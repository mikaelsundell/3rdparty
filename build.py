#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause

import argparse
import importlib
import os
from pathlib import Path
import platform
import shlex
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent
QT_PACKAGE = "qt-everywhere-src-6.10.1"
QT_MODULES = (
    "qtbase", "qt3d", "qthttpserver", "qtimageformats", "qtmultimedia",
    "qtnetworkauth", "qtpositioning", "qtscxml", "qtserialport",
    "qtshadertools", "qtsvg", "qttools", "qttranslations", "qtwebsockets",
)


def check_macos_python(project):
    requirements = []
    if project is None or project in (
        "boost", "openexr", "ocio", "oiio", "opencv", "materialx", "openusd",
    ):
        requirements.append(("numpy", "numpy"))
    if project is None or project == "openusd":
        requirements.extend((("OpenGL", "PyOpenGL"), ("jinja2", "Jinja2")))
    if project is None or project in ("pyside", "openusd"):
        if sys.version_info < (3, 11):
            requirements.append(("typing_extensions", "typing_extensions"))
    if project is None or project == "opentimelineio":
        requirements.append(("setuptools", "setuptools"))
    missing = []
    for module, package in requirements:
        try:
            importlib.import_module(module)
        except (ImportError, OSError) as error:
            print(f"{package} is required for {sys.executable}: {error}", file=sys.stderr)
            missing.append(package)
    if missing:
        raise SystemExit("Install the missing Python packages with:\n  " +
                         shlex.join([sys.executable, "-m", "pip", "install", *missing]))


def build_macos(args, configurations, parser):
    for tool in ("cmake", "make", "xcrun", "curl"):
        if not shutil.which(tool):
            parser.error(f"{tool} is required on PATH")

    env = os.environ.copy()
    deployment_target = args.target or "12"
    env["MACOSX_DEPLOYMENT_TARGET"] = deployment_target
    env["CMAKE_OSX_DEPLOYMENT_TARGET"] = deployment_target
    env["SDKROOT"] = subprocess.check_output(
        ["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True
    ).strip()
    check_macos_python("boost" if args.base_only else args.project)

    build_dir = args.build_dir.resolve() if args.build_dir is not None else ROOT / "build"
    # Preserve the full-build clean choice; selected and base-only builds resume.
    if args.configuration == "all" and args.project is None and not args.base_only and build_dir.exists():
        answer = input(f"Remove existing build directory {build_dir}? (y/N): ") if sys.stdin.isatty() else "n"
        if answer.lower() in ("y", "yes"):
            if build_dir == ROOT or build_dir in ROOT.parents:
                parser.error("the build directory must not contain the source tree")
            shutil.rmtree(build_dir)

    # An SDK shell exposes its LLVM tools for consumers. Dependency builds
    # must still select the system compiler unless CC/CXX explicitly override it.
    if env.get("THIRDPARTY_PREFIX"):
        sdk_bin = (Path(env["THIRDPARTY_PREFIX"]) / "bin").resolve()
        env["PATH"] = os.pathsep.join(
            entry for entry in env["PATH"].split(os.pathsep)
            if Path(entry).resolve() != sdk_bin
        )

    ninja = shutil.which("ninja", path=env["PATH"])
    if not ninja or Path(ninja).resolve().is_relative_to(build_dir.resolve()):
        # Bootstrap the existing recipe with Make before configuring Ninja builds.
        # Keep this host tool outside SDK prefixes so installing Ninja cannot
        # overwrite the executable currently running a package build.
        tools_prefix = build_dir / "tools"
        print("Preparing Ninja with Make", flush=True)
        configure_dependencies(
            tools_prefix, "release", package_groups=False, env=env,
            generator="Unix Makefiles",
        )
        build_target(tools_prefix, "ninja", env=env)
        env["PATH"] = os.pathsep.join((str(tools_prefix / "ninja"), env["PATH"]))

    print(f"Building 3rdparty for {args.configuration}; macOS deployment target: {deployment_target}", flush=True)
    build_configurations(args, configurations, build_dir, "macosx", platform.machine(), env)


def build_configurations(args, configurations, build_dir, system, architecture, env=None):
    for configuration in configurations:
        prefix = build_dir / system / f"{architecture}.{configuration}"
        if system == "macosx":
            env = env.copy()
            # Shell setup may put the other configuration's tools on PATH.
            # Keep the system compiler first and use this prefix's pkg-config.
            package_bins = {
                (root / system / f"{architecture}.{variant}" / "bin").resolve()
                for root in (ROOT / "build", build_dir)
                for variant in ("debug", "release")
            }
            env["PATH"] = os.pathsep.join([
                *[entry for entry in env["PATH"].split(os.pathsep)
                  if Path(entry).resolve() not in package_bins],
                str(prefix / "bin"),
            ])
            env["CMAKE_PREFIX_PATH"] = str(prefix)
            env["PKG_CONFIG_PATH"] = os.pathsep.join([
                str(prefix / "lib/pkgconfig"), str(prefix / "share/pkgconfig"),
            ])
        configure_dependencies(
            prefix, configuration, package_groups=args.project not in (None, "qt"),
            qt_prerequisites=args.project == "qt", env=env,
        )
        if args.project == "qt":
            build_target(prefix, "qt-prerequisites", env=env)
            build_qt(prefix, configuration, env=env)
        else:
            build_target(prefix, args.project, env=env)
            if not args.project and not args.base_only:
                build_qt(prefix, configuration, env=env)
                configure_dependencies(prefix, configuration, package_groups=True, env=env)
                build_target(prefix, env=env)


def build_qt(prefix, configuration, env=None):
    windows = sys.platform == "win32"
    qt_dir = ROOT / "qt"
    qt_dir.mkdir(exist_ok=True)
    source = qt_dir / QT_PACKAGE
    if not (source / "CMakeLists.txt").is_file():
        archive = qt_dir / f"{QT_PACKAGE}.tar.xz"
        if not archive.is_file():
            partial = archive.with_suffix(".xz.part")
            subprocess.run([
                "curl.exe" if windows else "curl", "--fail", "--location", "--output", str(partial),
                f"https://mikaelsundell.s3.eu-west-1.amazonaws.com/3rdparty/{archive.name}",
            ], check=True)
            partial.replace(archive)
        subprocess.run(["cmake", "-E", "tar", "xf", str(archive)], cwd=qt_dir, check=True)

    if not windows:
        subprocess.run([sys.executable, str(ROOT / "src/scripts/patch_qt.py"), str(source)], check=True, env=env)
    # Keep existing Mac Qt build trees so interrupted builds can resume.
    qt_build = prefix / "qt" if windows else source / f"build.{configuration}"
    if not windows and prefix.parent.parent != ROOT / "build":
        qt_build = prefix / "qt"
    env = (env or os.environ).copy()
    # Mac Qt must keep the system compiler ahead of the installed LLVM tools.
    paths = [str(prefix / "ninja")]
    if windows:
        paths.append(str(prefix / "bin"))
    env["PATH"] = os.pathsep.join((*paths, env["PATH"]))
    if windows:
        qt_configs = "Release;Debug" if configuration == "debug" else "Release"
        excluded_modules = [
            f"-DBUILD_{module.name}=OFF"
            for module in sorted(source.glob("qt*"))
            if module.name not in QT_MODULES and (module / "CMakeLists.txt").is_file()
        ]
        options = [
            f"-DCMAKE_CONFIGURATION_TYPES={qt_configs}",
            f"-DQT_BUILD_SUBMODULES={';'.join(QT_MODULES)}",
            "-DQT_BUILD_TESTS=OFF", "-DQT_BUILD_EXAMPLES=OFF",
            *excluded_modules,
            "-DQT_FEATURE_system_png=ON", "-DQT_FEATURE_system_jpeg=ON",
            "-DQT_FEATURE_system_freetype=OFF", "-DQT_FEATURE_system_zlib=ON",
            "-DQT_FEATURE_ffmpeg=OFF", "-DQT_FEATURE_native_windows_backend=ON",
            "-DQT_FEATURE_spatialaudio_quick3d=OFF",
            "-DQT_FEATURE_scxml_qml=OFF", "-DQT_FEATURE_scxml_ecmascriptdatamodel=OFF",
            "-DQT_FEATURE_statemachine_qml=OFF",
        ]
    else:
        excluded = (
            "qtactiveqt", "qtcharts", "qtcoap", "qtconnectivity", "qtdeclarative",
            "qtdoc", "qtgraphs", "qtharfbuzz", "qtlocation", "qtlottie", "qtmqtt",
            "qtopcua", "qtquick3d", "qtquick3dphysics", "qtquicktimeline",
            "qtquickeffectmaker", "qtremoteobjects", "qtsensors", "qtserialbus",
            "qtspeech", "qtvirtualkeyboard", "qtwayland", "qtwebchannel",
            "qtwebengine", "qtwebview",
        )
        options = [
            *[f"-DBUILD_{module}=OFF" for module in excluded],
            "-DFEATURE_dup3=OFF", "-DQT_FEATURE_system_freetype=ON",
            "-DQT_FEATURE_system_zlib=ON",
            f"-DCMAKE_OSX_DEPLOYMENT_TARGET={env['MACOSX_DEPLOYMENT_TARGET']}",
            f"-DCMAKE_OSX_SYSROOT={env['SDKROOT']}",
        ]
    subprocess.run([
        "cmake", "-S", str(source), "-B", str(qt_build), "-G", "Ninja Multi-Config",
        f"-DCMAKE_INSTALL_PREFIX={prefix.as_posix()}",
        f"-DCMAKE_PREFIX_PATH={prefix.as_posix()}", *options,
    ], env=env, check=True)
    subprocess.run(["cmake", "--build", str(qt_build), "--parallel"], env=env, check=True)
    subprocess.run(["cmake", "--build", str(qt_build), "--target", "install"], env=env, check=True)

    required = [
        "bin/moc.exe", "bin/Qt6Core.dll",
        "lib/cmake/Qt6/Qt6Config.cmake", "lib/cmake/Qt6Core/Qt6CoreConfig.cmake",
        "lib/cmake/Qt6Multimedia/Qt6MultimediaConfig.cmake",
    ]
    if windows and configuration == "debug":
        required.append("bin/Qt6Cored.dll")
    if not windows:
        required = [
            "libexec/moc", "lib/cmake/Qt6/Qt6Config.cmake",
            "lib/cmake/Qt6Core/Qt6CoreConfig.cmake",
            "lib/cmake/Qt6Multimedia/Qt6MultimediaConfig.cmake",
            "lib/QtCore.framework/Versions/A/QtCore",
            "lib/QtCore.framework/Versions/A/QtCore_debug",
        ]
    for relative in required:
        if not (prefix / relative).is_file():
            raise SystemExit(f"Qt installation is missing {prefix / relative}")


def configure_dependencies(prefix, configuration, package_groups, qt_prerequisites=False, env=None, generator="Ninja"):
    windows = sys.platform == "win32"
    groups = "ON" if package_groups else "OFF"
    if windows:
        options = [f"-Dbuild_python_root={Path(sys.base_prefix).as_posix()}"]
    else:
        options = [
            "-DCMAKE_VERBOSE_MAKEFILE=ON",
            f"-DCMAKE_OSX_DEPLOYMENT_TARGET={env['MACOSX_DEPLOYMENT_TARGET']}",
        ]
    subprocess.run([
        "cmake", "-S", str(ROOT), "-B", str(prefix), "-G", generator,
        f"-DCMAKE_BUILD_TYPE={configuration.capitalize()}",
        f"-DCMAKE_INSTALL_PREFIX={prefix.as_posix()}",
        f"-DPython3_EXECUTABLE={Path(sys.executable).as_posix()}",
        *options,
        "-Dbuild_base=ON", f"-Dbuild_libs={groups}", f"-Dbuild_extras={groups}",
        f"-Dbuild_qt_prerequisites={'ON' if qt_prerequisites else 'OFF'}",
    ], env=env, check=True)


def build_target(prefix, target=None, env=None):
    command = ["cmake", "--build", str(prefix)]
    # Package recipes manage their own compiler jobs.
    command.extend(("--parallel", "2" if sys.platform == "win32" else "1"))
    if target:
        command.extend(("--target", target))
    subprocess.run(command, env=env, check=True)


def build_windows(args, configurations, parser):
    if args.target is not None:
        parser.error("--target sets the macOS deployment target")
    if sys.version_info[:2] != (3, 9):
        parser.error("Python 3.9 is required for the Windows build")
    if os.environ.get("VSCMD_ARG_TGT_ARCH", "").lower() != "x64" or not shutil.which("cl.exe"):
        parser.error("run from an x64 Visual Studio developer command prompt")
    for tool in ("cmake.exe", "ninja.exe", "curl.exe"):
        if not shutil.which(tool):
            parser.error(f"{tool} is required on PATH")

    build_dir = args.build_dir.resolve() if args.build_dir is not None else ROOT / "build"
    if not args.base_only and args.project in (None, "openusd"):
        for configuration in configurations:
            python_name = "python_d.exe" if configuration == "debug" else "python.exe"
            python = Path(sys.base_prefix) / python_name
            if not python.is_file():
                raise SystemExit(f"OpenUSD requires the selected Windows Python interpreter at {python}")
            site_packages = build_dir / "win" / f"x64.{configuration}" / "site-packages"
            subprocess.run([
                str(python), "-B", str(ROOT / "src/scripts/check_openusd_python.py"),
                str(site_packages),
            ], check=True)

    build_configurations(args, configurations, build_dir, "win", "x64")


def main():
    parser = argparse.ArgumentParser(description="Build 3rdparty dependencies on macOS or Windows.")
    parser.add_argument("configuration", choices=("debug", "release", "all"))
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--project", metavar="TARGET", help="build a selected target")
    selection.add_argument("--base-only", action="store_true", help="build only the base dependencies")
    parser.add_argument("--target", metavar="VERSION", help="macOS deployment target (default: 12)")
    parser.add_argument("--build-dir", type=Path, help="override the root build directory")
    args = parser.parse_args()
    if args.project is not None and (not args.project or args.project.startswith("-")):
        parser.error("--project requires a CMake target name")

    configurations = ("debug", "release") if args.configuration == "all" else (args.configuration,)
    if sys.platform == "darwin":
        build_macos(args, configurations, parser)
    elif sys.platform == "win32":
        build_windows(args, configurations, parser)
    else:
        parser.error("the build driver supports macOS and Windows")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
