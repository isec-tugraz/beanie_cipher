# Surrogate Differentials

Experiments based on https://eprint.iacr.org/2023/288.pdf

## Requirements

### Nix
- `nix develop`

### Manual
- Requires `cargo`, `rustc`

## Usage

- `cargo run`

```
Usage: diff_experiments [OPTIONS] <FWD_ROUNDS> <BWD_ROUNDS> <CUTOFF_PROB> <COMMAND>

Commands:
  low-mem   
  high-mem  
  help      Print this message or the help of the given subcommand(s)

Arguments:
  <FWD_ROUNDS>   
  <BWD_ROUNDS>   
  <CUTOFF_PROB>  

Options:
  -p, --prince-rounds <PRINCE_ROUNDS>  [default: 4]
  -h, --help                           Print help
```

### Example

`cargo run 4 2 12 high-mem`
