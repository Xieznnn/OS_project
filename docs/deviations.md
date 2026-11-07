# Deviations from the paper

Four columns: item, what the paper did, what we did, why.

| Item | Paper | Ours | Reason |
|---|---|---|---|
| Machine (D1) | HP DL160 G9, Xeon E5-2630 v3 @2.40 GHz, 128 GB DDR4, bare metal | Alibaba Cloud ECS, Intel Xeon 6982P-C, 8 vCPU, 14 GiB, `systemd-detect-virt` = kvm | The course's VirtualBox lab machine was not available to us; a KVM cloud instance is the same class of virtualisation, and the machine is disposable if a kernel bricks it |
| User space (D2) | Ubuntu 16.04.6 LTS, glibc 2.23 | Ubuntu 22.04.5 LTS, glibc 2.35, gcc 11.4 | The provider no longer offers 16.04 images. LEBench measures kernel time, so glibc only changes the syscall wrapper cost; the effect is small but not zero |
| Kernel count (D3) | 41 kernels, 3.0 to 4.20 | TODO: list the kernels actually installed and booted | Course allows a reduced scope; 41 x 3 runs is not feasible before the deadline |
| Baseline (D4) | Linux 4.0 | TODO: oldest kernel that boots, ideally 4.4.5 | TODO: record the failure symptoms if 4.0 or 4.4 cannot boot on this hardware |
| Kernel selection (D5) | `run.py` reboots and switches kernels automatically | manual selection in the GRUB menu, then run `TEST_DIR/OS_Eval` | `run.py` runs `grub-install --force` against `/dev/sda1` and can destroy the boot loader |
| Meltdown / PTI (D6) | Xeon E5-2630 v3, affected by Meltdown; the paper isolated PTI by rebuilding without `CONFIG_PAGE_TABLE_ISOLATION` | `meltdown: Not affected` on this CPU, so PTI is not enabled at all; `nopti` has no effect | There is no KPTI overhead to measure on this hardware. Claim 2 is reported as inconclusive and this deviation explains why |
| Extension (D7) | rebuild with the isolated feature turned off | transparent huge pages switched at run time, `always` vs `never` | D6 removes the KPTI experiment; THP is one of the 11 causes the paper lists and is a single runtime switch here |
| CPU frequency (D8) | fixed 2.40 GHz | `cpufreq` not exposed inside the VM | Frequency is decided by the hypervisor and cannot be pinned |
| Measurement noise (D9) | dedicated bare metal | shared vCPU cloud instance | Neighbouring load can perturb microsecond measurements; every kernel is measured 3 times and reported as mean + stdev |
