/* Copyright 2020 Cartesi Pte. Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 */

#include <pma-defines.h>

// Uses HTIF to exit the emulator with exit code in an immediate
#define exit_imm(imm) \
	li gp, imm; \
	j exit;

// Section with code
.section .text.init
.align 2;
.global _start;
_start:
	// Set the exception handler to trap
	// This is just in case an exception happens
	la t0, trap;
	csrw mtvec, t0;

execute_LR:
	la t1, foo;
	lr.w x0, (t0);
	beqz x0, execute_SC;
	exit_imm(2)

execute_SC:
	sc.w x0, t0, (t1);
	beqz x0, execute_AMO;
	exit_imm(3)

execute_AMO:
	amoadd.w x0, t0, (t1);
	beqz x0, execute_csr_RW;
	exit_imm(4)

execute_csr_RW:
	csrrw x0, sscratch, x0;
	beqz x0, execute_csr_SC;
	exit_imm(5)

execute_csr_SC:
	csrrs x0, sscratch, t1;
	beqz x0, execute_csr_SCI;
	exit_imm(6)

execute_csr_SCI:
	csrrsi x0, sscratch, 4;
	beqz x0, execute_arithmetic;
	exit_imm(7)

execute_arithmetic:
	add x0, t0, t1;
	beqz x0, execute_arithmetic_imm;
	exit_imm(8)

execute_arithmetic_imm:
	addi x0, x0, 9;
	beqz x0, execute_L;
	exit_imm(9)

execute_L:
	lb x0, (t1)
	beqz x0, execute_LUI;
	exit_imm(10)

execute_LUI:
	lui x0, 0x00001;
	beqz x0, execute_AUIPC;
	exit_imm(11)

execute_AUIPC:
	auipc x0, 0x00001;
	beqz x0, execute_JAL;
	exit_imm(12)

execute_JAL:
	jal x0, jal_test;
jal_test:
	beqz x0, execute_JALR;
	exit_imm(13)

execute_JALR:
	la t2, jalr_test;
	jalr x0, t2, 0;
jalr_test:
	beqz x0, success;
	exit_imm(14)

success:
	exit_imm(0);

// catch exception and exit
trap:
	exit_imm(1);

// Exits via HTIF using gp content as the exit code
exit:
	// HTIF exits with dev = cmd = 0 and a payload with lsb set.
	// the exit code is taken from payload >> 2
	slli gp, gp, 16;
	srli gp, gp, 15;
	ori gp, gp, 1;
1:
	li t0, PMA_HTIF_START_DEF
	sd gp, 0(t0);
	j 1b; // Should not be necessary

.data
foo: .word 0;
