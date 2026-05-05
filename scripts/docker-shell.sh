#!/usr/bin/env bash
set -euo pipefail
# Открывает bash в Linux-контейнере. При первом запуске создаёт контейнер
# и устанавливает valgrind, miri и lldb.
source "$(dirname "$0")/docker-common.sh"

ensure_container
exec docker exec -it "$CONTAINER" bash
