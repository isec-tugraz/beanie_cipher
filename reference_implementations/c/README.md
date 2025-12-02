# beanie reference implementation

## datapath

`enc` takes a input state, a subkey array, and a round number and returns an encrypted ciphertext

`dec` takes a input state, a subkey array, and a round number and returns an decrypted plaintext

## tweak key schedule

`tweak_key_schedule` takes the main key, a tweak, and a round number and returns the corresponding encrypted tweak

`key_expantion` takes the encrypted tweak and a number specifying the subkeys needed for the datapath and stores these subkeys in the array `round_keys`

