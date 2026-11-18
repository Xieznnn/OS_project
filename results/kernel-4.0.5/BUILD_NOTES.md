# Linux 4.0.5 Kernel Build

## Contributor
- Name: Zhou Yihan
- Student ID: 1240007581
- GitHub: zyihan510

## Build environment
- OS: Ubuntu 20.04.6 LTS
- Architecture: x86_64
- Compiler: GCC 9.4.0
- Target kernel: Linux 4.0.5

## Compatibility adjustments
1. Created compiler-gcc9.h from the existing compiler-gcc5.h
   as a temporary compatibility workaround.
2. Disabled CONFIG_X86_X32.
3. Set CONFIG_BLK_DEV_NVME=y and CONFIG_VIRTIO_NET=y.
4. Added R_X86_64_PLT32 handling alongside R_X86_64_PC32
   in arch/x86/tools/relocs.c.
5. Built with KCFLAGS="-fno-pie -fno-stack-protector".

These are experimental compatibility changes, not an
upstream-supported GCC 9 port.

## Build command
make -j4 KCFLAGS="-fno-pie -fno-stack-protector" bzImage

## Result
- Kernel version: 4.0.5
- Build exit code: 0
- bzImage generated successfully
- Image size: approximately 8.4 MB

## Validation status
- Compilation: PASSED
- Boot test: NOT PERFORMED
- LEBench on Linux 4.0.5: NOT PERFORMED

The build log records the final successful incremental build.
The SHA-256 checksum is stored in sha256.txt.

## Safety note
This kernel has not been installed or boot-tested on the
Alibaba Cloud ECS server. The running kernel remains 5.4.0-42-generic.
