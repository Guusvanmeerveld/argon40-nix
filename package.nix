{
  lib,
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "argonone";
  version = "1.0";

  src = ./.;

  installPhase = ''

  '';
}
