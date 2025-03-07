{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.argon;

  packages = import ../packages {
    inherit pkgs;
    enableOled = cfg.eon.enable;
  };
in {
  options = {
    programs.argon = {
      one = {
        enable = lib.mkEnableOption "Enable argononed service";

        package = lib.mkOption {
          type = lib.types.package;
          default = packages.argononed;
        };

        settings = {
          displayUnits = lib.mkOption {
            type = lib.types.enum ["celsius" "fahrenheit"];
            default = "celsius";
          };

          fanspeed = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                temperature = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  description = "The temperature to activate this fan speed at";
                };

                speed = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  description = "The speed the fans will be running at (as a percentage)";
                };
              };
            });

            default = [
              {
                temperature = 55;
                speed = 30;
              }
              {
                temperature = 60;
                speed = 55;
              }
              {
                temperature = 65;
                speed = 100;
              }
            ];
          };

          oled = {
            switchDuration = lib.mkOption {
              type = lib.types.ints.unsigned;
              default = 30;
            };

            screenList = lib.mkOption {
              type = lib.types.listOf (lib.types.enum ["clock" "cpu" "storage" "raid" "ram" "temp" "ip"]);
              default = ["clock" "cpu" "storage" "raid" "ram" "temp" "ip"];
            };
          };

          ir = {
            enable = lib.mkEnableOption "Enable IR remote support";

            keymap = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;

              description = "Map each IR code to a key. The default list contains the code mappings for the Argon IR remote.";

              default = {
                "POWER" = "00ff39c6";
                "UP" = "00ff53ac";
                "DOWN" = "00ff4bb4";
                "LEFT" = "00ff9966";
                "RIGHT" = "00ff837c";
                "VOLUMEUP" = "00ff01fe";
                "VOLUMEDOWN" = "00ff817e";
                "OK" = "00ff738c";
                "HOME" = "00ffd32c";
                "MENU" = "00ffb946";
                "BACK" = "00ff09f6";
              };
            };

            gpio = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable the overlay that configures the GPIO pins of the RPI correctly";
              };

              pin = lib.mkOption {
                type = lib.types.int;
                description = "The pin to configure to be used for the IR receiver. Should not need to be changed";
                default = 23;
              };
            };
          };
        };
      };

      eon = {
        enable = lib.mkEnableOption "Enable argoneond service";

        package = lib.mkOption {
          type = lib.types.package;
          default = packages.argoneond;
        };

        settings = {
          # rtc = {
          # };
        };
      };
    };
  };

  config = {
    environment = {
      systemPackages =
        lib.optional cfg.one.enable cfg.one.package
        ++ lib.optional cfg.eon.enable cfg.eon.package;

      etc = {
        "argonunits.conf" = lib.mkIf cfg.one.enable (let
          mappings = {
            "celsius" = "C";
            "fahrenheit" = "F";
          };
        in {
          text = ''
            #
            # Argon Unit Configuration
            # Generated by NixOS
            #
            temperature=${mappings."${cfg.one.settings.displayUnits}"}
          '';
          mode = "0666";
        });

        "argononed.conf" = lib.mkIf cfg.one.enable {
          text = ''
            #
            # Argon Fan Speed Configuration (CPU)
            # Generated by NixOS
            #
            ${lib.concatMapStringsSep "\n" ({
              speed,
              temperature,
            }: "${toString temperature}=${toString speed}")
            cfg.one.settings.fanspeed}
          '';
          mode = "0666";
        };

        "argoneonoled.conf" = lib.mkIf cfg.one.enable {
          text = ''
            #
            # Argon OLED Configuration
            # Generated by NixOS
            #
            switchduration=${toString cfg.one.settings.oled.switchDuration}
            screenlist="${lib.concatStringsSep " " cfg.one.settings.oled.screenList}"
          '';
          mode = "0666";
        };

        "argoneonrtc.conf" = lib.mkIf cfg.eon.enable {
          text = ''
            #
            # Argon RTC Configuration
            # Generated by NixOS
            #
          '';
          mode = "0666";
        };
      };
    };

    systemd.services = {
      argononed = lib.mkIf cfg.one.enable {
        description = "Argon One Fan and Button Service";
        after = ["multi-user.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RemainAfterExit = true;
          ExecStart = "${cfg.one.package}/bin/argononed SERVICE";
        };
      };

      argoneond = lib.mkIf cfg.eon.enable {
        description = "Argon EON RTC Service";
        after = ["multi-user.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RemainAfterExit = true;
          ExecStart = "${cfg.eon.package}/bin/argoneond SERVICE";
        };
      };
    };

    services.lirc = lib.mkIf cfg.one.settings.ir.enable {
      enable = true;

      options = ''
        [lircd]
        nodaemon = False
      '';

      configs = [
        ''
          begin remote
            name        argon
            bits        32
            flags       SPACE_ENC
            eps         20
            aeps        200

            header      8800  4400
            one         550   1650
            zero        550   550
            ptrail      550
            repeat      8800  2200
            gap         38500
            toggle_bit  0

            frequency   38000

              begin codes
                ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "KEY_${name}  0x${value}") cfg.one.settings.ir.keymap)}
              end codes

          end remote
        ''
      ];
    };

    # Configure GPIO overlay for IR receiver.
    hardware.deviceTree = lib.mkIf (cfg.one.settings.ir.enable && cfg.one.settings.ir.gpio.enable) {
      overlays = [
        # Equivalent to:
        # https://github.com/raspberrypi/linux/blob/rpi-6.1.y/arch/arm/boot/dts/overlays/gpio-ir-overlay.dts
        {
          name = "rpi4-gpio-ir-overlay";
          dtsText = ''
            // Definitions for ir-gpio module
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";

              fragment@0 {
                target-path = "/";
                __overlay__ {
                  gpio_ir: ir-receiver@12 {
                    compatible = "gpio-ir-receiver";
                    pinctrl-names = "default";
                    pinctrl-0 = <&gpio_ir_pins>;

                    // pin number, high or low
                    gpios = <&gpio ${toString cfg.one.settings.ir.gpio.pin} 1>;

                    // parameter for keymap name
                    linux,rc-map-name = "rc-rc6-mce";

                    status = "okay";
                  };
                };
              };

              fragment@1 {
                target = <&gpio>;
                __overlay__ {
                  gpio_ir_pins: gpio_ir_pins@12 {
                    brcm,pins = <${toString cfg.one.settings.ir.gpio.pin}>;  // pin 23
                    brcm,function = <0>;                            // in
                    brcm,pull = <2>;                                // up
                  };
                };
              };
            };
          '';
        }
      ];
    };
  };
}
