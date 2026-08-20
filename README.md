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

### Notes

The image can be used stand-alone in docker by starting an interactive shell, however it is intended to be used as a ```devcontainer``` within Microsoft VS Code.  

#### Building The Image

>**IMPORTANT**:  You must download the Gowin EDA release package from (https://www.gowinsemi.com/en/support/download_eda/). 

The Gowin EDA tools are freely usable for non-commercial purposes but behind a registration/login screen.

Rename the download to ```Gowin.tar.gz``` and place it in the same folder as the ```build.sh``` script.

Run ```./build.sh``` to build the image.  
