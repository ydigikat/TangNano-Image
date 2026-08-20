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

# Package URLs
ARG CMAKE_PKG=https://github.com/Kitware/CMake/releases/download/v4.4.2/cmake-4.4.2-linux-x86_64.sh
ARG LOADER_PKG=https://github.com/trabucayre/openFPGALoader/releases/download/v1.1.1/ubtuntu22.04-openFPGALoader.tgz
ARG VERIBLE_PKG=https://github.com/chipsalliance/verible/releases/download/v0.0-4128-gce6d8b4b/verible-v0.0-4128-gce6d8b4b-linux-static-x86_64.tar.gz
ARG RISCV_PKG=https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz


# -------------------------------------------------------------------
# Install software dependencies
# -------------------------------------------------------------------
RUN apt-get update

# These are needed for the Gowin tooling, best to let them install
# the full packages to avoid dependency issues so not using
# --no-install-recommends flag.  Annoyingly even if we're not using the
# Gowin IDE, QT is still needed for the CLI tools.  A benefit of installing
# QT is that you can run the IDE from the container if so desired.
RUN apt-get install -y \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    libqt5widgets5 libqt5gui5 libqt5core5a libqt5x11extras5
    
# Other tools and library dependencies.  These are needed at
# runtime by tooling that doesn't include them in its own package.    
RUN apt-get install -y --no-install-recommends ca-certificates \
    build-essential git zip wget ninja-build \
    libxcb-xinerama0 libxcb-cursor0 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 \
    libnss3 libasound2 pkg-config libftdi1-2 libftdi1-dev libhidapi-hidraw0 \
    libhidapi-dev libudev-dev zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev \
    libexpat1-dev

    
# -------------------------------------------------------------------    
# Install Gowin EDA from local copy
# -------------------------------------------------------------------
COPY Gowin.tar.gz .

RUN mkdir /opt/gowin/ && tar xvf Gowin.tar.gz -C /opt/gowin && rm Gowin.tar.gz && \
    mv /opt/gowin/IDE/bin/qt.conf /opt/gowin/IDE/bin/qt.orig && \
    echo "[Paths]\n\rPlugins=/usr/lib/x86_64-linux-gnu/qt5/plugins/" > /opt/gowin/IDE/bin/qt.conf 

ENV PATH="/opt/gowin/IDE/bin:${PATH}"

# -------------------------------------------------------------------
# CMake
# -------------------------------------------------------------------
RUN wget ${CMAKE_PKG} -nv -O cmake.sh && \
    chmod +x cmake.sh && ./cmake.sh --skip-license --prefix=/usr/local --exclude-subdir && rm cmake.sh

# -------------------------------------------------------------------
# Install openFPGALoader, this replaces the Gowin programmer 
# which does not work reliably on Linux.  This also means we can't use
# the Gowin analysis tools which require their programmer/cable support
# but fortunately we have open source alternatives.
# -------------------------------------------------------------------
RUN wget ${LOADER_PKG} -nv -O openFPGALoader.tgz && \
    tar -xvf openFPGALoader.tgz && rm openFPGALoader.tgz

# -------------------------------------------------------------------
# Verible. Used only for formatting
# -------------------------------------------------------------------
RUN wget ${VERIBLE_PKG} -nv -O verible.tar.gz && \
    tar -xvzf verible.tar.gz && chmod +x  verible*/* && cp verible*/bin/* /usr/local/bin && rm verible.tar.gz

# -------------------------------------------------------------------
# GCC RISC-V cross compiler
# -------------------------------------------------------------------
RUN wget -q  ${RISCV_PKG} -nv -O riscv.tar.gz && \
    tar -xzf riscv.tar.gz -C /opt && mv /opt/xpack-riscv* /opt/riscv-none-elf && rm riscv.tar.gz

# -------------------------------------------------------------------
# iVerilog
# -------------------------------------------------------------------
RUN apt-get install iverilog
    

# -------------------------------------------------------------------    
# Set permissions on gowin EDA
# -------------------------------------------------------------------
RUN find /opt/gowin -type d -exec chmod a+rx {} \; && \
    find /opt/gowin -type f -exec chmod a+r {} \; && \
    find /opt/gowin/IDE/bin -type f -exec chmod a+rx {} \; || true

RUN rm -rf /var/lib/apt/lists/*