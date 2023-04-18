UARCH_ENV_DIR := $(abspath .)
DEST_DIR := $(abspath ../../third-party/riscv-tests/isa)
SRC_DIR := $(abspath ../../third-party/riscv-tests/isa/rv64ui)
LIB_DIR := $(abspath ../../lib)
RISCV_PREFIX ?= riscv64-cartesi-linux-gnu-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static  -march=rv64i -mabi=lp64 -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -S -O binary
TESTS = \
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
	xor xori \

UARCH_TESTS = $(addprefix rv64ui-uarch-, $(TESTS))
UARCH_TESTS_BIN = $(addsuffix .bin, $(UARCH_TESTS))
UARCH_TESTS_DUMP = $(addsuffix .dump, $(UARCH_TESTS))

DEST_UARCH_TESTS = $(addprefix $(DEST_DIR)/, $(UARCH_TESTS))
DEST_UARCH_TESTS_BIN = $(addprefix $(DEST_DIR)/, $(UARCH_TESTS_BIN))
DEST_UARCH_TESTS_DUMP = $(addprefix $(DEST_DIR)/, $(UARCH_TESTS_DUMP))

all:  $(DEST_UARCH_TESTS_BIN)  $(DEST_UARCH_TESTS_DUMP)

clean:
	rm -f $(DEST_UARCH_TESTS) $(DEST_UARCH_TESTS_BIN) $(DEST_UARCH_TESTS_DUMP)

$(DEST_DIR)/rv64ui-uarch-%: $(SRC_DIR)/%.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -I$(UARCH_ENV_DIR) \
		-I$(SRC_DIR)/../macros/scalar \
		-I$(LIB_DIR)/machine-emulator-defines \
		-T$(UARCH_ENV_DIR)/link.ld \
		$(SRC_DIR)/$*.S -o $(DEST_DIR)/rv64ui-uarch-$*

%.bin: %
	$(RISCV_OBJCOPY) $* $*.bin

%.dump: %
	$(RISCV_OBJDUMP) $* > $*.dump

