#!/usr/bin/env bash
set -euo pipefail
# Генерирует flamegraph через cargo-flamegraph + perf в привилегированном контейнере.
# Использование: ./docker-flamegraph.sh [бинарь] [папка_вывода]
# Примеры:
#   ./docker-flamegraph.sh
#   ./docker-flamegraph.sh demo before
source "$(dirname "$0")/docker-common.sh"

BIN="${1:-demo}"
OUT_DIR="${2:-before}"
OUTPUT="artifacts/${OUT_DIR}/flamegraph.svg"

mkdir -p "$PROJECT_DIR/artifacts/${OUT_DIR}"

echo "==> Генерирую flamegraph для '${BIN}' -> ${OUTPUT}"
docker run --rm \
    --privileged \
    -v "$PROJECT_DIR:/app" \
    -v "$TARGET_VOLUME:/app/target" \
    -v "broken-app-cargo-registry:/usr/local/cargo/registry" \
    -w /app \
    "$IMAGE" \
    bash -c "
set -euo pipefail

echo '==> Устанавливаю perf...'
apt-get update -qq && apt-get install -y -q linux-perf

echo '==> Устанавливаю cargo-flamegraph...'
cargo install flamegraph --quiet 2>&1 | tail -1

echo 0 > /proc/sys/kernel/perf_event_paranoid  || true
echo 0 > /proc/sys/kernel/kptr_restrict        || true

echo '==> Запускаю cargo flamegraph --bin ${BIN}...'
CARGO_PROFILE_RELEASE_DEBUG=true cargo flamegraph \
    --bin ${BIN} \
    -o ${OUTPUT}

echo '==> Готово: ${OUTPUT}'
"
echo "==> Файл сохранён: $PROJECT_DIR/$OUTPUT"
