#!/usr/bin/env python3
import csv, glob, os, statistics, collections
root = os.environ["LEBENCH_DIR"]
groups = collections.defaultdict(lambda: collections.defaultdict(list))
for path in glob.glob(os.path.join(root, "results/raw/*/*.csv")):
    kern = os.path.basename(os.path.dirname(path))
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            if "kbest:" not in line:
                continue
            name, val = line.split("kbest:", 1)
            groups[name.strip()][kern].append(float(val.strip().strip(",")))

out = os.path.join(root, "results/summary.csv")
with open(out, "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["test", "kernel", "n", "mean_sec", "stdev_sec"])
    for test in sorted(groups):
        for kern in sorted(groups[test]):
            xs = groups[test][kern]
            sd = statistics.stdev(xs) if len(xs) > 1 else 0.0
            w.writerow([test, kern, len(xs), f"{statistics.mean(xs):.12f}", f"{sd:.12f}"])
print("wrote", out)
