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

EMULATOR_INC =
EMULATOR_DEP =

DEPDIR := third-party
SRCDIR := $(abspath src)
BUILDDIR = $(abspath build)
DOWNLOADDIR := $(DEPDIR)/downloads
SRCCLEAN := $(addsuffix .clean,$(SRCDIR))
DEPDIRS := $(addprefix $(DEPDIR)/,riscv-tests)
DEPCLEAN := $(addsuffix .clean,$(DEPDIRS))

TOOLCHAIN_TAG ?= devel

ifeq ($(EMULATOR_INC),)
EMULATOR_DEP = $(DEPDIR)/machine-emulator
EMULATOR_INC = $(abspath $(EMULATOR_DEP)/src)
endif

RISCV_PREFIX = riscv64-unknown-linux-gnu-
RVCC  = $(RISCV_PREFIX)gcc
RVCXX = $(RISCV_PREFIX)g++
RVCOPY = $(RISCV_PREFIX)objcopy
RVDUMP = $(RISCV_PREFIX)objdump

all: $(SRCDIR)

clean: $(SRCCLEAN)

depclean: $(DEPCLEAN) clean
	rm -rf $(BUILDDIR)

distclean: clean
	rm -rf $(BUILDDIR) $(DOWNLOADDIR) $(DEPDIRS) $(EMULATOR_DEP)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(DEPDIR)/machine-emulator:
	if [ ! -d $@ ]; then git clone --branch master --depth 1 git@github.com:cartesi/machine-emulator.git $@; fi

$(DEPDIR)/riscv-tests:
	cd $@ && ./configure
	$(MAKE) -C $@ RISCV_PREFIX=$(RISCV_PREFIX)

submodules:
	git submodule update --init --recursive

downloads: submodules $(EMULATOR_DEP)

dep: $(BUILDDIR) $(DEPDIRS)

$(SRCDIR):
	$(MAKE) -C $@ RISCV_PREFIX=$(RISCV_PREFIX) EMULATOR_INC=$(EMULATOR_INC) $(TARGET)

$(SRCCLEAN) $(DEPCLEAN): %.clean:
	$(MAKE) -C $* clean

copy-riscv-tests: $(BUILDDIR)
	cp -a $(DEPDIR)/riscv-tests/isa/*.bin $(DEPDIR)/riscv-tests/isa/*.dump $(BUILDDIR)

install: copy-riscv-tests
	mkdir -p $(INSTALLDIR)
	cp -a $(BUILDDIR)/*.bin $(BUILDDIR)/*.dump $(INSTALLDIR)

toolchain-env:
	@docker run --hostname toolchain-env -it --rm \
		-e USER=$$(id -u -n) \
		-e GROUP=$$(id -g -n) \
		-e UID=$$(id -u) \
		-e GID=$$(id -g) \
		-v `pwd`:/opt/cartesi/machine-tests \
		-w /opt/cartesi/machine-tests \
		cartesi/image-toolchain:$(TOOLCHAIN_TAG)

.PHONY: all clean distclean downloads $(SRCDIR) $(DEPDIRS) $(SRCCLEAN) $(DEPCLEAN)
