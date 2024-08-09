{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.argonone;

  package = pkgs.callPackage ../package.nix {};
in {
  options = {
    programs.argonone = {
      enable = lib.mkEnableOption "Enable argonone service";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "argonunits.conf" = {
        text = ''
          #
        '';
        mode = "0666";
      };
      "argononed.conf" = {
        text = ''
          #
          # Argon Fan Speed Configuration (CPU)
          #
          55=30
          60=55
          65=100
        '';
        mode = "0666";
      };
    };

    systemd.services.argonone = {
      description = "Argon One Fan and Button Service";
      after = ["multi-user.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RemainAfterExit = true;
        ExecStart = "${package}/bin/argonone SERVICE";
      };
    };
  };
}
