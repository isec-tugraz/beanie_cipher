const ROUND_CONSTANTS: [u128; 10] = [
    0x00000000000000000000000000000000,
    0x000000000000000013198a2e03707344,
    0x0000000000000000a4093822299f31d0,
    0x0000000000000000082efa98ec4e6c89,
    0x0000000000000000452821e638d01377,
    0x0000000000000000be5466cf34e90c6c,
    0x00000000000000007ef84f78fd955cb1,
    0x000000000000000085840851f1ac43aa,
    0x0000000000000000c882d32f25323c54,
    0x000000000000000064a51195e0e3610d,
];

const SBOX: [u32; 16] = [0, 4, 2, 11, 10, 12, 9, 8, 5, 15, 13, 3, 7, 1, 6, 14];
const SBOX_INV: [u32; 16] = [0, 13, 2, 11, 1, 8, 14, 12, 7, 6, 4, 3, 5, 10, 15, 9];

fn sbox(state: u32) -> u32 {
    let mut state_tmp: u32 = 0;
    for i in 0..8 {
        state_tmp |= (SBOX[((state >> i * 4) & 0xF) as usize]) << i * 4
    }
    state_tmp
}

fn sbox_inv(state: u32) -> u32 {
    let mut state_tmp: u32 = 0;
    for i in 0..8 {
        state_tmp |= (SBOX_INV[((state >> i * 4) & 0xF) as usize]) << i * 4
    }
    state_tmp
}

fn shift(state: u32) -> u32 {
    let mut state_shifted: u32 = state & 0xf0f0f0f0;
    state_shifted |= (state & 0x0f0f0000) >> 16;
    state_shifted |= (state & 0x00000f0f) << 16;
    state_shifted
}

fn xtime(x: u8) -> u8 {
    (0xf) & ((x << 1) ^ (((x >> 3) & 1) * 0x3))
}

fn muliply(x: u8, y: u8) -> u8 {
    ((y & 1) * x)
        ^ ((y >> 1 & 1) * xtime(x))
        ^ ((y >> 2 & 1) * xtime(xtime(x)))
        ^ ((y >> 3 & 1) * xtime(xtime(xtime(x))))
}

//GF(2^4) MDS matrix application
// Adapted from https://github.com/kokke/tiny-AES-c/blob/master/aes.c
fn mix_columns(state: u32) -> u32 {
    let c0: u8 = (state >> 28) as u8 & 0xf;
    let c1: u8 = (state >> 24) as u8 & 0xf;
    let c2: u8 = (state >> 20) as u8 & 0xf;
    let c3: u8 = (state >> 16) as u8 & 0xf;
    let c4: u8 = (state >> 12) as u8 & 0xf;
    let c5: u8 = (state >> 8) as u8 & 0xf;
    let c6: u8 = (state >> 4) as u8 & 0xf;
    let c7: u8 = (state >> 0) as u8 & 0xf;

    (u32::from(muliply(c0, 0x2) ^ muliply(c1, 0x1) ^ muliply(c2, 0x1) ^ muliply(c3, 0x9)) << 28)
        | (u32::from(muliply(c0, 0x1) ^ muliply(c1, 0x4) ^ muliply(c2, 0xf) ^ muliply(c3, 0x1))
            << 24)
        | (u32::from(muliply(c0, 0xd) ^ muliply(c1, 0x9) ^ muliply(c2, 0x4) ^ muliply(c3, 0x1))
            << 20)
        | (u32::from(muliply(c0, 0x1) ^ muliply(c1, 0xd) ^ muliply(c2, 0x1) ^ muliply(c3, 0x2))
            << 16)
        | (u32::from(muliply(c4, 0x2) ^ muliply(c5, 0x1) ^ muliply(c6, 0x1) ^ muliply(c7, 0x9))
            << 12)
        | (u32::from(muliply(c4, 0x1) ^ muliply(c5, 0x4) ^ muliply(c6, 0xf) ^ muliply(c7, 0x1))
            << 8)
        | (u32::from(muliply(c4, 0xd) ^ muliply(c5, 0x9) ^ muliply(c6, 0x4) ^ muliply(c7, 0x1))
            << 4)
        | (u32::from(muliply(c4, 0x1) ^ muliply(c5, 0xd) ^ muliply(c6, 0x1) ^ muliply(c7, 0x2))
            << 0)
}

