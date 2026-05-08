# Scripts

All `docker-*.sh` scripts run inside a shared Linux container (`broken-app-dev`). The container is created automatically on first run.

## Memory & thread analysis

| Command | What it does |
|---|---|
| `./docker-valgrind.sh` | Run `demo` binary under Valgrind (leak check) |
| `./docker-valgrind.sh demo --tool=helgrind` | Run with a different Valgrind tool |
| `./docker-valgrind.sh --tests` | Build & run all tests under Valgrind |
| `./docker-valgrind.sh --tests my_test` | Same, filtered by test name |
| `./docker-sanitize.sh asan` | Run tests with AddressSanitizer (default) |
| `./docker-sanitize.sh tsan` | Run tests with ThreadSanitizer |
| `./docker-sanitize.sh asan my_test` | ASan, filtered by test name |
| `./docker-miri.sh` | Run tests under Miri (UB detection) |
| `./docker-miri.sh my_test` | Miri, filtered by test name |

## Debugging

| Command | What it does |
|---|---|
| `./docker-lldb.sh` | Build `demo` and open it in `rust-lldb` |
| `./docker-lldb.sh my_bin` | Same for a different binary |
| `./docker-shell.sh` | Open a bash shell in the container |

## Profiling & benchmarks

| Command | What it does |
|---|---|
| `./profile.sh` | Build release binary and profile with `perf` (Linux) |
| `./compare.sh` | Run benchmarks and compare before/after |
