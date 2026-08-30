{ pkgs, testModule, ... }:

pkgs.testers.runNixOSTest {
  name = "nixos-facter-debug-module-test";

  nodes.machine = { ... }: {
    imports = [ testModule ];
    hardware.facter-debug.enable = true;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Check package got installed
    machine.succeed("which nixos-facter-nvd")
    machine.succeed("which nixos-facter-nix-diff")
  '';
}
