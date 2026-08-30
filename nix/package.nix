{ pkgs, bash-logger }:
let
  # Path to external lib (bash-logger)
  bash-logger-scriptPath = bash-logger.passthru.scriptPath;

  common-scriptPath = ../src/common.sh;
  nvd-scriptPath = ../src/nvd.sh;
  nix-diff-scriptPath = ../src/nix-diff.sh;

  nvd-scriptContent = builtins.readFile nvd-scriptPath;
  nix-diff-scriptContent = builtins.readFile nix-diff-scriptPath;

  runtimeInputs = [
    bash-logger
    pkgs.bash
  ];
in
{
  nvd = pkgs.writeShellApplication {
    inherit runtimeInputs;
    name = "nixos-facter-nvd";
    text = ''
      export BASH_LOGGER_SH=${bash-logger-scriptPath}
      export NIXOS_FACTER_DEBUG_COMMON_SH=${common-scriptPath}

      ${nvd-scriptContent}
    '';

  };

  nix-diff = pkgs.writeShellApplication {
    inherit runtimeInputs;
    name = "nixos-facter-nix-diff";
    text = ''
      export BASH_LOGGER_SH=${bash-logger-scriptPath}
      export NIXOS_FACTER_DEBUG_COMMON_SH=${common-scriptPath}

      ${nix-diff-scriptContent}
    '';
  };
}
