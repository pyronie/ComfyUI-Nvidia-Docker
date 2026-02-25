#!/bin/bash

# Pre-requisites (run first):
# - 00-nvidiaDev.sh

# Install decord -- for RMBG AI SAM3 -- on arm64 (DGX10)
# Recommended: add 'video' to NVIDIA_DRIVER_CAPABILITIES to have libnvcuvid.so available
# Original: https://github.com/dmlc/decord
# Using: https://github.com/johnnynunez/decord2
# as discovered on https://github.com/dmlc/decord/issues/297

# --- CONFIGURATION ---
FORCE_REINSTALL="${FORCE_REINSTALL:-false}"
# ---------------------

# --- COLOR CODES (for console)---
LOG_ERR=$(printf '\033[0;41m') # White on RED BG
# LOG_ERR=$(printf '\033[0;91m') # Red on Black BG
# LOG_ERR=$(printf '\033[0m') # No Color

LOG_WARN=$(printf '\033[0;33m') # Yellow
# LOG_WARN=$(printf '\033[0m') # No Color 

LOG_OK=$(printf '\033[0;32m') # GREEN
# LOG_OK=$(printf '\033[0m') # No Color 

# LOG_INFO=$(printf '\033[0;32m') # Green 
LOG_INFO=$(printf '\033[0m') # No Color

NC=$(printf '\033[0m') # No Color
# --------------------------------

set -e

error_exit() {
 echo -n -e "${LOG_ERR}!! ERROR: ${NC}"
  echo $*
  echo "!! Exiting decord script (ID: $$)"
  exit 1
}

source /comfy/mnt/venv/bin/activate || error_exit "Failed to activate virtualenv"

# --- CHECK EXISTING INSTALLATION ---
if [ "$FORCE_REINSTALL" = "false" ]; then
    if pip show decord > /dev/null 2>&1; then
        echo "${LOG_INFO}INFO:${NC} decord is already installed."
        echo "     (Set FORCE_REINSTALL=true in script to force rebuild/reinstall)"
        exit 0
    fi
else
    echo "${LOG_INFO}INFO:${NC} FORCE_REINSTALL is true. Proceeding..."
fi
# -----------------------------------

echo "** Installing decord on Arm64 (DGX10) **"

# Confirm we are on arm64
if [ "$(uname -m)" != "aarch64" ]; then
    echo   "${LOG_WARN}WARNING:${NC} This script is for arm64 only, exiting"
    exit 0
fi

# We need both uv and the cache directory to enable build with uv
use_uv=true
uv="/comfy/mnt/venv/bin/uv"
uv_cache="/comfy/mnt/uv_cache"
if [ ! -x "$uv" ] || [ ! -d "$uv_cache" ]; then use_uv=false; fi

if [ "A$use_uv" == "Atrue" ]; then
  if [ -z "${UV_TORCH_BACKEND+x}" ]; then error_exit "UV_TORCH_BACKEND is not set"; fi
  echo "== Using uv"
  echo " - uv: $uv"
  echo " - uv_cache: $uv_cache"
  echo " - UV_TORCH_BACKEND: $UV_TORCH_BACKEND"
else
  echo "== Using pip"
  echo " - TORCH_INDEX_URL: $TORCH_INDEX_URL"
fi

CMD="${PIP3_CMD} decord2 ${PIP3_XTRA}"
echo "CMD: \"${CMD}\""
${CMD} || error_exit "Failed to install decord"
echo "${LOG_OK}SUCCESS:${NC} decord installed successfully"
exit 0