pub fn enc(mut state: u32, key: &Vec<u32>, rounds: usize) -> u32 {
    if rounds == 0 {
        return state;
    }

    for round in 0..(rounds - 1) {
        state ^= key[round];
        state = sbox(state);
        state = shift(state);
        state = mix_columns(state);
    }

    state ^= key[rounds - 1];
    state = sbox(state);
    state = shift(state);
    state ^= key[rounds];

    state
}

pub fn dec(mut state: u32, key: &Vec<u32>, rounds: usize) -> u32 {
    if rounds == 0 {
        return state;
    }

    state ^= key[rounds];
    state = shift(state);
    state = sbox_inv(state);
    state ^= key[rounds - 1];

    for round in (0..(rounds - 1)).rev() {
        state = mix_columns(state);
        state = shift(state);
        state = sbox_inv(state);
        state ^= key[round];
    }

    state
}

fn sbox_tk(state: u128) -> u128 {
    let mut state_tmp: u128 = 0;
    for i in 0..32 {
        state_tmp |= u128::from(SBOX[((state >> i * 4) & 0xF) as usize]) << i * 4
    }
    state_tmp
}

fn prince_m_0(column: u16) -> u16 {
    let c0: u16 = (column >> 12) & 0xf;
    let c1: u16 = (column >> 8) & 0xf;
    let c2: u16 = (column >> 4) & 0xf;
    let c3: u16 = (column >> 0) & 0xf;

    (((c0 & 0b0111) ^ (c1 & 0b1011) ^ (c2 & 0b1101) ^ (c3 & 0b1110)) << 12)
        | (((c0 & 0b1011) ^ (c1 & 0b1101) ^ (c2 & 0b1110) ^ (c3 & 0b0111)) << 8)
        | (((c0 & 0b1101) ^ (c1 & 0b1110) ^ (c2 & 0b0111) ^ (c3 & 0b1011)) << 4)
        | (((c0 & 0b1110) ^ (c1 & 0b0111) ^ (c2 & 0b1011) ^ (c3 & 0b1101)) << 0)
}

fn prince_m_1(column: u16) -> u16 {
    let c0: u16 = (column >> 12) & 0xf;
    let c1: u16 = (column >> 8) & 0xf;
    let c2: u16 = (column >> 4) & 0xf;
    let c3: u16 = (column >> 0) & 0xf;

    (((c0 & 0b1011) ^ (c1 & 0b1101) ^ (c2 & 0b1110) ^ (c3 & 0b0111)) << 12)
        | (((c0 & 0b1101) ^ (c1 & 0b1110) ^ (c2 & 0b0111) ^ (c3 & 0b1011)) << 8)
        | (((c0 & 0b1110) ^ (c1 & 0b0111) ^ (c2 & 0b1011) ^ (c3 & 0b1101)) << 4)
        | (((c0 & 0b0111) ^ (c1 & 0b1011) ^ (c2 & 0b1101) ^ (c3 & 0b1110)) << 0)
}

fn prince_m(state: u128) -> u128 {
    u128::from(prince_m_0((state >> 112) as u16)) << 112
        | u128::from(prince_m_1((state >> 96) as u16)) << 96
        | u128::from(prince_m_1((state >> 80) as u16)) << 80
        | u128::from(prince_m_0((state >> 64) as u16)) << 64
        | u128::from(prince_m_0((state >> 48) as u16)) << 48
        | u128::from(prince_m_1((state >> 32) as u16)) << 32
        | u128::from(prince_m_1((state >> 16) as u16)) << 16
        | u128::from(prince_m_0((state >> 0) as u16)) << 0
}

fn prince_shift(state: u128) -> u128 {
    let mut shift_state: u128 = state & 0xF000F000F000F000F000F000F000F000;

    shift_state |= (state & 0x00000F000F000F0000000F000F000F00) << 16;
    shift_state |= (state & 0x0F000000000000000F00000000000000) >> 48;

    shift_state |= (state & 0x0000000000F000F00000000000F000F0) << 32;
    shift_state |= (state & 0x00F000F00000000000F000F000000000) >> 32;

    shift_state |= (state & 0x000000000000000F000000000000000F) << 48;
    shift_state |= (state & 0x000F000F000F0000000F000F000F0000) >> 16;

    shift_state
}

fn feistel(state: u128) -> u128 {
    (state ^ (state << 32)) & (0xffffffff << 96)
        | (state << 32) & (0xffffffff << 64)
        | (state ^ (state << 32)) & (0xffffffff << 32)
        | (state >> 96) & (0xffffffff << 0)
}

