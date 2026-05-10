pub fn slow_dedup(values: &[u64]) -> Vec<u64> {
    let mut seen = std::collections::HashSet::new();
    let mut out: Vec<u64> = values.iter().copied().filter(|v| seen.insert(*v)).collect();
    out.sort_unstable();
    out
}

pub fn slow_fib(n: u64) -> u64 {
    if n <= 1 {
        return n;
    }
    let (mut a, mut b) = (0u64, 1u64);
    for _ in 2..=n {
        (a, b) = (b, a + b);
    }
    b
}
