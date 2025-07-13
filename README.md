# DPDK Docker

Build images that contain built [DPDK](https://www.dpdk.org) library for
individual Ubuntu versions. An image will be tagged as:

```
<DPDK version>-<Ubuntu version>
```

For example, the image for DPDK *v23.11.3* that is built on Ubuntu *Jammy* will
be tagged as `23.11.3-jammy`.

Some pre-built images are available on
[Docker Hub](https://hub.docker.com/r/harku/dpdk).

## NVIDIA MLX5 Common Driver

To build/use an image with
[MLX5 driver](https://doc.dpdk.org/guides-23.11/platform/mlx5.html), you must
ensure that kernel modules `mlx5_core`, `mlx5_ib`, `ib_uverbs` have been loaded
in your host.

```
modprobe -a mlx5_core mlx5_ib ib_uverbs
```

## Build Example

Build DPDK v23.11.3 for Ubuntu 22.04 (Jammy):

```bash
make image DPDK_VER=23.11.3 UBUNTU_VER=jammy
```

## Usage Example

Run [Testpmd](https://doc.dpdk.org/guides-23.11/testpmd_app_ug/index.html) for DPDK-compatible NICs:

```bash
docker run -it --rm --privileged \
    --network host \
    -v /dev/hugepages:/dev/hugepages \
    -v /mnt/huge:/mnt/huge \
    harku/dpdk:23.11.3-jammy \
    dpdk-testpmd -l 0-3 -n 2 -- -i
```

Run [Testpmd](https://doc.dpdk.org/guides-23.11/testpmd_app_ug/index.html) for
`eth0` interface in a container using
[AF_XDP PMD](https://doc.dpdk.org/guides-23.11/nics/af_xdp.html):

```bash
docker run -it --rm --privileged \
    -v /dev/hugepages:/dev/hugepages \
    -v /mnt/huge:/mnt/huge \
    harku/dpdk:23.11.3-jammy \
    dpdk-testpmd --vdev=net_af_xdp0,iface=eth0 -l 0-3 -n 2 -- -i
```
