{
  pkgs,
  lib,
  disableOled ? true,
  ...
}:
pkgs.stdenv.mkDerivation (let
  outPath = placeholder "out";
  outputFilesDir = "${outPath}/lib/share/";
in {
  pname = "argon40-files";
  version = "1.0";

  src = ../.;

  postPatch = ''
    substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/smartctl' ${pkgs.smartmontools}/bin/smartctl
    substituteInPlace src/argonsysinfo.py --replace '/usr/sbin/hddtemp' ${pkgs.hddtemp}/bin/hddtemp

    substituteInPlace src/*.py --replace '/etc/argon/' ${outputFilesDir}
  '';

  installPhase = ''
    mkdir -p ${outputFilesDir}

    cp src/argon*.py ${outputFilesDir}

    mkdir -p ${outputFilesDir}/oled

    cp src/oled/*.bin ${outputFilesDir}/oled

    ${lib.optionalString disableOled ''
      # If the file exists, OLED will be enabled
      rm ${outputFilesDir}/argoneonoled.py
    ''}
  '';
})
