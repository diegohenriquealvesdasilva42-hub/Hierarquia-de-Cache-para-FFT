#!/usr/bin/env bash

# =========================================================
# Experimento Único — Sniper
# Variações:
# - Tamanho L1
# - Tamanho L2
# - Associatividade
# - Política (LRU / RANDOM)
# - Tamanho de linha
# =========================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

SNIPER_ROOT="${SNIPER_ROOT:-$HOME/sniper}"
FFT_BIN="${FFT_BIN:-$HOME/sniper/test/fft/fft}"

MAX_JOBS=$(($(nproc) * 2))
[ "$MAX_JOBS" -lt 1 ] && MAX_JOBS=1

info "Execuções paralelas: $MAX_JOBS"


if [ ! -f "$SNIPER_ROOT/run-sniper" ]; then
echo "[ERRO] run-sniper não encontrado em $SNIPER_ROOT"
exit 1
fi

if [ ! -f "$FFT_BIN" ]; then
echo "[ERRO] FFT não encontrado em $FFT_BIN"
echo "Compile com:"
echo "cd ~/sniper/test/fft"
echo "make"
exit 1
fi

BASE_RESULTS="$(pwd)/results/exp_final"
mkdir -p "$BASE_RESULTS"

info "Iniciando experimento completo"

declare -A LOG2=(["16"]=4 ["32"]=5 ["64"]=6 ["128"]=7 ["256"]=8)

for POLICY in lru random; do
for ASSOC in 1 2 4 8; do
for L1 in 16 32 64 128; do
for L2 in 256 512 1024 2048; do
for LS in 16 32 64 128; do

(
L="${LOG2[$LS]}"

OUT="$BASE_RESULTS/p${POLICY}_a${ASSOC}_l1${L1}_l2${L2}_ls${LS}"
mkdir -p "$OUT"

info "Policy=$POLICY Assoc=$ASSOC L1=$L1 L2=$L2 Line=$LS"

cmd=(
"$SNIPER_ROOT/run-sniper"
-c gainestown
-n 1
-d "$OUT"
-g perf_model/l1_dcache/cache_size=$L1
-g perf_model/l1_icache/cache_size=$L1
-g perf_model/l2_cache/cache_size=$L2
-g perf_model/l1_dcache/associativity=$ASSOC
-g perf_model/l1_icache/associativity=$ASSOC
-g perf_model/l2_cache/associativity=8
-g perf_model/l1_dcache/replacement_policy=$POLICY
-g perf_model/l1_icache/replacement_policy=$POLICY
-g perf_model/l2_cache/replacement_policy=$POLICY
-g perf_model/l1_dcache/data_block_size=$LS
-g perf_model/l1_icache/data_block_size=$LS
-g perf_model/l2_cache/data_block_size=$LS
--
"$FFT_BIN"
-m16
-p1
-l"$L"
)

"${cmd[@]}" > "$OUT/stdout.txt" 2>&1 || true

if [ -f "$OUT/sim.out" ]; then
IPC=$(grep -i IPC "$OUT/sim.out" | head -1 | awk '{print $NF}')
success "IPC=$IPC"
else
warn "Falha"
fi

) &

while [ "$(jobs -r | wc -l)" -ge "$MAX_JOBS" ]; do
sleep 1
done

done
done
done
done
done

wait

success "Experimento finalizado"
info "Resultados em: $BASE_RESULTS"
