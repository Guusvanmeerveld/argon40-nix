# Argon40 scripts for NixOS

This flake aims to package the [Argon40](https://argon40.com/) install script for NixOS so that it can be easily installed on a Raspberry Pi running NixOS. The [install script](https://download.argon40.com/argon1.sh) was written for Raspberry Pi OS and its derivatives and thus expects to be run in an FHS compliant environment. This flake was written using the install script as a main inspiration. Using this flake also has the advantage of declaritively specifying the fan speed mappings of the case, which is preferable when using NixOS. I personally have the [Argon ONE M.2 Case for Raspberry Pi 4](https://argon40.com/products/argon-one-m-2-case-for-raspberry-pi-4) and the [Argon EON Pi NAS](https://argon40.com/products/argon-eon-pi-nas) and have tested this flake on both.

## Installation

### With flakes

Add the following into the desired `flake.nix` file.

```nix
{
    inputs.argon40-nix.url = "github:guusvanmeerveld/argon40-nix";
}
```

## Usage

### Module import

Simply import the NixOS module as follows:

```nix
{ inputs, ... }: {
    imports = [inputs.argon40-nix.nixosModules.default];
}
```

### Example configuration for Argon ONE case

```nix
{ inputs, ... }: {
    imports = [inputs.argon40-nix.nixosModules.default];

    config = {
        programs.argon.one = {
            enable = true;

            settings = {
                # Is 'celsius' by default, can also be set to 'fahrenheit'
                displayUnits = "celsius";

                # This is the same config as the original Argon40 config.
                # This is also the default config for this flake.
                fanspeed = [
                    {
                        # This the temperature threshold at which this fan speed will activate.
                        # The temperature is in the above specified unit.
                        temperature = 55;
                        # This is speed percentage at which the fan will spin.
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
        };
    };
}
```

### Example configuration for Argon EON case

```nix
{ inputs, ... }: {
    imports = [inputs.argon40-nix.nixosModules.default];

    config = {
        programs.argon = {
            # IMPORTANT: Note that the module for the Argon ONE also has to be enabled in order for the OLED screen on the EON to work, since that functionality is part of the Argon ONE service.
            one = {
                enable = true;

                settings = {
                    oled = {
                        # Configure what modules will show up on the OLED screen.
                        screenList = ["clock" "cpu" "storage" "raid" "ram" "temp" "ip"];
                        # Configure how long it takes to switch between modules.
                        switchDuration = 30;
                    };
                };
            };

            # All this does is enable the RTC service.
            eon.enable = true;
        };
    };
}
```

## Thanks to

- [Argon40](https://argon40.com/) for providing such an awesome case, continuously providing updates and [open sourcing](https://github.com/Argon40Tech) their projects.
- [okunze's repo](https://github.com/okunze/Argon40-ArgonOne-Script) containing an up to date version of the argon40 install script.
