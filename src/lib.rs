pub mod algo;
pub mod concurrency;

pub fn sum_even(values: &[i64]) -> i64 {
    values.iter().copied().filter(|&v| v % 2 == 0).sum()
}

/// Подсчёт ненулевых байтов.
pub fn leak_buffer(input: &[u8]) -> usize {
    input.iter().filter(|&&b| b != 0).count()
}

pub fn normalize(input: &str) -> String {
    input
        .chars()
        .filter(|c| !c.is_whitespace())
        .collect::<String>()
        .to_lowercase()
}

pub fn average_positive(values: &[i64]) -> f64 {
    let (sum, count) = values
        .iter()
        .filter(|&&v| v > 0)
        .fold((0i64, 0usize), |(s, n), &v| (s + v, n + 1));
    if count == 0 {
        0.0
    } else {
        sum as f64 / count as f64
    }
}

pub fn use_after_free() -> i32 {
    let val = *Box::new(42_i32);
    val + val
}
