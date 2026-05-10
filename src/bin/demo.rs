use broken_app::{algo, leak_buffer, normalize, sum_even};

fn main() {
    let nums: Vec<i64> = (0..500_000).collect();
    let dedup_data: Vec<u64> = (0..1_000).flat_map(|n| [n, n]).collect();

    for _ in 0..10_000 {
        std::hint::black_box(sum_even(&nums));
    }

    std::hint::black_box(algo::slow_fib(43));

    for _ in 0..10_000 {
        std::hint::black_box(algo::slow_dedup(&dedup_data));
    }

    println!("non-zero: {}", leak_buffer(&[1_u8, 0, 2, 3]));
    println!("normalize: {}", normalize(" Hello World "));
}
