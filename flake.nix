{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ ./dev/partition.nix ];

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
              typescript
            ];
          };
        };

      flake = {
        overlays.default = final: _prev: {
          lycosa = self.packages.${final.stdenv.hostPlatform.system}.default;
        };
      };
    };
}
