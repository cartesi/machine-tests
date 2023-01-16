UARCH_ENV_DIR := $(abspath .)
TESTS_SRC_DIR := $(abspath ../../third-party/riscv-tests/isa)
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

all:  $(UARCH_TESTS_BIN) $(UARCH_TESTS_DUMP)

rv64ui-uarch-%: $(TESTS_SRC_DIR)/rv64ui/%.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -I$(UARCH_ENV_DIR) \
		-I$(TESTS_SRC_DIR)/macros/scalar \
		-I$(LIB_DIR)/machine-emulator-defines \
		-T$(UARCH_ENV_DIR)/link.ld \
		$< -o $(TESTS_SRC_DIR)/$@

%.bin: %
	$(RISCV_OBJCOPY) $(TESTS_SRC_DIR)/$<  $(TESTS_SRC_DIR)/$@

%.dump: %
	$(RISCV_OBJDUMP) $(TESTS_SRC_DIR)/$< > $(TESTS_SRC_DIR)/$@
