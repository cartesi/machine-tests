/* Copyright 2022 Cartesi Pte. Ltd.
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

#define exit_imm(imm) \
    li gp, imm; \
    j exit;

#define check_minstret(n) \
    csrr t0, minstret; \
    li t1, n; \
    bne t0, t1, fail;

#define set_minstret(n) \
    csrwi minstret, n;

#define MSTATUS_MPP_MASK 0x1800
#define MSTATUS_MPP_S    0x800

// Section with code
.section .text.init
.align 2;
.global _start;
_start:
    // Set the fail exception handler to trap
    la t0, fail;
    csrw mtvec, t0;

    // Expect time read to be valid
    rdtime t0;

    // Expect cycle greater than 0
    rdcycle t0;
    beq t0, zero, fail;

    // Expect instret to be greater than 0
    rdinstret t0;
    beq t0, zero, fail;

    // Expect mcountinhibit to read 0
    csrr t0, mcountinhibit;
    bne t0, zero, fail;

    // Expect all hpmcounters to read 0
    csrr t0, hpmcounter3;
    bne t0, zero, fail;
    csrr t0, hpmcounter13;
    bne t0, zero, fail;
    csrr t0, hpmcounter31;
    bne t0, zero, fail;

    // Set a trap that will ignore the failing instruction and resume to next instruction
    la t0, skip_instruction_trap;
    csrw mtvec, t0;

    // No instructions between instret read and write, it should stay 0
    set_minstret(0);
    check_minstret(0);

    // One instruction must, increment instret by 1
    set_minstret(0);
    nop; // increment 1 instruction
    check_minstret(1);

    // EBREAK
    set_minstret(0);
    ebreak; // exception raised, increment only 4 trap instructions
    check_minstret(4);

    // ECALL
    set_minstret(0);
    ebreak; // exception raised, increment only 4 trap instructions
    check_minstret(4);

    // LR/SC for invalid addresses
    set_minstret(0);
    li t0, 0xffffffffffffffff; // increment 1 instruction
    lr.w t0, (t0); // exception raised, increment only 4 trap instructions
    li t0, 0xffffffffffffffff; // increment 1 instruction
    sc.w t0, t0, (t0); // exception raised increment only 4 trap instructions
    check_minstret(10);

    // LW/SW for invalid addresses
    set_minstret(0);
    li t0, 0xffffffffffffffff; // increment 1 instruction
    lw t0, (t0); // exception raised, increment only 4 trap instructions
    li t0, 0xffffffffffffffff; // increment 1 instruction
    sw t0, 0(t0); // exception raised, increment only 4 trap instructions
    check_minstret(10);

	// If RVC is enabled, skip to next test
    csrr t2, misa;
    andi t2, t2, 1 << ('c' - 'a');
    bnez t2, supervisor_mode;
    // Jump into a misaligned address
    set_minstret(0);
    la a1, _start; // increment 2 instructions (auipc + addi)
    jalr x0, 3(a1); // exception raised increment only trap instructions
    check_minstret(6);

supervisor_mode:
    // Enter supervisor mode.
    la t0, in_supervisor
    csrw mepc, t0
    li t0, MSTATUS_MPP_MASK
    csrc mstatus, t0
    li t1, MSTATUS_MPP_S
    csrs mstatus, t1
    mret

in_supervisor:
    // Expect time read to be valid
    rdtime t0;

    // Expect cycle greater than 0
    rdcycle t0;
    beq t0, zero, fail;

    // Expect instret to be greater than 0
    rdinstret t0;
    beq t0, zero, fail;

    exit_imm(0);

fail:
    exit_imm(1);

skip_instruction_trap:
    csrr t0, mepc;
    addi t0, t0, 4;
    csrw mepc, t0;
    mret;

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
