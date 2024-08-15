{
  description = "Nixified argonone";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    {
      # homeManagerModules = {
      #   default = import ./modules/home-manager.nix;
      # };

      nixosModules = {
        default = import ./modules/nixos.nix;
      };

      overlays = {
        default = final: _prev: {
          argononed = self.packages."${final.system}".argononed;
          argoneond = self.packages."${final.system}".argoneond;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = import ./packages {inherit pkgs;};
    });
}
