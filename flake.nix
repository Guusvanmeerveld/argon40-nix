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

      # nixosModules = {
      #   default = import ./modules/nixos.nix;
      # };

      overlays = {
        argonone = final: _prev: {
          argonone = self.packages."${final.system}".default;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = let
        package = pkgs.callPackage ./package.nix {};
      in {
        argonone = package;
        default = package;
      };
    });
}
