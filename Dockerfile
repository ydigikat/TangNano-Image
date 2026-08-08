# -------------------------------------------------------------------
# Builds a docker container for building projects using the Gowin
# EDA toolset and RISC-V cross compiler.
# -------------------------------------------------------------------

# Ubuntu core (older LTS is better for Gowin tools)
FROM ubuntu:22.04

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Update package list
RUN apt-get update

# -------------------------------------------------------------------    
# Install the free Gowin EDA  - you must download a copy and place the
# tarred file in the container build folder as it is behind a login.
# -------------------------------------------------------------------

COPY Gowin.tar.gz .
RUN mkdir /opt/gowin/ && \    
    tar xvf Gowin.tar.gz -C /opt/gowin/
RUN rm Gowin.tar.gz

ENV PATH="/opt/gowin/IDE/bin:${PATH}"

# QT runtime support
RUN apt-get install -y \
qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
libqt5widgets5 libqt5gui5 libqt5core5a libqt5x11extras5

# Update the Gowin qt.conf to point to the local system plugins
RUN mv /opt/gowin/IDE/bin/qt.conf /opt/gowin/IDE/bin/qt.orig
RUN echo "[Paths]\n\rPlugins=/usr/lib/x86_64-linux-gnu/qt5/plugins/" > /opt/gowin/IDE/bin/qt.conf 

# -------------------------------------------------------------------
# Install dependencies needed to build and setup the other
# tooling.
# -------------------------------------------------------------------
# C/C++
RUN apt-get install -y \
    build-essential git \
    zip wget autoconf automake autotools-dev \
    gawk bison flex texinfo gperf libtool \
    patchutils bc ninja-build \
    libxcb-xinerama0 libxcb-cursor0 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 \
    libnss3 libasound2 pkg-config libftdi1-2 libftdi1-dev libhidapi-hidraw0 \
    libhidapi-dev libudev-dev zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev \
    libexpat1-dev

# -------------------------------------------------------------------
# Retrieve and install cmake.
# The bundled cmake in Ubuntu 22.04 LTS is too old for many of the
# builds so we need to update that first
# -------------------------------------------------------------------
RUN wget https://github.com/Kitware/CMake/releases/download/v4.4.2/cmake-4.4.2-linux-x86_64.sh -O cmake.sh    
RUN chmod +x cmake.sh && \
    ./cmake.sh --skip-license --prefix=/usr/local --exclude-subdir 
RUN rm cmake.sh

# -------------------------------------------------------------------
# Install openFPGALoader, this replaces the Gowin programmer 
# which does not work reliably on Linux.  This also means we can't use
# the Gowin analysis tools which require their programmer/cable support
# but fortunately we have open source alternatives.
# -------------------------------------------------------------------
RUN wget https://github.com/trabucayre/openFPGALoader/releases/download/v1.1.1/ubtuntu22.04-openFPGALoader.tgz -O openFPGALoader.tgz
RUN tar -xvf openFPGALoader.tgz   
RUN rm openFPGALoader.tgz

# -------------------------------------------------------------------
# Install slang.  This provides the language support package
# for the IDE, intellisense, linting etc.
#
# I leave this commented out as the VS code extension from HRT will
# install a local slang instance which is guaranteed to be aligned
# with the version needed by the extension.  You can uncomment this
# if you're using nvim or something else.
# -------------------------------------------------------------------    
# RUN git clone https://github.com/MikePopoloski/slang.git && \
#     cd slang && \
#     cmake -B build && \
#     cmake --build build -j 6 && \
#     cmake --install build --strip && \
#     cd / 

# -------------------------------------------------------------------
# Verible.  While this is also LSP and linter, I only use this for 
# code formatting in the IDE. slang does not provide this yet.
# -------------------------------------------------------------------
RUN wget https://github.com/chipsalliance/verible/releases/download/v0.0-4128-gce6d8b4b/verible-v0.0-4128-gce6d8b4b-linux-static-x86_64.tar.gz -O verible.tar.gz
RUN tar -xvzf verible.tar.gz && \
    chmod +x  verible*/* && \
    cp verible*/bin/* /usr/local/bin
RUN rm verible.tar.gz

# -------------------------------------------------------------------
# GCC RISC-V compiler (picorv32 core cross compiler) 
# -------------------------------------------------------------------
RUN wget -q  https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz -O riscv.tar.gz
RUN tar -xzf riscv.tar.gz -C /opt
RUN mv /opt/xpack-riscv-none-elf-gcc-14.2.0-3 /opt/riscv-none-elf
RUN rm riscv.tar.gz

# -------------------------------------------------------------------    
# Set permissions on gowin EDA
# -------------------------------------------------------------------
RUN find /opt/gowin -type d -exec chmod a+rx {} \; && \
    find /opt/gowin -type f -exec chmod a+r {} \; && \
    find /opt/gowin/IDE/bin -type f -exec chmod a+rx {} \; || true

# Leave us with an sudo capability    
RUN apt-get update && apt-get install -y --no-install-recommends sudo    

RUN test -f /usr/local/bin/slang || echo "NOTE: slang (optional) was not installed.  See README.md for more details."