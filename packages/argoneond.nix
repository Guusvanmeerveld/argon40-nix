{
  pkgs,
  sourceFilesPackage,
  ...
}:
pkgs.writeShellApplication {
  name = "argoneond";

  runtimeInputs = [
    (pkgs.python3.withPackages (p: (with p; [i2c-tools smbus2 libgpiod])))
  ];

  text = ''
    python3 ${sourceFilesPackage}/lib/share/argoneond.py "$@"
  '';
}
