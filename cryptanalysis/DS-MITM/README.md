# Find the size of the parameter space for the offline phase of the DS-MitM attack

## Requirements
- minizinc (v 2.9.3)

## Usage

- File: `ds_mitm.mzn`
    - Speficy Number of rounds `NR` and break point (where encryption switches to decryption) `BP` in file
    - Run with minizinc
        - `minizinc ds_mitm.mzn`
        - Return number of bits of the parameter space
