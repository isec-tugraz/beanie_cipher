use rand::prelude::*;
use std::collections::HashMap;

use beanie_cipher;

pub fn edp(rounds: usize, mut mask: u32) -> (HashMap<u8, u64>, u128, (u128, u128), u32, Vec<u32>) {
    let mut rng = rand::rng();
    if mask == 0 {
        mask = 1 << rng.random_range(0..32);
    }
    let mut s0: u32;
    let mut s1: u32;

    let key = rng.random::<u128>();
    let tweak1 = rng.random::<u128>();
    let tweak2 = rng.random::<u128>();
    let round_keys0 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak1, rounds),
        rounds + 1,
    );
    let round_keys1 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak2, rounds),
        rounds + 1,
    );

    // let mut difference_count: HashMap<u32, u8> = HashMap::new();
    let mut difference_count: Vec<u8> = vec![0; 1 << 32];

    let limit: usize = 1 << 32;
    for i in 0..limit {
        if (mask.count_ones() == 1) && (i as u32 & mask) > 0 {
            // Test each difference only once
            continue;
        }

        s0 = i as u32;
        s1 = s0 ^ mask;

        s0 = beanie_cipher::enc(s0, &round_keys0, rounds);
        s0 = beanie_cipher::dec(s0, &round_keys1, rounds);
        s1 = beanie_cipher::enc(s1, &round_keys0, rounds);
        s1 = beanie_cipher::dec(s1, &round_keys1, rounds);

        // *difference_count.entry(s0 ^ s1).or_insert(0) += 1;
        difference_count[(s0 ^ s1) as usize] += 1;
    }

    let mut difference_frequency: HashMap<u8, u64> = HashMap::new();

    let mut max_count: u8 = 0;
    let limit: usize = 1 << 32;
    for i in 0..limit {
        // match difference_count.get(&(i as u32)) {
        //         Some(&count) => *difference_frequency.entry(count).or_insert(0) += 1,
        //         None => *difference_frequency.entry(0).or_insert(0) += 1
        //     }
        *difference_frequency.entry(difference_count[i]).or_insert(0) += 1;

        if difference_count[i] > max_count {
            max_count = difference_count[i];
        }
    }

    let mut output_mask_max: Vec<u32> = Vec::new();
    for i in 0..limit {
        if difference_count[i] == max_count {
            output_mask_max.push(i as u32);
        }
        if output_mask_max.len() > 20 {
            break;
        }
    }

    (
        difference_frequency,
        key,
        (tweak1, tweak2),
        mask,
        output_mask_max,
    )
}

pub fn edp_mask(
    rounds: usize,
    input_mask: u32,
    output_mask: u32,
) -> (u32, u128, (u128, u128), u32, u32) {
    let mut rng = rand::rng();
    let mut s0: u32;
    let mut s1: u32;

    let key = rng.random::<u128>();
    let tweak1 = rng.random::<u128>();
    let tweak2 = rng.random::<u128>();
    let round_keys0 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak1, rounds),
        rounds + 1,
    );
    let round_keys1 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak2, rounds),
        rounds + 1,
    );

    let mut difference_count: u32 = 0;

    let limit: usize = 1 << 32;
    for i in 0..limit {
        if (input_mask.count_ones() == 1) && (i as u32 & input_mask) > 0 {
            // Test each difference only once
            continue;
        }

        s0 = i as u32;
        s1 = s0 ^ input_mask;

        s0 = beanie_cipher::enc(s0, &round_keys0, rounds);
        s0 = beanie_cipher::dec(s0, &round_keys1, rounds);
        s1 = beanie_cipher::enc(s1, &round_keys0, rounds);
        s1 = beanie_cipher::dec(s1, &round_keys1, rounds);

        // *difference_count.entry(s0 ^ s1).or_insert(0) += 1;
        if (s0 ^ s1) == output_mask {
            difference_count += 1;
        }
    }

    if input_mask.count_ones() == 1 {
        (
            difference_count * 2,
            key,
            (tweak1, tweak2),
            input_mask,
            output_mask,
        )
    } else {
        (
            difference_count,
            key,
            (tweak1, tweak2),
            input_mask,
            output_mask,
        )
    }
}

