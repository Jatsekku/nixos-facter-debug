{ config, lib, ... }:
let
  cfg = config.hardware.facter-debug;
in
{
  options.hardware.facter-debug = {
    enable = lib.mkEnableOption "nixos-facter-debug module";

    package = {
      nvd = lib.mkOption {
        type = lib.types.package;
        description = "nixos.facter.debug.nvd wrapper package";
      };
      nix-diff = lib.mkOption {
        type = lib.types.package;
        description = "nixos.facter.debug.nix-diff wrapper package";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package.nvd
      cfg.package.nix-diff
    ];
  };
}
