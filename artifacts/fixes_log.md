
## Результаты запуска на приложении до доработок

```bash
cargo check
```

###### Результат check до модификации
```
warning[E0133]: dereference of raw pointer is unsafe and requires unsafe block
--> src/lib.rs:60:15
|
60 |     let val = *raw;
|               ^^^^ dereference of raw pointer
|
= note: raw pointers may be null, dangling or unaligned; they can violate aliasing rules and cause data races: all of these are undefined behavior
note: an unsafe function restricts its caller, but its body is safe by default
--> src/lib.rs:57:1
|
57 | pub unsafe fn use_after_free() -> i32 {
| ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
= note: for more information, see <https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html>
= note: `#[warn(unsafe_op_in_unsafe_fn)]` (part of `#[warn(rust_2024_compatibility)]`) on by default

warning[E0133]: call to unsafe function `std::boxed::Box::<T>::from_raw` is unsafe and requires unsafe block
--> src/lib.rs:61:10
|
61 |     drop(Box::from_raw(raw));
|          ^^^^^^^^^^^^^^^^^^ call to unsafe function
|
= note: consult the function's documentation for information on how to avoid undefined behavior
= note: for more information, see <https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html>

warning[E0133]: dereference of raw pointer is unsafe and requires unsafe block
--> src/lib.rs:62:11
|
62 |     val + *raw
|           ^^^^ dereference of raw pointer
|
= note: raw pointers may be null, dangling or unaligned; they can violate aliasing rules and cause data races: all of these are undefined behavior
= note: for more information, see <https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html>

For more information about this error, try `rustc --explain E0133`.
warning: `broken-app` (lib) generated 3 warnings (run `cargo fix --lib -p broken-app` to apply 1 suggestion)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
```

```bash
cargo test
```
###### Результат запуска тестов до модификации
```
running 6 tests
test counts_non_zero_bytes ... ok
test averages_only_positive ... FAILED
test fib_small_numbers ... ok
test dedup_preserves_uniques ... ok
test normalize_simple ... ok

thread 'sums_even_numbers' (1204) panicked at src/lib.rs:11:29:
unsafe precondition(s) violated: slice::get_unchecked requires that the index is within the slice

This indicates a bug in the program. This Undefined Behavior check is optional, and cannot be relied on for safety.
thread caused non-unwinding panic. aborting.
error: test failed, to rerun pass `--test integration`

Caused by:
process didn't exit successfully: `/app/target/debug/deps/integration-332043ffe63b7964` (signal: 6, SIGABRT: process abort signal)
```

```bash
cargo +nightly miri test
```

###### Результат запуска miri тестов до модификации
```
running 6 tests
test averages_only_positive ... FAILED
test counts_non_zero_bytes ... ok
test dedup_preserves_uniques ... ok
test fib_small_numbers ... ok
test normalize_simple ... ok
test sums_even_numbers ... error: Undefined Behavior: `assume` called with `false`
--> src/lib.rs:11:22
|
11 |             let v = *values.get_unchecked(idx);
|                      ^^^^^^^^^^^^^^^^^^^^^^^^^ Undefined Behavior occurred here
|
= help: this indicates a bug in the program: it performed an invalid operation, and caused Undefined Behavior
= help: see https://doc.rust-lang.org/nightly/reference/behavior-considered-undefined.html for further information
= note: this is on thread `sums_even_numbe`
= note: stack backtrace:
0: broken_app::sum_even
at src/lib.rs:11:22: 11:47
1: sums_even_numbers
at tests/integration.rs:7:16: 7:31
2: sums_even_numbers::{closure#0}
at tests/integration.rs:4:23: 4:23

note: some details are omitted, run with `MIRIFLAGS=-Zmiri-backtrace=full` for a verbose backtrace

error: aborting due to 1 previous error

error: test failed, to rerun pass `--test integration`

Caused by:
process didn't exit successfully: `/usr/local/rustup/toolchains/nightly-aarch64-unknown-linux-gnu/bin/cargo-miri runner /app/target/miri/aarch64-unknown-linux-gnu/debug/deps/integration-8b18f0d975fb3dac` (exit status: 1)
note: test exited abnormally; to see the full output pass --no-capture to the harness.
```

###### Результат запуска valgrind, ASan, TSan тестов до модификации
тесты не проходят


## Исправление логики
###### sum_even
Исправлена ошибка выхода за границы среза и убран ненужный unsafe блок
Добавлены тесты:
* test sum_even_all_evens ... ok
* test sum_even_empty_slice ... ok
* test sum_even_negative_evens ... ok
* test sum_even_no_evens ... ok

###### average_positive
Исправлена логика и добавлены тесты:
* test average_positive_empty ... ok
* test average_positive_single_element ... ok
* test average_positive_no_positives ... ok

###### normalize
Исправлено логика и добавлены тесты:
* test normalize_empty ... ok
* test normalize_no_whitespace ... ok
* test normalize_multiple_spaces ... ok
* test normalize_tabs_and_newlines ... ok

