{
  pkgs,
  lib,
  disableOled ? true,
  ...
}: let
  pythonPackage = pkgs.stdenv.mkDerivation (let
    outPath = placeholder "out";
    pythonFilesDir = "${outPath}/lib/share/";
  in {
    pname = "argon40-python";
    version = "1.0";

    src = ./.;

    postPatch = ''
      substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/smartctl' ${pkgs.smartmontools}/bin/smartctl
      substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/hddtemp' ${pkgs.hddtemp}/bin/hddtemp

      substituteInPlace src/*.py --replace '/etc/argon/' ${pythonFilesDir}
    '';

    installPhase = ''
      mkdir -p ${pythonFilesDir}

      cp src/argon*.py ${pythonFilesDir}

      # If the file exists, OLED will be enabled
      ${lib.optionalString disableOled "rm ${pythonFilesDir}/argoneonoled.py"}
    '';
  });
in
  pkgs.writeShellApplication {
    name = "argon40";

    runtimeInputs =
      [
        (pkgs.python3.withPackages (p: (with p; [i2c-tools smbus2 libgpiod])))
      ]
      ++ (with pkgs; [gawk util-linux]);

    text = ''
      python3 ${pythonPackage}/lib/share/argononed.py "$@"
    '';
  }
