{pkgs, ...}: let
  pythonPackage = pkgs.stdenv.mkDerivation {
    pname = "argonone-python";
    version = "1.0";

    src = ./.;

    postPatch = ''
      substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/smartctl' ${pkgs.smartmontools}/bin/smartctl
      substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/hddtemp' ${pkgs.hddtemp}/bin/hddtemp

      substituteInPlace src/argonsysinfo.py --replace 'awk' ${pkgs.gawk}/bin/awk
      substituteInPlace src/argonsysinfo.py --replace 'lsblk' ${pkgs.util-linux}/bin/lsblk
    '';

    installPhase = let
      outPath = placeholder "out";
    in ''
      mkdir -p ${outPath}/lib/share

      cp src/argon*.py ${outPath}/lib/share/
    '';
  };
in
  pkgs.writeShellApplication {
    name = "argonone";

    runtimeInputs = [
      (pkgs.python3.withPackages (p: (with p; [i2c-tools smbus2 libgpiod])))
    ];

    text = ''
      python3 ${pythonPackage}/lib/share/argononed.py "$@"
    '';
  }
