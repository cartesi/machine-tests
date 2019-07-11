BUILD_DIR ?= $(abspath ../build)
SRC_DIR ?= .

ifneq ($(EMULATOR_INC),)
EMULATOR_FLAGS= -I$(EMULATOR_INC)
endif

RISCV_PREFIX = riscv64-unknown-linux-gnu-
CC  = $(RISCV_PREFIX)gcc
CXX = $(RISCV_PREFIX)g++
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

CFLAGS=-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -I$(BUILD_DIR)/include $(EMULATOR_FLAGS)
CXXFLAGS=-static -fno-exceptions -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -I$(BUILD_DIR)/include $(EMULATOR_FLAGS)

SRCS  := $(wildcard *.S)
TMPS  := $(SRCS:.S=.out)
BINS  := $(TMPS:%.out=$(BUILD_DIR)/%.bin)
DUMPS := $(TMPS:%.out=$(BUILD_DIR)/%.dump)

.DEFAULT_GOAL := all

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.out
	$(OBJCOPY) -S -O binary $< $@

$(BUILD_DIR)/%.dump: $(BUILD_DIR)/%.out
	$(OBJDUMP) -d $< > $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# assembly
$(BUILD_DIR)/%.out: %.S $(BUILD_DIR)
	$(CC) $(CFLAGS) $(patsubst %.ld,-T%.ld,$(wildcard $(patsubst %.S,%.ld,$<))) -o $@ $<

.PHONY: all clean copy
all: $(BINS) $(DUMPS)

clean:
	$(RM) -r $(BUILD_DIR)/*.out $(BUILD_DIR)/*.bin


