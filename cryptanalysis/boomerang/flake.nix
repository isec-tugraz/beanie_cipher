{
  description = "Beanie, Boomerang Deterministic Propagation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.minizinc
              pkgs.or-tools
            ];

            MZN_SOLVER_PATH = "${pkgs.or-tools}/share/minizinc/solvers";  # Make cp-sat solver available
          };
        }
      );
    };
}
