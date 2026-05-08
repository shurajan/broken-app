#!/usr/bin/env bash
set -euo pipefail
# Собирает бинарь или тесты и прогоняет через valgrind.
# Использование: ./docker-valgrind.sh [бинарь] [флаги_valgrind]
#                ./docker-valgrind.sh --tests [фильтр_теста] [флаги_valgrind]
# Примеры:
#   ./docker-valgrind.sh
#   ./docker-valgrind.sh demo
#   ./docker-valgrind.sh demo --tool=helgrind
#   ./docker-valgrind.sh demo --tool=callgrind
#   ./docker-valgrind.sh --tests
#   ./docker-valgrind.sh --tests my_test
source "$(dirname "$0")/docker-common.sh"

if [[ "${1:-}" == "--tests" ]]; then
    shift
    TEST_FILTER="${1:-}"
    [[ $# -gt 0 ]] && shift || true
    VALGRIND_FLAGS="${*:---leak-check=full --error-exitcode=1}"
    ensure_container
    docker exec -it "$CONTAINER" bash -c "
set -euo pipefail
BINS=\$(cargo test --no-run --message-format=json 2>/dev/null \
    | grep -o '\"executable\":\"[^\"]*\"' | cut -d'\"' -f4)
if [[ -z \"\$BINS\" ]]; then echo 'Ошибка: тестовые бинари не найдены.' >&2; exit 1; fi
FAILED=0
while IFS= read -r BIN; do
    echo \"==> valgrind \$BIN ${TEST_FILTER}\"
    valgrind ${VALGRIND_FLAGS} \"\$BIN\" ${TEST_FILTER} || FAILED=1
done <<< \"\$BINS\"
exit \$FAILED
"
else
    BIN="${1:-demo}"
    shift || true
    VALGRIND_FLAGS="${*:---leak-check=full --error-exitcode=1}"
    ensure_container
    docker exec -it "$CONTAINER" bash -c \
        "cargo build --bin ${BIN} && echo '==> valgrind ${VALGRIND_FLAGS} ./target/debug/${BIN}' && valgrind ${VALGRIND_FLAGS} ./target/debug/${BIN}"
fi
