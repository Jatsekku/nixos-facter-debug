#!/run/current-system/sw/bin/bash
# ^ Shebang for non-nix fallback

# Source common module
# shellcheck disable=SC1090,SC1091
source "${NIXOS_FACTER_DEBUG_COMMON_SH}"

main() {
local flake_path
  if ! flake_path="$(get_flake)"; then
    exit 1
  fi

  local target_host
  if ! target_host="$(get_current_hostname)"; then
    exit 1
  fi

  exec nix run "$flake_path#nixosConfigurations.${target_host}.config.hardware.facter.debug.nix-diff"
}

main
