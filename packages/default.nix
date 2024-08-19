{
  pkgs,
  enableOled ? false,
}: rec {
  source = pkgs.callPackage ./source.nix {
    disableOled = !enableOled;
  };

  argononed = pkgs.callPackage ./argononed.nix {
    sourceFilesPackage = source;
  };

  argoneond = pkgs.callPackage ./argoneond.nix {
    sourceFilesPackage = source;
  };
}
