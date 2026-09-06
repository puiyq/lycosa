{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, self', ... }:
        {
          packages = {
            lycosa = pkgs.callPackage ./package.nix { };
            default = self'.packages.lycosa;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.packages.default ];
            packages = with pkgs; [
              electron
              typescript
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              biome.enable = true;
              deadnix.enable = true;
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rs;
              };
              statix.enable = true;
            };
          };
        };

      flake = {
        overlays.default = final: _prev: {
          lycosa = self.packages.${final.stdenv.hostPlatform.system}.default;
        };
      };
    };
}
