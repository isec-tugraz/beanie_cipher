use clap::{Parser, Subcommand};
use indicatif::ProgressBar;
use io::Write;
use std::collections::HashMap;
use std::collections::hash_map::Entry;
use std::io;
use std::ops::Sub;

use rand::Rng;

const BLOCK_SIZE: u32 = 32;

type Block = u32;

fn measure_diff_prob(f: impl Fn(Block) -> Block, alpha: Block, beta: Block, trials: u64) -> u64 {
    let mut successes = 0u64;

    let mut rng = rand::rng();
    for _ in 0..trials {
        let pt: Block = rng.random();
        if f(pt) ^ f(pt ^ alpha) == beta {
            successes += 1;
        }
    }

    successes
}

fn describe_differential(f: impl Fn(Block) -> Block, alpha: Block, beta: Block, trials: u64) {
    let diff_prob = (measure_diff_prob(f, alpha, beta, trials) as f64) / (trials as f64);
    println!(
        "{:08x} -> {:08x}: 2^{:.2} (2^{:.1} tries)",
        alpha,
        beta,
        diff_prob.log2(),
        (trials as f64).log2(),
    );
}

pub fn find_diff_high_memory(f: impl Fn(Block) -> Block + Copy, p_abs_log: u32) {
    let mut rng = rand::rng();

    let n_queries =
        ((BLOCK_SIZE as f64).sqrt().ceil() as u64) * 2u64.pow(BLOCK_SIZE / 2) * 2u64.pow(p_abs_log);

    println!("Encrypting 2^{:.2} texts...", (n_queries as f64).log2());

    let mut queries: HashMap<Block, Block> = HashMap::new();
    let mut collisions: HashMap<Block, Vec<Block>> = HashMap::new();

    let alpha: Block = rng.random();
    let g = |p: Block| f(p) ^ f(p ^ alpha);

    let bar = ProgressBar::new(n_queries);
    for i in 0..n_queries {
        if i.is_multiple_of(10_000) {
            bar.set_position(i);
        }

        let input: Block = rng.random();
        let output = g(input);

        let old_value = match queries.entry(output) {
            Entry::Occupied(occ) => *occ.get(),
            Entry::Vacant(vac) => {
                vac.insert(input);
                continue;
            }
        };

        let collisions_vec = collisions.entry(old_value).or_default();
        collisions_vec.push(input);
    }
    bar.finish();
    std::mem::drop(queries);

    println!("Found {} collisions", collisions.len());

    let mut diff_scores: HashMap<(Block, Block), u64> = HashMap::new();
    for (i, i_vec) in collisions.into_iter() {
        let mut i_vec = i_vec;
        i_vec.push(i);

        for i in 0..i_vec.len() {
            for j in (i + 1)..i_vec.len() {
                let inputs = (i_vec[i], i_vec[j]);
                let outputs = (f(inputs.0), f(inputs.1));

                let alpha = inputs.0 ^ inputs.1;
                let beta = outputs.0 ^ outputs.1;

                *diff_scores.entry((alpha, beta)).or_default() += 1;
            }
        }
    }

    let interesting_diffs: Vec<(Block, Block)> = diff_scores
        .into_iter()
        .filter(|(_, score)| *score >= (BLOCK_SIZE / 4) as u64)
        .map(|(diff, _)| diff)
        .collect();

    println!(
        "Found {} interesting differentials",
        interesting_diffs.len()
    );

    let diff_tries: u64 = (BLOCK_SIZE as u64) * 2u64.pow(p_abs_log);
    let cutoff = BLOCK_SIZE as u64 / 2;

    let mut best_prob: u64 = 0;
    let mut best_diff: (Block, Block) = (0, 0);

    for (alpha, beta) in interesting_diffs.iter() {
        let alpha = *alpha;
        let beta = *beta;

        let successes = measure_diff_prob(f, alpha, beta, diff_tries);
        if successes < cutoff {
            continue;
        }

        if successes > best_prob {
            best_prob = successes;
            best_diff = (alpha, beta);
        }

        // let diff_prob = (successes as f64) / (diff_tries as f64);
        // println!("{alpha:08x} -> {beta:08x}: 2^{:.2}", diff_prob.log2());
    }

    describe_differential(f, best_diff.0, best_diff.1, diff_tries * 8);
}

