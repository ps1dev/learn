// Hooks for the CI run that boots every example in PCSX-Redux. They compile
// to nothing unless the example is built with BOOK_CI=true, so the examples
// read the same as they would without them.

#pragma once

#ifdef BOOK_CI
#include "common/hardware/pcsxhw.h"
#include "common/syscalls/syscalls.h"

// Print the line the CI script greps for, then leave the emulator with
// exit code 0. On hardware pcsx_exit is an ignored store.
#define BOOK_CI_PASS(fmt, ...)                                  \
    do {                                                        \
        ramsyscall_printf("BOOK-PASS " fmt "\n", ##__VA_ARGS__); \
        pcsx_exit(0);                                           \
    } while (0)
#else
#define BOOK_CI_PASS(fmt, ...) \
    do {                       \
    } while (0)
#endif