fn tks_shift(state: u128) -> u128 {
    state & 0xF000F000F000F000F000F000F000F000
        | (((state >> 64) & 0x000000000F000F00) << 96)
        | (((state >> 0) & 0x0F000F0000000000) << 32)
        | (((state >> 0) & 0x000000000F000F00) << 32)
        | (((state >> 64) & 0x0F000F0000000000) >> 32)
        | ((state >> 0) & 0x00F000F000F000F0) << 64
        | ((state >> 64) & 0x00F000F000F000F0) << 0
        | (((state >> 64) & 0x000F000F00000000) << 32)
        | (((state >> 0) & 0x00000000000F000F) << 96)
        | (((state >> 0) & 0x000F000F00000000) >> 32)
        | (((state >> 64) & 0x00000000000F000F) << 32)
}

pub fn tweak_key_schedule(key: u128, mut tweak: u128, rounds: usize) -> u128 {
    if rounds == 0 {
        return tweak;
    }

    for round in 0..rounds {
        tweak ^= key;
        tweak ^= ROUND_CONSTANTS[round];
        tweak = sbox_tk(tweak);
        tweak = prince_m(tweak);
        tweak = prince_shift(tweak);
        tweak = feistel(tweak);
        tweak = tks_shift(tweak);
    }

    tweak ^= key;
    tweak ^= ROUND_CONSTANTS[rounds];

    tweak
}

// void key_expansion(state_t* round_keys, state_tk_t* key, uint8_t nr_keys)
pub fn key_expansion(key: u128, nr_keys: usize) -> Vec<u32> {
    let mut round_keys: Vec<u32> = vec![0; nr_keys];
    if nr_keys > 0 {
        round_keys[0] = (key >> 96) as u32;
    }
    if nr_keys > 1 {
        round_keys[1] = (key >> 64) as u32;
    }
    if nr_keys > 2 {
        round_keys[2] = (key >> 32) as u32;
    }
    if nr_keys > 3 {
        round_keys[3] = (key >> 0) as u32;
    }
    if nr_keys > 4 {
        round_keys[4] = round_keys[0] ^ round_keys[1];
    }
    if nr_keys > 5 {
        round_keys[5] = round_keys[2] ^ round_keys[3];
    }
    if nr_keys > 6 {
        round_keys[6] = round_keys[0] ^ round_keys[2];
    }
    if nr_keys > 7 {
        round_keys[7] = round_keys[1] ^ round_keys[3];
    }
    if nr_keys > 8 {
        round_keys[8] = round_keys[0] ^ round_keys[3];
    }
    if nr_keys > 9 {
        round_keys[9] = round_keys[1] ^ round_keys[2];
    }
    round_keys
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sbox_test() {
        assert_eq!(sbox(0x12345678), 0x42bac985);
    }

    #[test]
    fn sbox_inv_test() {
        assert_eq!(sbox_inv(0x12345678), 0xd2b18ec7);
    }

    #[test]
    fn shift_test() {
        assert_eq!(shift(0x12345678), 0x16385274);
    }

    #[test]
    fn mix_columns_test() {
        assert_eq!(mix_columns(0x12345678), 0x1f43fd89);
    }

    #[test]
    fn sbox_tk_test() {
        assert_eq!(
            sbox_tk(0x0123456789abcdeffedcba9876543210),
            0x042bac985fd3716ee6173df589cab240
        );
    }

    #[test]
    fn prince_m_test() {
        assert_eq!(
            prince_m(0x0123456789abcdeffedcba9876543210),
            0x3012456789abfcdecfedba9876540321
        );
    }

    #[test]
    fn prince_shift_test() {
        assert_eq!(
            (prince_shift(0x0123456789abcdeffedcba9876543210) >> 64) as u64,
            0x05af49e38d27c16b
        );
    }

    #[test]
    fn feistel_test() {
        assert_eq!(
            feistel(0x0123456789abcdeffedcba9876543210),
            0x88888888fedcba988888888801234567
        );
    }

    #[test]
    fn tks_shift_test() {
        assert_eq!(
            tks_shift(0x0123456789abcdeffedcba9876543210),
            0x09d44d908e53ca17f62bb26f71ac35e8
        );
    }

    #[test]
    fn key_expansion_test() {
        assert_eq!(
            key_expansion(0x0123456789abcdeffedcba9876543210, 10),
            vec![
                0x01234567, 0x89abcdef, 0xfedcba98, 0x76543210, 0x88888888, 0x88888888, 0xffffffff,
                0xffffffff, 0x77777777, 0x77777777
            ]
        );
    }
}
