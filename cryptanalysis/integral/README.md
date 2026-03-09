# Integral Distinguisher

## Find integral distinguisher via monomial prediction

Since the MDS matrix model is quite heavy, the model takes quite a while to solve and it is therefore hard to find the best integral distinguishers.

### Requirements

#### Nix
run `nix develop`

#### Manual
- Requires `python`, `uv`, `minizinc`, `pyminizinc`
- Run `uv sync` and `source .venv/bin/activate`

### HW method

Uses HW method proposed in "[Finding Bit-Based Division Property for Ciphers](https://eprint.iacr.org/2020/547)".
For each monomial trail at the MDS Matrix we check if the masked sub matrix is invertable (=correct monomial trail).

The tool checks each bit of the output for a balanced property. This is done for all inputs with one constant bit.
Therefore we need to check if all 32*32 combinations are key dependent in order to rule out integral distinguisher for a given round number. 
```
usage: mon_int_cp.py [-h] [-r ROUNDS] [-b BREAK]

Find integral distinguisher with monomial prediction.

options:
  -h, --help            show this help message and exit
  -r ROUNDS, --rounds ROUNDS
  -b BREAK, --break BREAK
```
