#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${GLUALINT_VERSION:-1.29.0}"
BIN_DIR="${ROOT_DIR}/.tools/glualint/${VERSION}/bin"

if [[ ! -x "${BIN_DIR}/glualint" && ! -x "${BIN_DIR}/glualint.exe" ]]; then
  "${ROOT_DIR}/scripts/install-glualint.sh"
fi

if [[ -x "${BIN_DIR}/glualint" ]]; then
  GLUALINT="${BIN_DIR}/glualint"
else
  GLUALINT="${BIN_DIR}/glualint.exe"
fi

if [[ "$#" -gt 0 ]]; then
  exec "${GLUALINT}" "$@"
fi

exec "${GLUALINT}" lint "${ROOT_DIR}/gamemodes/terrortown/entities/weapons/ttt_bomb_vest/shared.lua"
