# CS340 Course Project - Reproducing LEBench (SOSP'19)

Reproduction of two claims from:

> Xiang (Jenny) Ren, Kirk Rodrigues, Luyuan Chen, et al.
> *An Analysis of Performance Evolution of Linux's Core Operations.* SOSP 2019.

- Paper: <https://www.eecg.toronto.edu/~stumm/Papers/Ren-sosp-19.pdf>
- Upstream benchmark: <https://github.com/LinuxPerfStudy/LEBench>
- Upstream experiment notes: <https://github.com/LinuxPerfStudy/LEBench/blob/master/EXPERIMENTS.md>

## 1. Claims under test

1. **Figure 1(a)**: with Linux 4.0 as the baseline, many core operations became
   slower in later kernels. Positive percentages mean slower than the baseline.
2. **Section 4.1.1 (KPTI, the Meltdown patch)**: kernel page-table isolation adds
   system-call latency. The paper reports roughly 22% averaged over all
   micro-benchmarks, roughly 59% for `read` and roughly 63% for `recv`.

Scope is reduced from the paper: it measures 41 kernels (3.0 to 4.20), we measure
about 5. Application benchmarks (Redis, Apache, Nginx) are out of scope.

## 2. Environment

| Item | Value |
|---|---|
| Host machine | Alibaba Cloud ECS, Intel Xeon 6982P-C (4 cores, 8 vCPU) |
| Virtualisation | KVM (`systemd-detect-virt` reports `kvm`) |
| Guest OS | Ubuntu 22.04.5 LTS (deviation D2: the paper used 16.04) |
| vCPU / RAM | 8 vCPU, 14 GiB, 40 GiB root disk |
| gcc | gcc (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0 |
| Kernel when repository was created | 5.15.0-198-generic |
| Kernels measured | TODO: one `uname -r` per kernel |
| Baseline kernel | TODO: closest bootable kernel to 4.0 |
| Upstream commit | see `docs/upstream-commit.txt` |

The paper's absolute times come from an HP DL160 G9 with a 2.40 GHz Xeon E5-2630 v3
and 128 GB DDR4. Our absolute times will never match. Every comparison in this
repository is a **percentage relative to the baseline kernel**, or KPTI-on versus
KPTI-off on the same kernel.

Differences from the paper are tabulated in `docs/deviations.md`.

## 3. Dependencies

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y build-essential git wget ca-certificates python3
```

Record `gcc --version` and the guest OS release into `results/env/`.

## 4. Reproducing a single measurement

Measurements run from the clone at `$LEBENCH_DIR`, not from the copy inside this
repository, so that the repository stays clean.

```bash
git clone https://github.com/LinuxPerfStudy/LEBench.git "$HOME/LEBench"
export LEBENCH_DIR=$HOME/LEBench
sudo -E bash scripts/run_one.sh
```

The script builds `TEST_DIR/OS_Eval` and runs it as
`./TEST_DIR/OS_Eval 0 "$(uname -r)"`. It writes
`$LEBENCH_DIR/output.<kernel>.csv` and copies it to
`$LEBENCH_DIR/results/raw/<kernel>/<timestamp>.csv`.

Runtime per kernel is 20 to 70 minutes on our hardware (TODO: record the measured
time for each kernel). The first minute has no output because the program calls
`sleep(60)`.

Each kernel is measured **three times**, each run after a fresh boot into that
kernel, with no other workload on the machine.

## 5. Aggregating results

```bash
export LEBENCH_DIR=$HOME/LEBench
python3 scripts/summarize.py
```

This reads every `results/raw/<kernel>/*.csv`, keeps the `kbest:` values and writes
`results/summary.csv` with `test, kernel, n, mean_sec, stdev_sec`.

The percentage used everywhere is

```text
change(%) = (mean kbest of this kernel - mean kbest of baseline) / mean kbest of baseline x 100
```

## 6. What we deliberately do not run

`sudo python run.py` from upstream is **not** used. It rewrites GRUB and runs
`grub-install --force` against `/dev/sda1`, which can destroy the boot loader of the
machine. We select kernels from the GRUB menu by hand and run `TEST_DIR/OS_Eval`
directly. This is recorded in `docs/deviations.md`.

## 7. Repository layout

```text
README.md
NOTICE.md
LICENSE-LEBench
docs/upstream-commit.txt
docs/deviations.md
scripts/run_one.sh
scripts/summarize.py
results/env/<kernel>.txt
results/raw/<kernel>/<timestamp>.csv
results/summary.csv
results/logs/
LEBench/                 upstream snapshot, its own .git removed
report/                  final English PDF
```

`.gitignore` excludes the compiled binary, kernel `.deb` files, ISOs and disk images.
No file in this repository exceeds 50 MB.
