#ifndef HTIF_UTIL_H
#define HTIF_UTIL_H
#include <pma-defines.h>
#include <htif-defines.h>

/* from: https://www.cartesi.io/en/docs/machine/target/architecture/
 * 1. start by writing 0 to fromhost
 * 2. write the request to tohost     (from a0)
 * 3. read the response from fromhost (into a0)
 *
 * with the following memory layout:
 * +------+----------+
 * | 0x00 | tohost   |
 * | 0x08 | fromhost |
 * | 0x10 | ihalt    |
 * | 0x18 | iconsole |
 * | 0x20 | iyield   |
 * +------+----------+
 *
 * htif register offsets: */
#define O_TOHOST   0x00
#define O_FROMHOST 0x08
#define O_IHALT    0x10
#define O_ICONSOLE 0x18
#define O_IYIELD   0x20

#define htif_const(dev, cmd, data) \
    (((dev) << 56UL) | (((cmd) & 0xff) << 48UL) | (((data) & 0xffffffffffUL)))
#define htif_yield_const(reason, data) \
    ((((reason) & 0xffffUL) << 32UL) | (((data) & 0xffffffffUL)))

#define htif_call(base, ireg, oreg) \
    li base, PMA_HTIF_START_DEF; \
    sd zero, O_FROMHOST (base); \
    sd ireg, O_TOHOST   (base); \
    ld oreg, O_FROMHOST (base)

#define htif_yield(cmd, reason, data) \
    li t1, htif_const(HTIF_DEVICE_YIELD_DEF, cmd, htif_yield_const(reason, data)); \
    htif_call(t0, t1, a0)

#define htif_exit(retval) \
    li t1, htif_const(HTIF_DEVICE_HALT_DEF, HTIF_HALT_HALT_DEF, ((retval) << 1) | 0x01); \
    htif_call(t0, t1, a0)

#define htif_console_putchar(data) \
    li t1, htif_const(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_PUTCHAR_DEF, data); \
    htif_call(t0, t1, a0)

#define htif_console_getchar() \
    li t1, htif_const(HTIF_DEVICE_CONSOLE_DEF, HTIF_CONSOLE_GETCHAR_DEF, 0); \
    htif_call(t0, t1, a0); \
    andi a0, a0, 0xFF; \
    addi a0, a0, -1

#endif /* HTIF_UTIL_H */
