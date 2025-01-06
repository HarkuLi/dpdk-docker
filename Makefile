REPO := harku/dpdk
DPDK_VER := 23.11.3
UBUNTU_VER := jammy

.PHONY: image
image:
	docker build \
		--build-arg DPDK_VER=${DPDK_VER} \
		--build-arg UBUNTU_VER=${UBUNTU_VER} \
		-t "${REPO}:${DPDK_VER}-${UBUNTU_VER}" .
