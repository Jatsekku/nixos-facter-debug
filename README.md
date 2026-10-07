# NixOS facter-debug Module

NixOS module providing shell wrappers for facter's (`nvd` and `nix-diff`).

---

## Options reference

### NixOS Module Options <br>`hardware.facter-debug`

| Option             | Type    | Default    | Description                                      |
| :----------------- | :------ | :--------- | :----------------------------------------------- |
| `enable`           | bool    | `false`    | Whether to enable the nixos-facter-debug module. |
| `package.nvd`      | package |            | `nixos.facter.debug.nvd` wrapper package.        |
| `package.nix-diff` | package |            | `nixos.facter.debug.nix-diff` wrapper package.   |

---

## Usage examples

1. Add the module to your flake.nix inputs:
```nix
nixos-facter-debug = {
  url = "github:Jatsekku/nixos-facter-debug";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

2. Import the NixOS module:
```nix
imports = [ inputs.nixos-facter-debug.nixosModules.default ];
```

3. Enable module:
```
hardware.facter-debug.enable = true;
```

4. Now you can use:
```shell
nixos-facter-nix-diff
nixos-facter-nvd
```

---

