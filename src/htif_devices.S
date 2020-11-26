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
#include <htif-defines.h>

#define HTIF_TOHOST_ADDRESS PMA_HTIF_START_DEF
#define HTIF_FROMHOST_ADDRESS (PMA_HTIF_START_DEF+8)
#define HTIF_IYIELD_ADDRESS (PMA_HTIF_START_DEF+32)

// Uses HTIF to exit the emulator with exit code in an immediate.
// HTIF halt device exits with dev = cmd = 0 and a payload with lsb set.
// So the data payload uses bits 1-47
#define exit_imm(imm) \
    li gp, imm; \
    j exit;

// Sends a command to HTIF device
// Yield and Console device uses bits 0-47 for data payload
#define htif_cmd(dev, cmd, data) \
    li t0, dev; \
    slli t1, t0, HTIF_DEV_SHIFT_DEF; \
    li t0, cmd; \
    slli t0, t0, HTIF_CMD_SHIFT_DEF; \
    li t2, HTIF_CMD_MASK_DEF; \
    and t0, t0, t2; \
    or t1, t1, t0; \
    li t0, data; \
    li t2, HTIF_DATA_MASK_DEF; \
    and t0, t0, t2; \
    or gp, t1, t0; \
    li t0, HTIF_FROMHOST_ADDRESS; \
    li t1, HTIF_TOHOST_ADDRESS; \
    sd x0, 0(t0); \
    sd gp, 0(t1);

// Check HTIF fromhost address for yield command ack
#define check_htif_yield_ack(dev, cmd, data) \
    li t0, HTIF_IYIELD_ADDRESS; \
    ld t3, 0(t0); \
    srli t3, t3, cmd; \
    andi t3, t3, 1; \
    addi t3, t3, -1; \
    not t3, t3; // t3 is all 0 if cmd is disabled, all 1 if enabled \
    li t0, dev; \
    slli t1, t0, HTIF_DEV_SHIFT_DEF; \
    li t0, cmd; \
    slli t0, t0, HTIF_CMD_SHIFT_DEF; \
    li t2, HTIF_CMD_MASK_DEF; \
    and t0, t0, t2; \
    or t1, t1, t0; \
    li t0, data; \
    li t2, HTIF_DATA_MASK_DEF; \
    and t0, t0, t2; \
    or t1, t1, t0; \
    and t1, t1, t3; // if cmd is disabled, expect 0 ack \
    li t0, HTIF_FROMHOST_ADDRESS; \
    ld t2, 0(t0); \
    bne t1, t2, ack_failed;

// Check HTIF fromhost address for command ack
#define check_htif_ack(dev, cmd, data) \
    li t0, dev; \
    slli t1, t0, HTIF_DEV_SHIFT_DEF; \
    li t0, cmd; \
    slli t0, t0, HTIF_CMD_SHIFT_DEF; \
    li t2, HTIF_CMD_MASK_DEF; \
    and t0, t0, t2; \
    or t1, t1, t0; \
    li t0, data; \
    li t2, HTIF_DATA_MASK_DEF; \
    and t0, t0, t2; \
    or t1, t1, t0; \
    li t0, HTIF_FROMHOST_ADDRESS; \
    ld t2, 0(t0); \
    bne t1, t2, ack_failed;

// Section with code
.section .text.init
.align 2;
.global _start;
_start:
    // Set the exception handler to trap
    // This is just in case an exception happens
    la t0, trap;
    csrw mtvec, t0;

    // Test yield progress
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 10);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 0);
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 20);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 0);
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 30);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_PROGRESS_DEF, 0);

    // Test yield rollup
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 45);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 0);
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 55);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 0);
    htif_cmd(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 65);
    check_htif_yield_ack(HTIF_DEVICE_YIELD_DEF, HTIF_YIELD_ROLLUP_DEF, 0);

    // Test console getchar
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0);

    // Test console putchar
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 67);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 0);
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 84);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 0);
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 83);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 0);
    htif_cmd(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 73);
    check_htif_ack(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, 0);

    // halt with payload 42
    exit_imm(42);

// If HTIF device command is not acked, exit with 2
ack_failed:
    exit_imm(2);

// catch exception and exit
trap:
    exit_imm(1);

// Exits via HTIF using gp content as the exit code
exit:
    slli gp, gp, 16;
    srli gp, gp, 15;
    ori gp, gp, 1;
1:
    li t0, HTIF_FROMHOST_ADDRESS;
    li t1, HTIF_TOHOST_ADDRESS;
    sd x0, 0(t0);
    sd gp, 0(t1);
    j 1b; // Should not be necessary
