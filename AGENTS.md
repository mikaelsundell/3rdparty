# Working on 3rdparty

## Build entry points

- Keep the existing flow: `build.sh` delegates to the root `Makefile`, which
  configures CMake and invokes its generated Makefiles.
- Use `MY_MAKE_FLAGS` to select a generated target. Keep prerequisite edges in
  `build_add_dependencies`; do not duplicate the dependency graph in `build.sh`.
- Use the normal `build/macosx/<architecture>.debug` and `.release` directories.
  Do not introduce an alternative permanent build layout for selected projects.
- A selected library build must skip Qt and unrelated package targets.

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
   actual source-root name; it may differ from its filename. Configure from the
   extracted source's `${build_cmake}` directory, using the established
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
6. Execute the actual configure, build, and install commands from the custom
   command. Defining an unused `build_configure` or `build_install` variable does
   not perform those steps. List the outputs in both the custom command and
   the custom target's dependencies.
7. Reuse `build_install_script` for Mach-O path normalization and
   `build_install_check` for required files. Pass binary files to path rewriting
   and regular files to the existence check; do not pass directories as files.
8. Register the package in the appropriate existing build group, then declare
   its prerequisites with `build_add_dependencies`.
9. Prefer corrected, published source packages over local source patches.
   Document the exact archive, extracted root, version/commit, and fork changes
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
