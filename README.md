# Gowin EDA toolchain

This project builds a docker container that can be used for development of my Gowin FPGA based projects.

> IMPORTANT:  You must download the Gowin EDA tar file (https://www.gowinsemi.com/en/support/download_eda/) and save it in the same folder as the build.sh script before building the container. While it is free to use, it is behind a registration process.  The build expects this to be renamed ```Gowin.tar.gz```

I install the following tools and dependencies, in many cases I only use the tool for part of its full capabilities.

| Tool | What I use it for |
| ---- | ------- |
| Ubuntu 22.04 LTS core | The Linux operating system |
| Build Tools | C/C++ x86 native compiler and tools |
| Gowin EDA | FPGA development |
| OpenFPGALoader | Flashing / Programming devices |
| slang | LSP (language support) and linting |
| verilator | SystemVerilog code formatting (not LSP) |
| GNU riscv64 | GCC cross compiler for pivorv32 soft-core|

run  ```./build.sh``` to build the container.  

### Notes

> Don't forget to download the Gowin package first.

The container can be used stand-alone in docker, however it is intended for use as a devcontainer in Microsoft VS Code.  Most of my projects include a ```.devcontainer``` configuration.   You can download and build one of these using VS Code to check that the container is working once built.  

The devcontainer will add VS code specific support to the docker image when the project is first opened (zsh etc).

#### Building The Container

This container does not take too long to build as it mostly uses release packages.  These are fetched usign ```wget```, unpacked and copied to the correct locations.

In broad terms the build goes through the following steps:

1. Install Ubuntu 22.04 LTS (core)
2. Install x86 compiler tools, utilities and libraries needed for the subsequent steps.
2. Install Gowin EDA (from your local download) add install QT support.
4. Install cmake.
5. Install openFPGALoader.
6. Install verible 
8. Install riscv64 compiler tools.

#### Windows Support
The container can be used on MS Windows if you have desktop container support, Docker Desktop or Rancher for example.  
