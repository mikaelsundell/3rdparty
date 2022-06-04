#########################################################################
#
# This is the master makefile.
# Here we put all the top-level make targets, platform-independent
# rules, etc.
#
# Run 'make help' to list helpful targets.
#
#########################################################################


.PHONY: all debug clean realclean nuke

base_dir     =${working_dir}
working_dir	:= ${shell pwd}

$(info 3rdparty:configuration)

# Figure out which architecture we're on
include ${working_dir}/src/make/detectplatform.mk

# Presence of make variables DEBUG and PROFILE cause us to make special
# builds, which we put in their own areas.
ifdef DEBUG
    variant +=${hw}.debug
endif

MY_MAKE_FLAGS ?=
MY_CMAKE_FLAGS ?=

# Set up variables holding the names of platform-dependent directories --
# set these after evaluating site-specific instructions
build_dir     := build
platform_dir  := ${build_dir}/${platform}/${variant}

$(info -- base_dir = ${base_dir})
$(info -- build_dir = ${build_dir})

VERBOSE := ${SHOWCOMMANDS}
ifneq (${verbose},)
MY_CMAKE_FLAGS += -DCMAKE_VERBOSE_MAKEFILE:BOOL=${verbose}
endif

ifneq (${build_base},)
	MY_CMAKE_FLAGS += -Dbuild_base:BOOL=${build_base}
endif

ifneq (${build_libs},)
	MY_CMAKE_FLAGS += -Dbuild_libs:BOOL=${build_libs}
endif

ifneq (${build_extras},)
	MY_CMAKE_FLAGS += -Dbuild_extras:BOOL=${build_extras}
endif

ifneq (${build_autotools},)
	MY_CMAKE_FLAGS += -Dbuild_autotools:BOOL=${build_autotools}
endif

ifneq (${build_media},)
	MY_CMAKE_FLAGS += -Dbuild_media:BOOL=${build_media}
endif

ifdef DEBUG
	MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=Debug
else
	MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=Release
endif

#########################################################################
# Top-level documented targets

all: cmakeinstall

# 'make debug' is implemented via recursive make setting DEBUG
debug: 
	@( ${MAKE} DEBUG=1 --no-print-directory )

# 'make cmakesetup' constructs the build directory and runs 'cmake' there
cmakesetup:  
	@( cmake -E make_directory ${platform_dir} ; \
		cd ${platform_dir} ; \
		cmake -DCMAKE_INSTALL_PREFIX=${base_dir}/${platform_dir} \
			 ${MY_CMAKE_FLAGS} \
			 ../../../ ; \
	 )

# 'make cmakeinstall' builds everthing and installs it in 'dist'.
# Suppress pointless output from docs installation.
cmakeinstall: cmakesetup
	@( cd ${platform_dir} ; time ${MAKE} ${MY_MAKE_FLAGS} )

# 'make clean' clears out the build directory for this platform
clean:
	@( cmake -E remove_directory ${build_dir} )

#########################################################################

# 'make help' prints important make targets
help:
	@echo "Targets:"
	@echo "  make                        Build all projects for development and test in ${build_dir},"
	@echo "  make debug                  Build all projects with debugging symbols when possible."
	@echo "  make cmake                  Build all projects with cmake."
	@echo "  make clean                  Get rid of all build files."
	@echo "  make help                   Print all the make options"
	@echo ""
	@echo "Helpful modifiers:"
	@echo "  make verbose=1 ...          Show all compilation commands."
	@echo "  make build_base=1 ...       Build base."
	@echo "  make build_libs=1 ...       Build libraries."
	@echo "  make build_extras=1 ...     Build extras."
	@echo "  make build_autotools=1 ...  Build autotools."
	@echo "  make build_media=1 ...      Build media."
	@echo ""