fn walsh_transform(mut a: Vec<i32>) -> Vec<i32> {
    let mut h: usize = 1;
    while h < a.len() {
        for i in (0..a.len()).step_by(h * 2) {
            for j in i..(i + h) {
                a[j] = a[j] + a[j + h];
                a[j + h] = a[j] - 2 * a[j + h]
            }
        }
        h = h << 1;
    }
    a
}

pub fn elp(rounds: usize, mut mask: u32) -> (HashMap<i32, u64>, u128, (u128, u128), u32, Vec<u32>) {
    let mut rng = rand::rng();
    if mask == 0 {
        mask = 1 << rng.random_range(0..32);
    }

    let mut s: u32;
    let key = rng.random::<u128>();
    let tweak1 = rng.random::<u128>();
    let tweak2 = rng.random::<u128>();
    let round_keys0 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak1, rounds),
        rounds + 1,
    );
    let round_keys1 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak2, rounds),
        rounds + 1,
    );

    let mut parity: Vec<i32> = vec![0; 1 << 32];

    let limit: usize = 1 << 32;
    for i in 0..limit {
        s = i as u32;

        s = beanie_cipher::enc(s, &round_keys0, rounds);
        s = beanie_cipher::dec(s, &round_keys1, rounds);

        parity[i] = if ((s & mask).count_ones() & 0x1) as i32 == 1 {
            1
        } else {
            -1
        };
    }
    parity = walsh_transform(parity);

    let mut bias_frequency: HashMap<i32, u64> = HashMap::new();

    let mut max_count: i32 = 0;
    let limit: usize = 1 << 32;
    for i in 0..limit {
        *bias_frequency.entry(parity[i]).or_insert(0) += 1;

        if (parity[i].abs()) > max_count {
            max_count = parity[i].abs();
        }
    }

    let mut input_masks_max: Vec<u32> = Vec::new();
    for i in 0..limit {
        if parity[i].abs() == max_count {
            input_masks_max.push(i as u32);
        }
        if input_masks_max.len() > 20 {
            break;
        }
    }
    (bias_frequency, key, (tweak1, tweak2), mask, input_masks_max)
}

pub fn elp_mask(
    rounds: usize,
    input_mask: u32,
    output_mask: u32,
) -> (i32, u128, (u128, u128), u32, u32) {
    let mut rng = rand::rng();

    let mut s: u32;
    let key = rng.random::<u128>();
    let tweak1 = rng.random::<u128>();
    let tweak2 = rng.random::<u128>();
    let round_keys0 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak1, rounds),
        rounds + 1,
    );
    let round_keys1 = beanie_cipher::key_expansion(
        beanie_cipher::tweak_key_schedule(key, tweak2, rounds),
        rounds + 1,
    );

    let mut bias: i32 = 0;

    let limit: usize = 1 << 32;
    for i in 0..limit {
        s = i as u32;
        let input_parity = ((s & input_mask).count_ones() & 0x1) as i32;

        s = beanie_cipher::enc(s, &round_keys0, rounds);
        s = beanie_cipher::dec(s, &round_keys1, rounds);

        if ((s & output_mask).count_ones() & 0x1) as i32 == input_parity {
            bias += 1;
        } else {
            bias -= 1;
        };
    }

    (bias, key, (tweak1, tweak2), input_mask, output_mask)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn walsh_transform_test() {
        assert_eq!(
            walsh_transform(vec![1, -1, 1, 1, 1, -1, -1, -1]),
            vec![0, 4, 0, 4, 4, 0, -4, 0]
        );
    }

    #[test]
    fn walsh_transform_test2() {
        assert_eq!(
            walsh_transform(vec![1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, -1, -1, -1]),
            vec![0, 0, 8, 8, 0, 0, 0, 0, 4, -4, 4, -4, -4, 4, 4, -4]
        );
    }

    #[test]
    fn walsh_transform_test3() {
        assert_eq!(
            walsh_transform(vec![1, 0, 1, 0, 0, 1, 1, 0]),
            vec![4, 2, 0, -2, 0, 2, 0, 2]
        );
    }
}
