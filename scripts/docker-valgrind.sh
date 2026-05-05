#!/usr/bin/env bash
set -euo pipefail
# Собирает бинарь и прогоняет через valgrind.
# Использование: ./docker-valgrind.sh [бинарь] [флаги valgrind]
# Примеры:
#   ./docker-valgrind.sh
#   ./docker-valgrind.sh demo
#   ./docker-valgrind.sh demo --tool=helgrind
#   ./docker-valgrind.sh demo --tool=callgrind
source "$(dirname "$0")/docker-common.sh"

BIN="${1:-demo}"
shift || true
VALGRIND_FLAGS="${*:---leak-check=full --error-exitcode=1}"

ensure_container
docker exec -it "$CONTAINER" bash -c \
    "cargo build --bin ${BIN} && valgrind ${VALGRIND_FLAGS} ./target/debug/${BIN}"
