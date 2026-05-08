#!/usr/bin/env bash
set -euo pipefail
# Использование: ./docker-miri.sh [фильтр_теста]
source "$(dirname "$0")/docker-common.sh"

ensure_container
echo "==> cargo +nightly miri test $*"
docker exec -it "$CONTAINER" cargo +nightly miri test "$@"