fn floyds_algoritm<T>(f: impl Fn(T) -> T + Copy, start: T) -> (T, T)
where
    T: Copy + Clone + PartialEq,
{
    let mut tortoise: T;
    let mut hare: T;

    tortoise = f(start);
    hare = f(tortoise);

    while tortoise != hare {
        tortoise = f(tortoise);
        hare = f(f(hare));
    }

    tortoise = start;

    let mut prev_tortoise = tortoise;
    let mut prev_hare = hare;

    while tortoise != hare {
        prev_tortoise = tortoise;
        prev_hare = hare;

        tortoise = f(tortoise);
        hare = f(hare);
    }

    (prev_tortoise, prev_hare)
}

pub fn find_diff_parallel(f: impl Fn(Block) -> Block + Copy, p_abs_log: u32) {
    let mut rng = rand::rng();

    let factor: u64 = 1;
    let trials = factor * 2u64.pow(p_abs_log);

    let mut current_best_prob = 0.0;
    let mut current_best_diff: (Block, Block) = (0, 0);

    loop {
        let offset: Block = rng.random();
        let start: Block = rng.random();
        let (x1, x2) = floyds_algoritm(|x| f(x) ^ f(x ^ offset), start);

        let alpha = x1 ^ x2;
        if alpha == 0 {
            continue;
        }
        let beta = f(x1) ^ f(x2);

        io::stdout().flush().unwrap();
        let successes = measure_diff_prob(f, alpha, beta, trials);
        if successes >= 1 {
            let prob = successes as f64 / trials as f64;

            if prob > current_best_prob {
                current_best_diff = (alpha, beta);
                current_best_prob = prob;
            }

            println!(
                "{alpha:08x} -> {beta:08x}: 2^{:.1} (2^{:.0} tries) (current best: {:08x}->{:08x} with p=2^{:.2})",
                prob.log2(),
                (trials as f64).log2(),
                current_best_diff.0,
                current_best_diff.1,
                current_best_prob.log2(),
            );
        }
    }
}

#[derive(Subcommand, Debug, Clone)]
enum SubCommand {
    LowMem,
    HighMem,
}

#[derive(Parser, Debug, Clone)]
struct Args {
    #[command(subcommand)]
    cmd: SubCommand,

    fwd_rounds: usize,
    bwd_rounds: usize,
    cutoff_prob: u32,

    #[arg(short, long, default_value_t = 4)]
    prince_rounds: usize,
}

fn main() {
    let args = Args::parse();

    let prince_rounds = args.prince_rounds;
    let beanie_rounds: (usize, usize) = (args.fwd_rounds, args.bwd_rounds);
    let cutoff = args.cutoff_prob;

    println!(
        "Finding Differentials up to 2^-{cutoff} for {}+{} BEANIE rounds",
        beanie_rounds.0, beanie_rounds.1
    );

    let master_key: u128 = 0xaf99f53eb200958efa282babfa5af61;
    let tweak1: u128 = 0x8873886be4cae801ae7755348b1db21b;
    let tweak2: u128 = 0x8873886be4cae801ae7755348b1db21e;

    let key1 = beanie_cipher::tweak_key_schedule(master_key, tweak1, prince_rounds);
    let round_keys1 = beanie_cipher::key_expansion(key1, beanie_rounds.0 + 1);

    let key2 = beanie_cipher::tweak_key_schedule(master_key, tweak2, prince_rounds);
    let round_keys2 = beanie_cipher::key_expansion(key2, beanie_rounds.1 + 1);

    println!("round keys:");
    let enc_keys_str = round_keys1
        .iter()
        .map(|x| format!("{x:08x}"))
        .collect::<Vec<String>>()
        .join(", ");
    let dec_keys_str = round_keys2
        .iter()
        .map(|x| format!("{x:08x}"))
        .collect::<Vec<String>>()
        .join(", ");

    println!("enc round keys: {enc_keys_str}");
    println!("dec round keys: {dec_keys_str}");
    println!(
        "enc_rk[-1] ^ dec_rk[-1]: {:08x}",
        round_keys1[round_keys1.len() - 1] ^ round_keys2[round_keys2.len() - 1],
    );

    let enc = |pt: Block| {
        let ct = beanie_cipher::enc(pt, &round_keys1, beanie_rounds.0);
        beanie_cipher::dec(ct, &round_keys2, beanie_rounds.1)
    };

    match args.cmd {
        SubCommand::LowMem => find_diff_parallel(enc, cutoff),
        SubCommand::HighMem => find_diff_high_memory(enc, cutoff),
    }
    // find_diff_parallel(enc, cutoff);

    find_diff_high_memory(enc, cutoff);
}
