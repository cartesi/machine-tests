# Copyright 2019 Cartesi Pte. Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#

UNAME:=$(shell uname)

PREFIX = /opt/cartesi
INSTALLDIR = $(PREFIX)/tests

DEPDIR := third-party
SRCDIR := $(abspath src)
BUILDDIR = $(abspath build)
DOWNLOADDIR := $(DEPDIR)/downloads
SRCCLEAN := $(addsuffix .clean,$(SRCDIR))
DEPDIRS := $(addprefix $(DEPDIR)/,riscv-tests)
DEPCLEAN := $(addsuffix .clean,$(DEPDIRS))

TOOLCHAIN_DOCKER_REPOSITORY ?= cartesi/toolchain
TOOLCHAIN_TAG ?= 0.13.0

RISCV_PREFIX = riscv64-cartesi-linux-gnu-
RVCC  = $(RISCV_PREFIX)gcc
RVCXX = $(RISCV_PREFIX)g++
RVCOPY = $(RISCV_PREFIX)objcopy
RVDUMP = $(RISCV_PREFIX)objdump

all: $(SRCDIR)

clean: $(SRCCLEAN)

depclean: $(DEPCLEAN) clean
	rm -rf $(BUILDDIR)
	$(MAKE) -C $@ clean

distclean: clean
	rm -rf $(BUILDDIR) $(DOWNLOADDIR) $(DEPDIRS)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

lib/machine-emulator-defines/pma-defines.h:
	git submodule update --init --recursive lib/machine-emulator-defines

$(DEPDIR)/riscv-tests:
	cd $@ && ./configure
	$(MAKE) -C $@ RISCV_PREFIX=$(RISCV_PREFIX)
	$(MAKE) copy-riscv-tests

submodules:
	git submodule update --init --recursive third-party/riscv-tests

downloads: submodules

dep: $(BUILDDIR) $(DEPDIRS)

$(SRCDIR):
	$(MAKE) -C $@ RISCV_PREFIX=$(RISCV_PREFIX) $(TARGET)

$(SRCCLEAN) $(DEPCLEAN): %.clean:
	$(MAKE) -C $* clean

copy-riscv-tests: $(BUILDDIR)
	cp -a $(DEPDIR)/riscv-tests/isa/*.bin $(DEPDIR)/riscv-tests/isa/*.dump $(BUILDDIR)
	cd $(DEPDIR)/riscv-tests/isa && find . -maxdepth 1 -type f ! -name "*.*" -exec cp -a {} $(BUILDDIR)/{}.elf \;

install: copy-riscv-tests
	mkdir -p $(INSTALLDIR)
	cp -a $(BUILDDIR)/*.bin $(BUILDDIR)/*.dump $(BUILDDIR)/*.elf $(INSTALLDIR)

toolchain-env:
	@docker run --hostname toolchain-env -it --rm \
		-e USER=$$(id -u -n) \
		-e GROUP=$$(id -g -n) \
		-e UID=$$(id -u) \
		-e GID=$$(id -g) \
		-v `pwd`:/opt/cartesi/machine-tests \
		-w /opt/cartesi/machine-tests \
		$(TOOLCHAIN_DOCKER_REPOSITORY):$(TOOLCHAIN_TAG)

toolchain-exec:
	docker run --hostname toolchain-env --rm \
		-e USER=$$(id -u -n) \
		-e GROUP=$$(id -g -n) \
		-e UID=$$(id -u) \
		-e GID=$$(id -g) \
		-v `pwd`:/opt/cartesi/machine-tests \
		-w /opt/cartesi/machine-tests \
		$(TOOLCHAIN_DOCKER_REPOSITORY):$(TOOLCHAIN_TAG) $(CONTAINER_COMMAND)

.PHONY: all clean distclean downloads $(SRCDIR) $(DEPDIRS) $(SRCCLEAN) $(DEPCLEAN)
