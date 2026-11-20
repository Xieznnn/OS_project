#!/bin/bash
set -euo pipefail
MODE="${1:?用法: bash scripts/run_thp.sh never 或 always}"
if [[ "$MODE" != "never" && "$MODE" != "always" ]]; then
  echo "只能是 never 或 always"
  exit 1
fi
if [[ -z "${LEBENCH_DIR:-}" ]]; then
  echo "先执行 export LEBENCH_DIR=/root/LEBench"
  exit 1
fi
repo_root=$(cd "$(dirname "$0")/.." && pwd)
echo "$MODE" | tee /sys/kernel/mm/transparent_hugepage/enabled
ACTUAL=$(cat /sys/kernel/mm/transparent_hugepage/enabled)
echo "当前设置: $ACTUAL"
case "$MODE" in
  never)  [[ "$ACTUAL" == *"[never]"* ]] || { echo "没有切到 never"; exit 1; } ;;
  always) [[ "$ACTUAL" == *"[always]"* ]] || { echo "没有切到 always"; exit 1; } ;;
esac
cd "$LEBENCH_DIR"
make -C TEST_DIR
kern=$(uname -r)
stamp=$(date +%Y%m%d-%H%M%S)
outdir="$repo_root/results/raw/${kern}-thp-${MODE}"
mkdir -p "$outdir"
{
  date
  echo "mode_requested=$MODE"
  echo "thp_enabled=$(cat /sys/kernel/mm/transparent_hugepage/enabled)"
  uname -a
} | tee "$outdir/${stamp}.env.txt"
./TEST_DIR/OS_Eval 0 "$kern"
cp "$LEBENCH_DIR/output.${kern}.csv" "$outdir/${stamp}.csv"
echo "保存到 $outdir/${stamp}.csv"
