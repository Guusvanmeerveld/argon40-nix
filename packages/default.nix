{pkgs}: rec {
  source =
    pkgs.callPackage ./source.nix {};

  argononed = pkgs.callPackage ./argononed.nix {
    sourceFilesPackage = source;
  };

  argoneond = pkgs.callPackage ./argoneond.nix {
    sourceFilesPackage = source;
  };
}
