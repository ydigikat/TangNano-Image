# Gowin EDA toolchain

This project builds a docker image for development Gowin FPGA based projects.

It includes the following tools:

| Tool | Purpose |
| ---- | ------- |
| Ubuntu 22.04 LTS core | OS Version specified by Gowin |
| Build Tools | C/C++ x86 native compiler and tools |
| Gowin EDA | FPGA development |
| OpenFPGALoader | Flashing / Programming devices |
| slang | LSP (language support) and linting |
| verilator | SystemVerilog code formatting (not LSP) |
| iverilog | Simulation / testbenches |
| GNU riscv64 | GCC cross compiler for pivorv32 soft-core|

#### Building The Image

Run ```./build.sh``` to build the image.  

If you get a 404 error from any downloads then likely the target filename (usually release version number) has changed.  Check for an updated release.