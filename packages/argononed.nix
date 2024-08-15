{
  pkgs,
  sourceFilesPackage,
  ...
}:
pkgs.writeShellApplication {
  name = "argononed";

  runtimeInputs =
    [
      (pkgs.python3.withPackages (p: (with p; [i2c-tools smbus2 libgpiod])))
    ]
    ++ (with pkgs; [gawk util-linux]);

  text = ''
    python3 ${sourceFilesPackage}/lib/share/argononed.py "$@"
  '';
}
