#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause

import argparse
import os
from pathlib import Path
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


def build_macos(args, configurations, parser):
    if not shutil.which("cmake"):
        parser.error("CMake is required on PATH. Run through build.sh to use CMake.app.")
    if args.build_dir is not None and not args.project:
        parser.error("--build-dir on macOS requires --project during the build driver migration")

    deployment_target = args.target or "12"
    env = os.environ.copy()
    env["MACOSX_DEPLOYMENT_TARGET"] = deployment_target
    env["CMAKE_OSX_DEPLOYMENT_TARGET"] = deployment_target
    env["SDKROOT"] = subprocess.check_output(
        ["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True
    ).strip()

    if not args.project:
        subprocess.run(
            ["/bin/bash", str(ROOT / "src/scripts/build_macos_full.sh"), args.configuration],
            cwd=ROOT, env=env, check=True,
        )
        return

    command = [
        "make", "verbose=1", "build_base=1", "build_libs=1", "build_extras=1",
        f"MY_MAKE_FLAGS={shlex.quote(args.project)}",
    ]
    if args.build_dir is not None:
        command.append(f"build_dir={args.build_dir.resolve()}")
    for configuration in configurations:
        subprocess.run([*command, configuration], cwd=ROOT, env=env, check=True)


def build_qt_windows(prefix, configuration):
    qt_dir = ROOT / "qt"
    qt_dir.mkdir(exist_ok=True)
    source = qt_dir / QT_PACKAGE
    if not (source / "CMakeLists.txt").is_file():
        archive = qt_dir / f"{QT_PACKAGE}.tar.xz"
        if not archive.is_file():
            partial = archive.with_suffix(".xz.part")
            subprocess.run([
                "curl.exe", "--fail", "--location", "--output", str(partial),
                f"https://mikaelsundell.s3.eu-west-1.amazonaws.com/3rdparty/{archive.name}",
            ], check=True)
            partial.replace(archive)
        subprocess.run(["cmake", "-E", "tar", "xf", str(archive)], cwd=qt_dir, check=True)

    qt_build = prefix / "qt"
    env = os.environ.copy()
    env["PATH"] = os.pathsep.join((str(prefix / "ninja"), str(prefix / "bin"), env["PATH"]))
    qt_configs = "Release;Debug" if configuration == "debug" else "Release"
    excluded_modules = [
        f"-DBUILD_{module.name}=OFF"
        for module in sorted(source.glob("qt*"))
        if module.name not in QT_MODULES and (module / "CMakeLists.txt").is_file()
    ]
    subprocess.run([
        "cmake", "-S", str(source), "-B", str(qt_build), "-G", "Ninja Multi-Config",
        f"-DCMAKE_INSTALL_PREFIX={prefix.as_posix()}",
        f"-DCMAKE_PREFIX_PATH={prefix.as_posix()}",
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
    ], env=env, check=True)
    subprocess.run(["cmake", "--build", str(qt_build)], env=env, check=True)
    subprocess.run(["cmake", "--build", str(qt_build), "--target", "install"], env=env, check=True)

    required = [
        "bin/moc.exe", "bin/Qt6Core.dll",
        "lib/cmake/Qt6/Qt6Config.cmake", "lib/cmake/Qt6Core/Qt6CoreConfig.cmake",
        "lib/cmake/Qt6Multimedia/Qt6MultimediaConfig.cmake",
    ]
    if configuration == "debug":
        required.append("bin/Qt6Cored.dll")
    for relative in required:
        if not (prefix / relative).is_file():
            raise SystemExit(f"Qt installation is missing {prefix / relative}")


def configure_windows(prefix, configuration, package_groups, qt_prerequisites=False):
    groups = "ON" if package_groups else "OFF"
    subprocess.run([
        "cmake", "-S", str(ROOT), "-B", str(prefix), "-G", "Ninja",
        f"-DCMAKE_BUILD_TYPE={configuration.capitalize()}",
        f"-DCMAKE_INSTALL_PREFIX={prefix.as_posix()}",
        f"-DPython3_EXECUTABLE={Path(sys.executable).as_posix()}",
        f"-Dbuild_python_root={Path(sys.base_prefix).as_posix()}",
        "-Dbuild_base=ON", f"-Dbuild_libs={groups}", f"-Dbuild_extras={groups}",
        f"-Dbuild_qt_prerequisites={'ON' if qt_prerequisites else 'OFF'}",
    ], check=True)


def build_windows_target(prefix, target=None):
    command = ["cmake", "--build", str(prefix), "--parallel", "2"]
    if target:
        command.extend(("--target", target))
    subprocess.run(command, check=True)


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

    for configuration in configurations:
        prefix = build_dir / "win" / f"x64.{configuration}"
        configure_windows(
            prefix, configuration,
            package_groups=args.project not in (None, "qt"),
            qt_prerequisites=args.project == "qt",
        )

        if args.project == "qt":
            build_windows_target(prefix, "qt-prerequisites")
            build_qt_windows(prefix, configuration)
        else:
            build_windows_target(prefix, args.project)
            if not args.project and not args.base_only:
                build_qt_windows(prefix, configuration)
                configure_windows(prefix, configuration, package_groups=True)
                build_windows_target(prefix)


def main():
    parser = argparse.ArgumentParser(description="Build 3rdparty dependencies on macOS or Windows.")
    parser.add_argument("configuration", choices=("debug", "release", "all"))
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--project", metavar="TARGET", help="build a selected target")
    selection.add_argument("--base-only", action="store_true", help="build only the Windows base dependencies")
    parser.add_argument("--target", metavar="VERSION", help="macOS deployment target (default: 12)")
    parser.add_argument("--build-dir", type=Path, help="override the root build directory")
    args = parser.parse_args()
    if args.project is not None and (not args.project or args.project.startswith("-")):
        parser.error("--project requires a CMake target name")

    configurations = ("debug", "release") if args.configuration == "all" else (args.configuration,)
    if sys.platform == "darwin":
        if args.base_only:
            parser.error("--base-only currently requires Windows")
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
