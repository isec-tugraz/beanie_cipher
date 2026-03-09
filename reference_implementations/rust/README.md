# beanie reference implementation (rust)

Use `cargo test` to run test cases

Use as library as shown in [edp/elp](../../cryptanalysis/edp_elp/Cargo.toml)

## datapath

`enc` takes a input state, a subkey array, and a round number and returns an encrypted ciphertext

`dec` takes a input state, a subkey array, and a round number and returns an decrypted plaintext

## tweak key schedule

`tweak_key_schedule` takes the main key, a tweak, and a round number and returns the corresponding encrypted tweak

`key_expansion` takes the encrypted tweak and a number specifying the subkeys needed for the datapath and returns the round keys

