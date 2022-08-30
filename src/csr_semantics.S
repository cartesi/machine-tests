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

// Uses HTIF to exit the emulator with exit code in an immediate
#define exit_imm(imm) \
    li gp, imm; \
    j exit;

#define MSTATUS_MPP_MASK    0x00001800
#define MSTATUS_MPP_U       0x0
#define MSTATUS_MPP_S       0x800
#define MSTATUS_MPP_HS      0x1000
#define MSTATUS_MPP_M       0x1800

// Section with code
.section .text.init
.align 2;
.global _start;
_start:
    // Set the exception handler to trap
    // This is just in case an exception happens
    la t0, trap;
    csrw mtvec, t0;

    // Check if HS-mode is supported (currently it's not)
    li t0, MSTATUS_MPP_MASK
    csrc mstatus, t0        // set MPP to U-mode
    li t1, MSTATUS_MPP_HS
    csrs mstatus, t1        // attempt to set MPP to HS-mode
    csrr t2, mstatus
    and t2, t2, t0          // read MPP
    bne t2, zero, error     // MPP should be in U-mode

    // Check if S-mode is supported
    li t0, MSTATUS_MPP_MASK
    csrc mstatus, t0        // set MPP to U-mode
    li t1, MSTATUS_MPP_S
    csrs mstatus, t1        // attempt to set MPP to S-mode
    csrr t2, mstatus
    and t2, t2, t0          // read MPP
    bne t2, t1, error       // MPP should be in S-mode

    // Check if M-mode is supported
    li t0, MSTATUS_MPP_MASK
    csrc mstatus, t0        // set MPP to U-mode
    li t1, MSTATUS_MPP_M
    csrs mstatus, t1        // attempt to set MPP to S-mode
    csrr t2, mstatus
    and t2, t2, t0          // read MPP
    bne t2, t1, error       // MPP should be in M-mode

    exit_imm(0);

// on error halt with 1
error:
    exit_imm(1);

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
