# Beanie Cipher

A 32-bit Cipher for Cryptographic Mitigations against Software Attacks

This repository contains reference implementations and tools for cryptanalysis.

## [Reference Implementations](reference_implementations/)

Implementation of beanie in c and rust as well as a hardware implementation.

## [Differential/Linear Analysis](cryptanalysis/differential_and_linear/)

A bit-based model to find the minimum amount of differentially/linearly active S-Boxes with different configurations of the cipher.

Also includes a model for clustering that counts the number of characteristics above a certain probability threshold.

## [EDP/ELP](cryptanalysis/edp_elp/)

Contains program to experimentally calculate the EDP/ELP for random keys/tweaks

## [Surrogate Diff](cryptanalysis/surrogate_diff/)

Experiments based on https://eprint.iacr.org/2023/288.pdf

## [DS-MitM Analysis](cryptanalysis/DS-MitM/)

Propagates forward and backward with probability one and finds overlapping cells

## [Impossible Differential Analysis]()

Done by hand

## [Integral Analysis](cryptanalysis/integral/)

Sat model to find integral distinguisher via monomial prediction.

## [Boomerang Cryptanalysis](cryptanalysis/boomerang/)

Find best truncated difference with minimal number of active S-Boxes for the middle part of a sandwich boomerang distinguisher.
Validate the probability of a distinguisher.

## Reproducibility

Using nix (https://nixos.org/download/) we aim to make the tools usable in the future.
We provide a `flake.nix` and a `flake.lock` that specifies the dependencies under which the programs were tested.

Use

```nix develop```

in the directories of the specifies tools/implementations to obtain all needed dependencies.
The commands to run the tools are specified in the corresponding README.

For the rust/python programs the .toml file should also provide some level of reproducibility when not using nix.

## Cite

```
@article{tosc/GerhalterHMNFNHSME25,
  author       = {Simon Gerhalter and Samir Hodzic and Marcel Medwed and Marcel Nageler and Artur Folwarczny and Ventzislav Nikov and Jan Hoogerbrugge and Tobias Schneider and Gary McConville and Maria Eichlseder},
  title        = {{BEANIE} -- {A} 32-bit Cipher for Cryptographic Mitigations Against Software Attacks},
  journal      = {{IACR} Transactions on Symmetric Cryptology},
  number       = {4},
  volume       = {2025},
  pages        = {31--69},
  year         = {2025},
  doi          = {10.46586/tosc.v2025.i4.31-69},
  biburl       = {https://dblp.org/rec/journals/tosc/GerhalterHMNFNHSME25.bib},
}

```

## Notes

- To generate constraints we used the tool https://github.com/hadipourh/sboxanalyzer

- Due to historical reasons in a lot of the analysis the state is indexed row wise and not column wise like in the spec.

- For most tools we use minizinc with the solver or-tools and the python library pyminizinc.
