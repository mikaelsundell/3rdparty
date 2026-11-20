# Working on 3rdparty

## Build entry points

- Use `build.sh` on macOS or `build.bat` on Windows to start `build.py`.
  During the migration, macOS still uses the root `Makefile` to configure CMake
  and invoke its generated Makefiles. Windows uses CMake with Ninja.
- Use `MY_MAKE_FLAGS` to select a generated target. Keep prerequisite edges in
  `build_add_dependencies`; do not duplicate the dependency graph in `build.sh`.
- Use the normal `build/macosx/<architecture>.debug` and `.release` directories.
  Do not introduce an alternative permanent build layout for selected projects.
- A selected library build must skip Qt and unrelated package targets.
- Keep Qt's default Ninja Multi-Config build/install targets. Its Release tools,
  including moc, must be installed even in the Debug prefix. Validate changes to
  this flow with an AUTOMOC consumer of the installed Qt package.
- Stop the full build if Qt configuration, compilation, or installation fails.
  PySide must use Qt installed in its selected Debug or Release prefix; do not
  allow a missing installation to fall back to the other prefix.

## macOS migration handoff

- The Windows port and shared-recipe refactor are in place. Selected Windows
  x64 Debug and Release installs and an installed-Qt AUTOMOC consumer passed.
  The macOS recipe branches were checked through generated-rule comparisons
  on Windows. Native macOS builds are still pending.
- Establish a native baseline before replacing the root Makefile. Start with
  fresh selected Debug and Release builds of `json` for the shared CMake flow,
  `libpng` for Autotools and Mach-O install handling, and `opentimelineio` for
  C++ and Python installation with prerequisites. Use `--build-dir` with
  selected targets to keep validation separate from existing installs.
- The selected macOS path is `build.sh → build.py → Makefile`. The full path
  calls `src/scripts/build_macos_full.sh` from `build.py` and builds base
  dependencies, Qt, then libraries and extras. Preserve that order and the
  current prefixes when moving orchestration into the shared driver. Validate
  Qt's installed package with AUTOMOC and confirm PySide uses the matching
  prefix before removing the legacy entry points.

## Cross-platform recipe style

Apply this structure to every project recipe. Use `src/libpng/CMakeLists.txt`
as the model when the build commands differ by platform and
`src/json/CMakeLists.txt` when the full build sequence can be shared.

- Keep one recipe with shared project metadata, installed-output declarations,
  options, archive rule, target, and prerequisite edges wherever they agree.
  Reuse `build_cmake_commands` for matching CMake workflows and
  `build_add_archive_rule` when it can preserve the existing install sequence.
- Put platform conditions next to the settings they select, such as output
  names, patches, configure options, or build commands. Group declarations under
  short section comments and use the same spacing and multiline list formatting
  on both platforms. Keep each branch focused on what differs. Combine adjacent
  platform branches when there is no shared work between them.
- Move long filename lists into sibling `outputs.cmake` or
  `outputs-unix.cmake` files. Keep short lists and the output helpers in the
  recipe. Use an upstream install manifest to verify the explicit lists
  against a clean install in the same platform and configuration.
- Preserve existing functionality as recipes are consolidated. Check the build
  tool and command order, flags, patches, prerequisites, install paths and
  outputs, and post-install scripts for each platform. Keep distinct workflows
  such as Unix Autotools and Windows CMake where the package requires them.
  Compare the generated rules before and after, then validate fresh Debug and
  Release installs on the affected platforms. Report any platform that could
  only be checked at configuration time.

## Adding or changing a library

1. Read the closest existing recipes before editing. Follow their section order,
   spacing, variable names, and configure/make/install structure. `src/imath`,
   `src/pybind`, and `src/alembic` are examples; the three OTIO-related recipes
   also demonstrate package-output tracking.
2. Reuse `project_name`, `project_pkg`, `project_arc`, `project_url`,
   `project_src_dir`, `project_bin_dir`, `build_options`, `build_config`,
   `build_make`, and the existing output variables. Do not add parallel recipe
   APIs, download frameworks, staging systems, or package-specific CMake styles.
