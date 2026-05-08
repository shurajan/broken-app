#!/usr/bin/env bash
set -euo pipefail
# Запускает тесты под AddressSanitizer или ThreadSanitizer.
# Использование: ./docker-sanitize.sh [asan|tsan] [фильтр_теста]
# Примеры:
#   ./docker-sanitize.sh
#   ./docker-sanitize.sh tsan
#   ./docker-sanitize.sh asan test_name
source "$(dirname "$0")/docker-common.sh"

MODE="${1:-asan}"
shift || true

case "$MODE" in
    asan) SANITIZER="address" ;;
    tsan) SANITIZER="thread"  ;;
    *) echo "Неизвестный санитайзер: '$MODE'. Используйте asan или tsan." >&2; exit 1 ;;
esac

ensure_container
docker exec -it "$CONTAINER" bash -c "
set -euo pipefail
TARGET=\$(rustc +nightly -vV 2>/dev/null | grep '^host:' | cut -d' ' -f2)
rustup +nightly target add \"\$TARGET\" 2>/dev/null
echo \"==> RUSTFLAGS='-Z sanitizer=${SANITIZER}' cargo +nightly test --target \$TARGET $(printf '%q ' "$@")\"
RUSTFLAGS=\"-Z sanitizer=${SANITIZER}\" \
    cargo +nightly test --target \"\$TARGET\" $(printf '%q ' "$@")
"
