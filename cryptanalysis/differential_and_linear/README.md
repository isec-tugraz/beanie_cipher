# Active S-Boxes

Find minimum number of differentially and linearly active S-Boxes for different configurations.
Alternatively the exact probability can be optimized.
We implement a bit-based model taking the internals of the S-Box and the MixColumn operations into account.

## Requirements
Uses minizinc and pyminizinc and sage

## `active_sbox.py`
- Change the parameter of the search
- The Constraints for the S-Box and MixColumn get generated dynamically
- To add S-Boxes or MixColumn matracies, add them to the begin of the python file
```
usage: active_sbox.py [-h] [-r ROUNDS] [-b BREAK] [-s {PRESENT,SERPENT_S0,G7}]
                      [-m {jean_inv}] [-p {0011,0101,0110,1001,1010,1100}] [-l] [-e]

Find minimum number of active S-Box

options:
  -h, --help            show this help message and exit
  -r ROUNDS, --rounds ROUNDS
  -b BREAK, --break BREAK
  -s {PRESENT,SERPENT_S0,G7}, --sbox {PRESENT,SERPENT_S0,G7}
  -m {jean_inv}, --mcol {jean_inv}
  -p {0011,0101,0110,1001,1010,1100}, --permutation {0011,0101,0110,1001,1010,1100}
  -l, --linear          Switch between differential and linear characteristics
  -e, --exact           If true then calculate exact probability, else count active S-Boxes
```

Example:

`python3 active_sbox.py -p 0101 -m jean_inv -s G7  -l -e`

# Clustering

First find an optimal differential/linear characteristic.
Then fix the input/output difference/mask and count all solutions below a probability threshold l.
Given an optimal characteristic with probability $2^-p$, we search for all characteristics with a probability above $2^{-p-l}$
iterations specifies how many characteristics should be searched.

```
usage: clustering.py [-h] [-r ROUNDS] [-b BREAK] [-i ITERATIONS]
                     [-l LIMIT] [-d] [-p PROCESSES]

Clustering

options:
  -h, --help            show this help message and exit
  -r ROUNDS, --rounds ROUNDS
  -b BREAK, --break BREAK
  -i ITERATIONS, --iterations ITERATIONS
  -l LIMIT, --limit LIMIT
  -d, --differential
  -p PROCESSES, --processes PROCESSES
```

In the folder [diff/] and [lin/] we provide results of clustering for different round configurations.
