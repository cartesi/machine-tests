# Cartesi Machine Tests

The Cartesi Machine Tests is a repository containing RISC-V testing code.

## Getting Started

### Requirements

- RISCV64 C/C++ Compiler with support for C++17 (tested with GCC >= 8+).
- GNU Make >= 3.81
- Docker image cartesi/toolchain-env:v1

### Build

```bash
$ make toolchain-env
[toolchain-env]$ make dep
[toolchain-env]$ make
[toolchain-env]$ exit 
$ make INSTALLDIR=/my/path install 
```

Cleaning:

```bash
[toolchain-env]$ make depclean
[toolchain-env]$ make clean
```

## Usage

TODO

## Contributing

Thank you for your interest in Cartesi! Head over to our [Contributing Guidelines](https://github.com/cartesi/machine-tests/blob/master/CONTRIBUTING.md) for instructions on how to sign our Contributors Agreement and get started with Cartesi!

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Authors

* *Diego Nehab*
* *Victor Fusco*

## License

The machine-tests repository and all contributions are licensed under
[APACHE 2.0](https://www.apache.org/licenses/LICENSE-2.0). Please review our [LICENSE](https://github.com/cartesi/machine-tests/blob/master/LICENSE) file.

