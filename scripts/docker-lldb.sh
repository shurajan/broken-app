#!/usr/bin/env bash
set -euo pipefail
# Собирает бинарь с отладочными символами и запускает rust-lldb.
# Использование: ./docker-lldb.sh [бинарь]
# Пример:        ./docker-lldb.sh demo
source "$(dirname "$0")/docker-common.sh"

BIN="${1:-demo}"
ensure_container
docker exec -it "$CONTAINER" bash -c "cargo build --bin ${BIN} && rust-lldb ./target/debug/${BIN}"
