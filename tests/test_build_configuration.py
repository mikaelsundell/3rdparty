# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

"""Fast regression checks: isolated CMake fixtures only, no dependency builds.

Run with: python3 -m unittest discover -s tests -v
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
CMAKE = shutil.which('cmake')


class BuildConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='3rdparty-config-test-')
        self.addCleanup(self.temp.cleanup)
        self.source = Path(self.temp.name) / 'source'
        self.source.mkdir()
        self.build = Path(self.temp.name) / 'build'
        helpers = self.source / 'src/cmake'
        helpers.mkdir(parents=True)
        shutil.copy(ROOT / 'src/cmake/buildutils.cmake', helpers)
        self.header = ('cmake_minimum_required(VERSION 3.27)\n'
                       'project(configuration_test LANGUAGES NONE)\n'
                       'include(src/cmake/buildutils.cmake)\n')

    def configure(self, body, *flags, success=True):
        project = self.source / 'CMakeLists.txt'
        contents = self.header + body
        if not project.exists() or project.read_text() != contents:
            project.write_text(contents)
        result = subprocess.run([CMAKE, '-S', str(self.source), '-B', str(self.build),
                                 '-G', 'Unix Makefiles', *flags], text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        self.assertEqual(result.returncode == 0, success, result.stdout)
        return result.stdout

    def test_package_switch_disables_subdirectory(self):
        package = self.source / 'package'
        package.mkdir()
        (package / 'CMakeLists.txt').write_text('message(FATAL_ERROR "package enabled")\n')
        self.configure('build_add_project(sample DIR "${CMAKE_SOURCE_DIR}/package" '
                       'DESCRIPTION sample BUILD ON)\n', '-Dsample=OFF')

    def test_dependency_validation_after_registration(self):
        self.configure('add_custom_target(consumer)\n'
                       'build_add_dependencies(consumer provider)\n'
                       'add_custom_target(provider)\n'
                       'build_validate_dependencies()\n')
        result = self.configure('add_custom_target(consumer)\n'
                                'build_add_dependencies(consumer provider)\n'
                                'build_validate_dependencies()\n', success=False)
        self.assertIn("consumer requires disabled or unavailable target 'provider'", result)
        self.assertIn('-Dprovider=ON', result)

    def test_python_two_digit_minor_and_library_file(self):
        module = self.source / 'FindPython3.cmake'
        module.write_text('set(Python3_EXECUTABLE /python)\n'
                          'set(Python3_VERSION_MAJOR 3)\nset(Python3_VERSION_MINOR 12)\n'
                          'set(Python3_INCLUDE_DIRS /include)\n'
                          'set(Python3_LIBRARIES /lib/libpython3.12.dylib)\n')
        self.configure('list(PREPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")\n'
                       'build_find_python3(executable version tag includes library)\n'
                       'if(NOT version STREQUAL "3.12" OR NOT tag STREQUAL "312"\n'
                       '   OR NOT library STREQUAL "/lib/libpython3.12.dylib")\n'
                       '  message(FATAL_ERROR "Python discovery mismatch")\nendif()\n')

    def test_recipe_flags_and_support_files_invalidate_outputs(self):
        writer = self.source / 'write.cmake'
        writer.write_text('file(WRITE "${OUT}" "${VALUE}")\n')
        body = ('set(value A CACHE STRING "fixture value")\n'
                'build_add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/result.txt"\n'
                ' COMMAND "${CMAKE_COMMAND}" "-DOUT=${CMAKE_BINARY_DIR}/result.txt"\n'
                ' "-DVALUE=${value}" -P "${CMAKE_SOURCE_DIR}/write.cmake")\n'
                'add_custom_target(fixture ALL DEPENDS "${CMAKE_BINARY_DIR}/result.txt")\n')
        def run():
            subprocess.run([CMAKE, '--build', str(self.build)], check=True,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = self.build / 'result.txt'
        for value in ('A', 'B', 'A'):
            self.configure(body, '-Dvalue=' + value)
            run()
            self.assertEqual(output.read_text(), value)
        timestamp = output.stat().st_mtime_ns
        self.configure(body, '-Dvalue=A')
        run()
        self.assertEqual(output.stat().st_mtime_ns, timestamp)
        # macOS make can compare timestamps at whole-second resolution.
        time.sleep(1.1)
        writer.write_text('file(WRITE "${OUT}" "updated ${VALUE}")\n')
        run()
        self.assertEqual(output.read_text(), 'updated A')

    def test_qt_configuration_for_new_and_reused_builds(self):
        script = (ROOT / 'build.sh').read_text()
        function = script[script.index('build_3rdparty() {'):script.index('\nbuild_clean()')]
        tools = Path(self.temp.name) / 'tools'
        tools.mkdir()
        log = Path(self.temp.name) / 'commands.log'
        for tool in ('cmake', 'make'):
            stub = tools / tool
            stub.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$TEST_LOG"\n')
            stub.chmod(0o755)
        environment = dict(os.environ, PATH=str(tools) + ':' + os.environ['PATH'],
                           TEST_LOG=str(log))
        for variant, config in (('debug', 'Debug'), ('release', 'Release')):
            for reused in (False, True):
                qt = self.source / 'qt/source'
                qt.mkdir(parents=True, exist_ok=True)
                build = qt / ('build.' + variant)
                if reused:
                    build.mkdir(exist_ok=True)
                elif build.exists():
                    shutil.rmtree(build)
                log.write_text('')
                subprocess.run(['bash', '-ec', function + '\nscript_dir="$1"\n'
                                'machine_arch=fixture\nqt_name=source\nmajor_version=12\n'
                                'build_3rdparty "$2"\n', 'test', str(self.source), variant],
                               env=environment, check=True, stdout=subprocess.PIPE)
                commands = log.read_text()
                self.assertIn('.. -U BUILD_qtmultimedia ', commands)
                self.assertNotIn('-DBUILD_qtmultimedia=OFF', commands)
                self.assertIn('--build . --config ' + config + ' --parallel', commands)
                self.assertIn('--install . --config ' + config, commands)


if __name__ == '__main__':
    unittest.main()
