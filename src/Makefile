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

BUILD_DIR ?= $(abspath ../build)
RISCV_TESTS_DIR ?= $(abspath ../third-party/riscv-tests)

RISCV_PREFIX = riscv64-cartesi-linux-gnu-
CC  = $(RISCV_PREFIX)gcc
CXX = $(RISCV_PREFIX)g++
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

INCS=\
	-I$(BUILD_DIR)/include \
	-I$(RISCV_TESTS_DIR)/env/p \
	-I$(RISCV_TESTS_DIR)/env \
	-I$(RISCV_TESTS_DIR)/isa/macros/scalar \
	-I$(abspath ../lib/machine-emulator-defines)

CFLAGS=-g -march=rv64g -mabi=lp64d -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles $(INCS)
CXXFLAGS=-fno-exceptions $(CFLAGS)

SRCS  := $(wildcard *.S)
TMPS  := $(SRCS:.S=.elf)
BINS  := $(TMPS:%.elf=$(BUILD_DIR)/%.bin)
DUMPS := $(TMPS:%.elf=$(BUILD_DIR)/%.dump)

.DEFAULT_GOAL := all

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -S -O binary $< $@

$(BUILD_DIR)/%.dump: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -d $< > $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# assembly
$(BUILD_DIR)/%.elf: %.S | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Tlink.ld -o $@ $<

$(BUILD_DIR)/bootstrap.elf: bootstrap.S $(BUILD_DIR)
	$(CC) $(CFLAGS) -Tbootstrap.ld -o $@ $<

.PRECIOUS: $(BUILD_DIR)/%.elf
.PHONY: all clean copy uarch uarch-clean uarch-install
all: $(BINS) $(DUMPS)

uarch:
	make -C uarch

uarch-install:
	make -C uarch install INSTALLDIR=$(INSTALLDIR)

uarch-clean:
	make -C uarch clean

clean:
	$(RM) -r $(BUILD_DIR)/*.elf $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.dump
