use broken_app::{algo, concurrency, leak_buffer, normalize, sum_even, use_after_free};

#[test]
fn sums_even_numbers() {
    let nums = [1, 2, 3, 4];
    // Базовый случай: 2 + 4 = 6.
    assert_eq!(sum_even(&nums), 6);
}

#[test]
fn sum_even_empty_slice() {
    // Нет элементов — сумма должна быть 0 (нейтральный элемент сложения).
    assert_eq!(sum_even(&[]), 0);
}

#[test]
fn sum_even_no_evens() {
    // Все нечётные — нечего суммировать.
    assert_eq!(sum_even(&[1, 3, 5, 7]), 0);
}

#[test]
fn sum_even_all_evens() {
    // Все чётные — суммируются все.
    assert_eq!(sum_even(&[2, 4, 6]), 12);
}

#[test]
fn sum_even_negative_evens() {
    // Отрицательные чётные должны учитываться: -4 + 2 = -2.
    assert_eq!(sum_even(&[-4, -3, 1, 2]), -2);
}

#[test]
fn counts_non_zero_bytes() {
    let data = [0_u8, 1, 0, 2, 3];
    assert_eq!(leak_buffer(&data), 3);
}

#[test]
fn dedup_preserves_uniques() {
    let uniq = algo::slow_dedup(&[5, 5, 1, 2, 2, 3]);
    assert_eq!(uniq, vec![1, 2, 3, 5]); // порядок и состав важны
}

#[test]
fn fib_small_numbers() {
    assert_eq!(algo::slow_fib(10), 55);
}

#[test]
fn normalize_simple() {
    assert_eq!(normalize(" Hello World "), "helloworld");
}

#[test]
fn normalize_simple_multiple_spaces() {
    assert_eq!(normalize(" Hello   World "), "helloworld");
}

#[test]
fn normalize_tabs_and_newlines() {
    // replace(' ', "") пропускает \t и \n — is_whitespace() покрывает все виды пробелов.
    assert_eq!(normalize("Hello\tWorld\n"), "helloworld");
}

#[test]
fn normalize_empty() {
    assert_eq!(normalize(""), "");
}

#[test]
fn normalize_no_whitespace() {
    // Уже нормализованная строка не должна меняться.
    assert_eq!(normalize("hello"), "hello");
}

#[test]
fn averages_only_positive() {
    let nums = [-5, 5, 15];
    // Ожидается (5 + 15) / 2 = 10, но текущая реализация делит на все элементы.
    assert!((broken_app::average_positive(&nums) - 10.0).abs() < f64::EPSILON);
}

#[test]
fn average_positive_empty() {
    // Нет элементов — возвращаем 0.0, чтобы не делить на ноль.
    assert_eq!(broken_app::average_positive(&[]), 0.0);
}

#[test]
fn average_positive_no_positives() {
    // Нет положительных значений — делитель был бы 0, должен вернуть 0.0.
    assert_eq!(broken_app::average_positive(&[-3, -1, 0]), 0.0);
}

#[test]
fn average_positive_single_element() {
    // Среднее из одного элемента равно самому элементу.
    assert!((broken_app::average_positive(&[7]) - 7.0).abs() < f64::EPSILON);
}

#[test]
fn use_after_free_test() {
    assert_eq!(use_after_free(), 84);
}

// --- concurrency tests (intentional data races — TSan triggers) ---

#[test]
fn race_increment_data_race() {
    let _ = concurrency::race_increment(100, 4);
}

#[test]
fn read_after_sleep_stale_read() {
    concurrency::race_increment(50, 2);
    let _ = concurrency::read_after_sleep();
}

#[test]
fn reset_counter_races_with_increment() {
    use std::thread;
    let h = thread::spawn(|| concurrency::race_increment(500, 4));
    concurrency::reset_counter();
    let _ = h.join();
}
