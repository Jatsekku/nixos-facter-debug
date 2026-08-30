#!/run/current-system/sw/bin/bash
# ^ Shebang for non-nix fallback

# Prevent multiple sourcing
if [ -n "${__NIXOS_FACTER_DEBUG_COMMON_SH_SOURCED:-}" ]; then
    return
fi
readonly __NIXOS_FACTER_DEBUG_COMMON_SH_SOURCED=1

# shellcheck disable=SC1090,SC1091
source "${BASH_LOGGER_SH}"

logger_register_module "nixos-facter-debug::common" LOG_LEVEL_ALL
logger_set_log_format "[%cs%lvl%ce] %msg"
logger_enable_file_logging 0

__find_flake() {
  if [ -n "${NH_OS_FLAKE:-}" ]; then
    echo "$NH_OS_FLAKE"
  elif [ -n "${NH_FLAKE:-}" ]; then
    echo "$NH_FLAKE"
  elif [ -f "/etc/nixos/flake.nix" ]; then
    echo "/etc/nixos/flake.nix"
  else
    echo ""
  fi
}

##################################### API #####################################
get_flake() {
  local -r flake_path="$(__find_flake)"
  local msg

  if [ -z "$flake_path" ]; then
        msg="Could not obtain flake path."
        msg+=" Checked: NH_OS_FLAKE, NH_FLAKE, /etc/nixos/flake.nix"
        log_err "$msg"
        return 1
  fi

  log_inf "Flake path obtained: [${flake_path}]"
  echo "$flake_path"
}

get_current_hostname() {
    local hostname=""
    local msg

    if [ -f /etc/hostname ]; then
        hostname="$(< /etc/hostname)"
    else
        msg="Could not obtain current hostname:"
        msg+=" /etc/hostname does not exist"
        log_err "$msg"
    fi

    if [ -z "$hostname" ]; then
        msg="Could not obtain current hostname:"
        msg+=" hostname string is empty"
        log_err "$msg"
        return 1
    fi

    log_inf "Current hostname obtained: [${hostname}]"
    echo "$hostname"
}

