PREFIX = /opt/cartesi
INSTALLDIR = $(PREFIX)/tests
UARCH_ENV_DIR := $(abspath .)
LIB_DIR := $(abspath ../../lib)
RISCV_PREFIX ?= riscv64-cartesi-linux-gnu-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static  -march=rv64i -mabi=lp64 -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -S -O binary

# Tests provided by third party riscv tests
THIRDPARTY_TESTS = \
	add addi addiw addw \
	and andi \
	auipc \
	beq bge bgeu blt bltu bne \
	simple \
	fence_i \
	jal jalr \
	lb lbu lh lhu lw lwu ld \
	lui \
	or ori \
	sb sh sw sd \
	sll slli slliw sllw \
	slt slti sltiu sltu \
	sra srai sraiw sraw \
	srl srli srliw srlw \
	sub subw \
	xor xori

THIRDPARTY_SRC_DIR := $(abspath ../../third-party/riscv-tests/isa/rv64ui)
THIRDPARTY_BUILD_DIR := $(abspath ./third_party_build)
THIRDPARTY_TEST_NAMES = $(addprefix rv64ui-uarch-, $(THIRDPARTY_TESTS))
THIRDPARTY_TESTS_BIN_NAMES = $(addsuffix .bin, $(THIRDPARTY_TEST_NAMES))
THIRDPARTY_TESTS_DUMP_NAMES = $(addsuffix .dump, $(THIRDPARTY_TEST_NAMES))
TARGET_THIRDPARTY_TESTS = $(addprefix $(THIRDPARTY_BUILD_DIR)/, $(THIRDPARTY_TEST_NAMES))

# Tests provided by us
TESTS = fence
SRC_DIR = $(abspath .)
BUILD_DIR = $(abspath ./build)
TEST_NAMES = $(addprefix rv64ui-uarch-, $(TESTS))
TESTS_BIN_NAMES = $(addsuffix .bin, $(TEST_NAMES))
TESTS_DUMP_NAMES = $(addsuffix .dump, $(TEST_NAMES))
TARGET_TESTS = $(addprefix $(BUILD_DIR)/, $(TEST_NAMES))

TARGET_TEST_BINS  = \
	$(addprefix $(THIRDPARTY_BUILD_DIR)/, $(THIRDPARTY_TESTS_BIN_NAMES)) \
	$(addprefix $(BUILD_DIR)/, $(TESTS_BIN_NAMES))

TARGET_TEST_DUMPS = \
	$(addprefix $(THIRDPARTY_BUILD_DIR)/, $(THIRDPARTY_TESTS_DUMP_NAMES)) \
	$(addprefix $(BUILD_DIR)/, $(TESTS_DUMP_NAMES))

TARGETS =  \
	$(TARGET_THIRDPARTY_TESTS)  \
	$(TARGET_TESTS)  \
	$(TARGET_TEST_BINS) \
	$(TARGET_TEST_DUMPS)

all: $(TARGETS)

clean:
	rm -f $(TARGETS) $(BUILD_DIR) $(THIRDPARTY_BUILD_DIR)

install:
	mkdir -p $(INSTALLDIR)
	cp -a $(BUILD_DIR)/* $(INSTALLDIR)
	cp -a $(THIRDPARTY_BUILD_DIR)/* $(INSTALLDIR)

$(THIRDPARTY_BUILD_DIR)/rv64ui-uarch-%: $(THIRDPARTY_BUILD_DIR) $(THIRDPARTY_SRC_DIR)/%.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -I$(UARCH_ENV_DIR) \
		-I$(THIRDPARTY_SRC_DIR)/../macros/scalar \
		-I$(LIB_DIR)/machine-emulator-defines \
		-T$(UARCH_ENV_DIR)/link.ld \
		$(THIRDPARTY_SRC_DIR)/$*.S -o $(THIRDPARTY_BUILD_DIR)/rv64ui-uarch-$*

$(BUILD_DIR)/rv64ui-uarch-%: $(BUILD_DIR) $(SRC_DIR)/%.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -I$(UARCH_ENV_DIR) \
		-I$(THIRDPARTY_SRC_DIR)/../macros/scalar \
		-I$(LIB_DIR)/machine-emulator-defines \
		-T$(UARCH_ENV_DIR)/link.ld \
		$(SRC_DIR)/$*.S -o $(BUILD_DIR)/rv64ui-uarch-$*

%.bin: %
	$(RISCV_OBJCOPY) $* $*.bin

%.dump: %
	$(RISCV_OBJDUMP) $* > $*.dump

$(BUILD_DIR) $(THIRDPARTY_BUILD_DIR):
	mkdir -p $@

install:
	cp rv64ui-uarch-catalog.json $(INSTALLDIR)
