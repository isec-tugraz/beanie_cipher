# Find the minimum number of active S-Boxes in the middle part of a boomerang distinguisher

## Requirements
- minizinc (v 2.9.3)

## Usage

- File: `boomerang_truncated_u.mzn`
    - Speficy Number of rounds `NR` and break point (where encryption switches to decryption) `BP` in file
    - Run with minizinc
        - `minizinc boomerang_truncated_u.mzn`
        - Return Number of active S-Boxes

# Experimentally verify probability of Boomerang distinguisher

Verify the probability of a boomerang distinguisher with a experimental testing

## Requirements

- c build tools
- BEANIE c reference implementation, provided in this repo

## Usage

Specify
```
#define ALPHA_TRUNCATED 1
#define LEFT 3
#define RIGHT 2
#define ALPHA 0x0000000f
#define BETA 0x0000000f

#define ITERATIONS pow(2, 24)
```
- in `boomerang_probability.c`
    - `ALPHA_TRUNCATED` specifies if ALPHA is a truncated difference i.e. all differences with where the zeroes adhere to `ALPHA` are valid
    - `LEFT` rounds in the left branch
    - `RIGHT` rounds in the right branch
    - `ALPHA` input difference
    - `BETA` output difference
    - 'ITERATIONS' number of encryptions, must be high enough to provide confidance
- build with `make`
- run with `./`

