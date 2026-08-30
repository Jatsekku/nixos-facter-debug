{
  description = "Wrappers for nixos-facter's nvd and nix-diff";

  # Flake inputs
  inputs = {
    # Feature-rich, flexible logger utility for bash.
    bash-logger = {
      url = "github:Jatsekku/bash-logger";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Packages collection & NixOS.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ self, ... }:
    let
      # List of all supported systems
      supportedSystems = inputs.nixpkgs.lib.systems.flakeExposed;

      # Function for providing system-specific attributes
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            # Nixpkgs configured per system
            pkgs = import inputs.nixpkgs {
              inherit system;
              # Apply overlays defined by flake itself
              overlays = [ self.overlays.default ];
            };
            inherit system;
          }
        );

    in
    {
      # Provide packages
      packages = forEachSupportedSystem (
        { pkgs, system }:
        let
          # Dependencies
          bash-logger = inputs.bash-logger.packages.${system}.default;

          # Build package set
          nixos-facter-debug-pkg = pkgs.callPackage ./nix/package.nix {
            inherit bash-logger;
          };
        in
        {
          # Expose packages
          nixos-facter-debug-nvd = nixos-facter-debug-pkg.nvd;
          nixos-facter-debug-nix-diff = nixos-facter-debug-pkg.nix-diff;
        }
      );

      # Inject packages via overlays
      overlays.default = final: prev: {
        inherit (self.packages.${final.system})
          nixos-facter-debug-nvd
          nixos-facter-debug-nix-diff
          ;
      };

      # Provide NixOs modules
      nixosModules = rec {
        nixos-facter-debug = { pkgs, lib, ... }: {
          # Import the pure file directly here
          imports = [ ./nix/module.nix ];

          # Inject the default packages
          hardware.facter-debug.package.nvd =
            lib.mkDefault
              self.packages.${pkgs.system}.nixos-facter-debug-nvd;
          hardware.facter-debug.package.nix-diff =
            lib.mkDefault
              self.packages.${pkgs.system}.nixos-facter-debug-nix-diff;
        };

        # Alias default to the exact same module
        default = nixos-facter-debug;
      };

      # Add Nix checks
      checks = forEachSupportedSystem (
        { pkgs, ... }:
        {
          module-test = import ./nix/test/module-test.nix {
            inherit pkgs;
            testModule = self.nixosModules.default;
          };
        }
      );

      # Generate devShell for each system
      devShells = forEachSupportedSystem ({ pkgs, ... }: import ./nix/devshell.nix { inherit pkgs; });

      # Set formatter for Nix
      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
