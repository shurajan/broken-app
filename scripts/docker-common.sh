#!/usr/bin/env bash
# Источник для остальных docker-*.sh скриптов, не запускать напрямую.

CONTAINER="broken-app-dev"
TARGET_VOLUME="broken-app-linux-target"
IMAGE="rust:latest"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_container() {
    if ! docker container inspect "$CONTAINER" &>/dev/null; then
        echo "==> Первый запуск: создаю контейнер и устанавливаю инструменты..."
        docker run -d \
            --name "$CONTAINER" \
            -v "$PROJECT_DIR:/app" \
            -v "$TARGET_VOLUME:/app/target" \
            -w /app \
            "$IMAGE" \
            sleep infinity
        docker exec "$CONTAINER" bash -c \
            "apt-get update -qq \
             && apt-get install -y -q valgrind lldb \
             && rustup toolchain install nightly \
             && rustup +nightly component add miri"
        echo "==> Готово."
    elif [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" = "false" ]; then
        docker start "$CONTAINER" > /dev/null
    fi
}
