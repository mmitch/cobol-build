#
# Makefile template for COBOL build system
# copy to your source root directory and edit to your needs
#


# Position of the COBOL build system root directory relative to the
# root directory of your project.
#
# BUILDROOT is the directory where you put cobol-build, either the
# git submodule or the manual download.

export BUILDROOT=cobol-build



# Position of the project root directory relative to the COBOL build system root.
#
# Your PROJECTROOT must have one or more subdirectories that adhere to
# this directory layout:
#
#      subdirectory
#      +-- build.txt
#      `-- src/
#          +-- main/
#          |   `-- cobol/
#          `-- test/
#              `-- cobol/

export PROJECTROOT=..


# FIXME: calculate $(PROJECTROOT) from $(BUILDROOT) as relative path


# dispatch these targets to the COBOL build system
# you can add your own commands or dependencies as you like

all:
	$(MAKE) -C $(BUILDROOT) $@

build:
	$(MAKE) -C $(BUILDROOT) $@

clean:
	$(MAKE) -C $(BUILDROOT) $@

test:
	$(MAKE) -C $(BUILDROOT) $@

autotest:
	$(MAKE) -C $(BUILDROOT) $@