3. Download with `${download}` and extract with `${untar}`. Inspect the archive's
   actual source-root name; it may differ from its filename. For Unix CMake
   builds, configure from the extracted source's `${build_cmake}` directory
   using the established
   `${build_env} && cd ... && mkdir -p ... && cd ... && cmake ... && make ... &&
   make install` sequence in `build_make`.
4. Forward the existing build type, shared-library option, prefix, and selected
   Python interpreter where relevant. Ordinary fresh builds inherit
   `MACOSX_DEPLOYMENT_TARGET` from `build.sh` and use CMake's native architecture
   and SDK selection. Do not add blanket architecture/deployment/SDK arguments
   to recipes. Override architecture and deployment target only for packages
   that set their own defaults, such as OTIO; reuse `lib_arch` and the existing
   deployment-target variable. Do not force an SDK unless it is required.
5. Declare real installed outputs using `build_add_files`, `build_add_dir`, and
   `build_add_libs` where appropriate. Match the upstream library version,
   Debug suffix, and Python ABI suffix. Track headers/directories, libraries,
   Python modules, pkg-config files, and CMake package files that consumers need.
   Put a real installed file first in multi-output rules; a directory as the
   primary output can hide missing secondary files with Unix Makefiles.
6. Execute the actual configure, build, and install commands from the custom
   command. Defining an unused `build_configure` or `build_install` variable does
   not perform those steps. List the outputs in both the custom command and
   the custom target's dependencies. Use CMake's built-in `add_custom_command`
   with output-based build decisions. Do not add automatic recipe/flag/script
   invalidation, completion stamps, or timestamp-touch workarounds. Changes to
   flags alone are intentionally not tracked. Preserve explicit dependencies
   needed for specific functionality, such as installed Qt module configs.
7. Reuse `build_install_script` for Mach-O path normalization and
   `build_install_check` for required files. Pass binary files to path rewriting
   and regular files to the existence check; do not pass directories as files.
8. Register the package in the appropriate existing build group, then declare
   its prerequisites with `build_add_dependencies`.
9. For new libraries and version updates, keep the original upstream source
   archives unchanged in the Amazon S3 bucket. Store required patches alongside
   the library's `CMakeLists.txt` in `src/<library>/`. Keep Windows port patches
   in `src/<library>/msvc/`. Reuse `build_patch` and run
   `COMMAND ${build_patch}` after extraction and before configuration/build,
   following `src/llvm`. Prefer upstream fixes and record their commit or PR.
   Validate patches against the original archive and compile the actual affected
   source files for Debug and Release. Recheck each patch when upgrading versions.
   Document the exact archive, extracted root, version/commit, and applied patches
   in `packages.txt`. Preserve upstream license notices and update
   `THIRD_PARTY_NOTICES.md` and `licenses/manifest.json` with provenance/checksums.

## Validation

- Always validate a fresh install: empty build and install directories must be
  sufficient. Existing installed files must not hide missing build/install steps.
  Do not add cache-repair code, installed-output fallbacks, or ignored errors to
  make a stale working tree pass.
- Validate both Debug and Release, including the package's prerequisite targets:

  ```sh
  ./build.sh debug --project opentimelineio --target 12
  ./build.sh release --project opentimelineio --target 12
  ```

- For disposable fresh prefixes, reuse the existing Makefile `build_dir`
  override, for example:

  ```sh
  MAKEFLAGS='-- build_dir=build-validation' \
    ./build.sh all --project opentimelineio --target 12
  ```

- Check every declared output, architecture, and non-system runtime dependency
  against the selected configuration's prefix. Verify CMake/pkg-config consumer
  metadata and Python imports where provided, and compile/run a small external
  C++ consumer. Check downloaded archive and copied notice checksums.
- Keep temporary consumers and validation scripts under ignored build folders
  or temporary directories. Do not recreate the removed root `tests` directory
  or retain dependency checkouts and test archives there.
- Record any upstream runtime defects separately; do not disguise them as a
  successful build check or silently modify the published source.
- Run `bash -n build.sh` and `git diff --check`. Do not build the whole dependency
  collection to validate one newly added library.
