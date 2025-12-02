mod statistic_experiments;

fn main() {
    let key = beanie_cipher::tweak_key_schedule(0, 0, 5);
    println!("{:032x?}", key);
    let round_keys = beanie_cipher::key_expansion(key, 6);

    println!("{:08x?}", round_keys);
    let state = beanie_cipher::enc(0, &round_keys, 5);
    println!("{:08x?}", state);
    println!("{:08x?}", beanie_cipher::dec(state, &round_keys, 5));

    let mut x: u32 = 0;
    for i in 0..(1<<28) {
    	x ^= beanie_cipher::enc(i, &round_keys, 5);
    }
    println!("{:08x?}", x);
}
