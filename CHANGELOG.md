# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.27.0] - 2023-04-26
- Added rv64ui-uarch-catalog.json
- Added rv64ui uarch fence test

### Changed
- Improved rv64ui test build

## [0.26.0] - 2023-04-18
### Added
- Added separated build for uarch/rv64ui tests

### Changed
- Updated toolchain image to v0.14.0
- Updated machine-emulator-defines

## [0.25.0] - 2023-02-16
### Added
- Added a big set of floating-point tests
- Added virtual address translation tests
- Added illegal instruction tests
- Added new tests for HTIF and CLINT devices
- Added interrupts tests
- Added support for debugging tests with GDB

### Changed
- Bump marchid to 0xe

## [0.24.0] - 2023-02-10
### Added
- Added RISC-V compressed instructions tests

### Changed
- Updated toolchain version to v0.13.0

## [0.23.0] - 2022-11-17
### Added
- Added RISC-V floating-point tests

### Changed
- Changed PMA board address to the new range in microarchitecture
- Updated toolchain version to v0.12.0

## [0.22.0] - 2022-10-19
### Changed
- Bump marchid to 0xd

## [0.21.0] - 2022-10-03
### Added
- Added PTE reserved exception test
- Added xtval value test

## [0.20.0] - 2022-09-14
### Added
- Added CSR semantics test
- Added CSR counters test
- Added LR/SC test
- Added mcycle write test

### Changed
- Updated RISC-V tests.

## [0.19.0] - 2022-06-30
### Changed
- Updated toolchain version to v0.11.0
- Bump marchid to 0xc

## [0.18.0] - 2022-06-24
### Changed
- Updated toolchain version to v0.10.0

## [0.17.0] - 2022-06-10
### Changed
- Bump marchid to 0xb

## [0.16.0] - 2022-05-12
### Changed
- Bump marchid to 0xa
- Correct a bug on the HTIF test
- Split yield and console into separate files

## [0.15.0] - 2022-04-20
### Changed
- Updated toolchain version to v0.9.0

## [0.14.0] - 2022-03-24
### Added
- Added rollup exception test

### Changed
- Updated toolchain version to v0.8.0

## [0.13.0] - 2021-12-17
### Changed
- Updated toolchain version to v0.7.0
- Adjust yield test to generate both types: manual and automatic
- Add rollup test

## [Previous Versions]
- [0.12.0]
- [0.11.0]
- [0.10.0]
- [0.9.0]
- [0.8.0]
- [0.7.0]
- [0.6.0]
- [0.5.0]
- [0.4.0]
- [0.3.0]
- [0.2.0]
- [0.1.0]

[Unreleased]: https://github.com/cartesi/machine-tests/compare/v0.27.0...HEAD
[0.27.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.27.0
[0.26.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.26.0
[0.25.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.25.0
[0.24.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.24.0
[0.23.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.23.0
[0.22.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.22.0
[0.21.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.21.0
[0.20.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.20.0
[0.19.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.19.0
[0.18.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.18.0
[0.17.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.17.0
[0.16.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.16.0
[0.15.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.15.0
[0.14.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.14.0
[0.13.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.13.0
[0.12.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.12.0
[0.11.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.11.0
[0.10.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.10.0
[0.9.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.9.0
[0.8.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.8.0
[0.7.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.7.0
[0.6.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.6.0
[0.5.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.5.0
[0.4.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.4.0
[0.3.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.3.0
[0.2.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.2.0
[0.1.0]: https://github.com/cartesi/machine-tests/releases/tag/v0.1.0
