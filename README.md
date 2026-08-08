# Gowin EDA toolchain

This project builds a docker container that can be used for development of my Gowin FPGA based projects.

> IMPORTANT:  You must download the Gowin EDA tar and save it in the same folder as the build.sh script before building the container. While it is free to use, it is behind a registration process.  The build expects this to be named ```Gowin.tar.gz```

I install the following tools and dependencies, in many cases I only use the tool for part of its full capabilities.

| Tool | What I use it for |
| ---- | ------- |
| Ubuntu 22.04 LTS core | The Linux operating system |
| Build Tools | C/C++ x86 native compiler and tools |
| Gowin EDA | FPGA development |
| OpenFPGALoader | Flashing / Programming devices |
| slang | LSP (language support) and linting |
| verilator | SystemVerilog code formatting (not LSP) |
| GNU RISC-V | Cross compiler for pivorv32 soft-core|

run  ```./build.sh``` to build the container.  

### Notes

> Don't forget to download the Gowin package first.

The container can be used stand-alone in docker, however it is intended for use as a devcontainer in Microsoft VS Code.  Most of my projects include a ```.devcontainer``` configuration.   You can download and build one of these using VS Code to check that the container is working once built.  The devcontainer will add VS code specific support to the docker image when the project is first opened. 

#### Building The Container

The container build can take some time since most of the tools are built from their source code, I've found this more reliable than using the packages provided with the OS which are usually quite old.  The picorv32 specifies a particular branch of the RISC-V toolchain as being compatible, I suspect other later branches are but will follow their guidance which means building a specific version from the source, this takes a while.

In broad terms the build goes through the following steps:

1. Install Ubuntu 22.04 LTS (core)
2. Install Gowin EDA (local copy) and fetch required QT support.
3. Install tools, utilities and libs to support development and build of further tooling.
4. Install newer version of cmake (release package)
5. Install openFPGALoader (from source)
6. Optional: slang (you don't need this if using as a vscode .devcontainer, see build.sh)
7. Install verible (release package)
8. Build the GCC RISC-V compiler from source (slow)

The GCC build from source is the most likely to fail so is placed after all the other steps so that a failure doesn't require the entire container to be rebuilt.  The GCC build is a bit of a mess, it seems to add lots of modules from other git repositories and sources some of which are no longer extant and others which time out.  You may have to try a few times before you can even clone the repo for a build.

#### Windows Support
The container can be used on MS Windows if you have desktop container support, Docker Desktop or Rancher for example.  
