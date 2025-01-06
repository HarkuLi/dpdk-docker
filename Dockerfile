ARG DPDK_VER="23.11.3"
ARG UBUNTU_VER="jammy"

FROM ubuntu:${UBUNTU_VER} AS builder

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        build-essential \
        libbpf-dev \
        libnuma-dev \
        pkg-config \
        python3-pip \
        python3-pyelftools \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson ninja

ARG DPDK_VER
ARG DPDK_SRC_DIR="/dpdk-src"
ARG DPDK_DIR="/dpdk"

RUN wget -O "/tmp/dpdk.tar.xz" "https://fast.dpdk.org/rel/dpdk-${DPDK_VER}.tar.xz" \
    && mkdir -p ${DPDK_SRC_DIR} ${DPDK_DIR} \
    && tar -xJf "/tmp/dpdk.tar.xz" -C ${DPDK_SRC_DIR} --strip-components=1 \
    && rm /tmp/dpdk.tar.xz \
    && cd ${DPDK_SRC_DIR} \
    && meson setup --prefix ${DPDK_DIR} build \
    && cd build \
    && ninja \
    && meson install

# ----- #

FROM ubuntu:${UBUNTU_VER} AS app

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        libatomic1 \
        libbpf-dev \
        libnuma-dev \
        python3 \
        python3-pyelftools \
    && rm -rf /var/lib/apt/lists/*

ARG DPDK_DIR="/dpdk"
ARG DPDK_LIB_DIR="${DPDK_DIR}/lib/x86_64-linux-gnu"

COPY --from=builder /dpdk ${DPDK_DIR}

RUN echo "${DPDK_LIB_DIR}" > /etc/ld.so.conf.d/dpdk.conf \
    && ldconfig

ENV PATH="${PATH}:${DPDK_DIR}/bin"
ENV PKG_CONFIG_PATH="${DPDK_LIB_DIR}/pkgconfig"
