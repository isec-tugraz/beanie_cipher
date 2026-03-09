# ELP/EDP Experimental

For a specific key and tweak pair encrypt all $2^{32}$ plaintexts.
Then build DDT/LAT row for a fixed input/output.

## Instruction

Using `nix develop` the python library needed should be build and installed

### Manual Setup

Requires: rustc, cargo, uv, maturin
- Build python library in rust
    - `uv sync`
        - Should build and install python library `beanie`
        - Uses beanie reference implementation from `../../reference_implementations/rust`
    - `source .venv/bin/activate`
        - Manual python library `pip install target/wheels/beanie-0.1.0-cp38-abi3-manylinux_2_34_x86_64.whl`

### Run EDP/ELP Experiments
- Run EDP/ELP search
    - Specify Rounds r (r encryptions + r decryptions)
    - Specify Mask m (also specifies input difference)
    - Toggle EDP/ELP with the l parameter
    - OUTPUT_MASK can be specified of only a single output difference should be considered

```
usage: ep.py [-h] [-t THREADS] [-r ROUNDS] [-i ITERATIONS] [-m MASK] [-o OUTPUT_MASK] [-l]

EDP/ELP of Beanie

options:
  -h, --help            show this help message and exit
  -t THREADS, --threads THREADS
  -r ROUNDS, --rounds ROUNDS
  -i ITERATIONS, --iterations ITERATIONS
  -m MASK, --mask MASK
  -o OUTPUT_MASK, --output_mask OUTPUT_MASK
  -l, --linear
```

In the [experiments](experiments) folder we provide example outputs of the program
