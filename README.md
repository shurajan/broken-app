# broken-app

Учебный проект для практики отладки: Valgrind, miri, ASan, TSan и criterion.  
Код содержит намеренные ошибки — утечки памяти, UB, гонки данных, логические баги.

---

## Работы на Mac

Проще использовать Docker для отладки, так как инструменты сильно отличаются по поведению.

```bash
# Первый запуск: создаёт контейнер, устанавливает valgrind, miri и lldb (~5 мин)
./scripts/docker-shell.sh

# Запустить тесты через miri
./scripts/docker-miri.sh

# Запустить конкретный тест
./scripts/docker-miri.sh sums_even_numbers

# Запустить valgrind на бинаре demo
./scripts/docker-valgrind.sh

# Запустить с другим инструментом valgrind
./scripts/docker-valgrind.sh demo --tool=helgrind

# Запустить lldb-отладчик на бинаре demo
./scripts/docker-lldb.sh
```

Скрипты автоматически поднимают Linux-контейнер при необходимости.  
Код редактируется на Mac в RustRover — изменения сразу видны внутри контейнера.

---

## Структура проекта

```
src/
├── lib.rs           — sum_even, leak_buffer, normalize, average_positive, use_after_free
├── algo.rs          — slow_dedup, slow_fib
├── concurrency.rs   — race_increment, read_after_sleep
└── bin/demo.rs      — точка входа для ручного запуска

tests/
└── integration.rs   — интеграционные тесты (часть намеренно падает)

benches/
└── baseline.rs      — замеры производительности

scripts/
├── docker-common.sh — общий хелпер (источник для остальных)
├── docker-shell.sh    — интерактивный bash в контейнере
├── docker-miri.sh     — запуск тестов через miri
├── docker-valgrind.sh — сборка + valgrind
└── docker-lldb.sh     — сборка + интерактивный отладчик lldb
```

---

## Намеренные ошибки

### Undefined Behaviour (ловит miri и ASan)

| Функция | Ошибка |
|---|---|
| `sum_even` | `get_unchecked` с off-by-one: читает за границей среза |
| `use_after_free` | use-after-free: чтение после `drop(Box::from_raw(...))` |

### Утечки памяти (ловит Valgrind)

| Функция | Ошибка |
|---|---|
| `leak_buffer` | `Box::into_raw` без последующего `Box::from_raw` |

### Гонки данных (ловит miri)

| Функция | Ошибка |
|---|---|
| `race_increment` | `static mut COUNTER` инкрементируется из нескольких потоков без синхронизации |
| `read_after_sleep` | чтение `COUNTER` без барьера памяти, `sleep` не заменяет синхронизацию |

### Логические ошибки (падают тесты)

| Функция | Ошибка |
|---|---|
| `average_positive` | делит сумму на `values.len()` вместо количества положительных элементов |
| `normalize` | не схлопывает повторяющиеся пробелы внутри строки |

### Проблемы производительности (видны в бенчмарках)

| Функция | Проблема |
|---|---|
| `slow_fib` | рекурсия без мемоизации, экспоненциальная сложность |
| `slow_dedup` | сортировка на каждой вставке, O(n² log n) вместо O(n) |

---

## Рабочий процесс

### Интерактивная сессия

```bash
./scripts/docker-shell.sh   # открывает bash в Linux-контейнере

# Внутри контейнера:
cargo test                  # запустить все тесты
cargo run --bin demo        # запустить demo
cargo bench                 # бенчмарки
```

### miri — поиск UB и гонок

```bash
./scripts/docker-miri.sh                    # все тесты
./scripts/docker-miri.sh sums_even_numbers  # один тест
```

Внутри контейнера можно также:
```bash
cargo +nightly miri run --bin demo
```

### Valgrind — утечки памяти

```bash
./scripts/docker-valgrind.sh                          # memcheck (по умолчанию)
./scripts/docker-valgrind.sh demo --tool=helgrind      # гонки потоков
./scripts/docker-valgrind.sh demo --tool=callgrind     # профилировщик вызовов
```

### lldb — интерактивный отладчик

```bash
./scripts/docker-lldb.sh          # demo (по умолчанию)
./scripts/docker-lldb.sh demo     # явно указать бинарь
```

Основные команды внутри сессии lldb:

```
b main               # точка останова на функции
b src/lib.rs:10      # точка останова на строке
run                  # запустить программу
n                    # следующая строка (step over)
s                    # шаг внутрь функции (step in)
p my_var             # вывести значение переменной
bt                   # backtrace стека вызовов
q                    # выйти
```

### AddressSanitizer (ASan)

Внутри контейнера:
```bash
RUSTFLAGS="-Z sanitizer=address" cargo +nightly run --target x86_64-unknown-linux-gnu --bin demo
```

---

## Управление контейнером

```bash
# Посмотреть статус
docker ps -a --filter name=broken-app-dev

# Удалить контейнер (при следующем запуске пересоздастся)
docker rm -f broken-app-dev

# Удалить вместе с Linux-артефактами сборки
docker rm -f broken-app-dev && docker volume rm broken-app-linux-target
```

> Linux-артефакты сборки хранятся в отдельном Docker-volume `broken-app-linux-target`  
> и не смешиваются с macOS-сборкой в `target/`.
