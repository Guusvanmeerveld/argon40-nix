{
  lib,
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "argonone";
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

    cp src/argon* ${outPath}/lib/share/
  '';
}
