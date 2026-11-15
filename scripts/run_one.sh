#!/bin/bash
set -euo pipefail
if [[ -z "${LEBENCH_DIR:-}" ]]; then
  echo "先执行 export LEBENCH_DIR=\$HOME/LEBench"
  exit 1
fi
cd "$LEBENCH_DIR"
make -C TEST_DIR
kern=$(uname -r)
stamp=$(date +%Y%m%d-%H%M%S)
outdir="$LEBENCH_DIR/results/raw/$kern"
mkdir -p "$outdir" "$LEBENCH_DIR/results/logs"
if [[ -w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
  echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null || true
fi

./TEST_DIR/OS_Eval 0 "$kern"

if [[ -f "$LEBENCH_DIR/output.${kern}.csv" ]]; then
    cp "$LEBENCH_DIR/output.${kern}.csv" "$outdir/${stamp}.csv"
elif [[ -f "$LEBENCH_DIR/output_file.csv" ]]; then
    cp "$LEBENCH_DIR/output_file.csv" "$outdir/${stamp}.csv"
else
    echo "警告: 跑完了，但没找到任何生成的 csv 文件！"
    exit 1
fi

echo "结果已保存: $outdir/${stamp}.csv"
