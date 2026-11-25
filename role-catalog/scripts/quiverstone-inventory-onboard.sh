#!/usr/bin/env bash
#
# Quiverstone organization inventory role onboarding (AWS CloudShell).
#
# Kept for commands generated before the multi-role script existed:
#   curl -fsSL <url>/quiverstone-inventory-onboard.sh | bash -s -- --variant direct ...
# It downloads quiverstone-onboard.sh from the same role-catalog location and
# runs it with --role-type org-inventory. New commands call
# quiverstone-onboard.sh directly.
set -euo pipefail

SCRIPT_BASE="${QUIVERSTONE_SCRIPT_BASE:-https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts}"
[[ "$SCRIPT_BASE" =~ ^https://[A-Za-z0-9.-]+(/[A-Za-z0-9._/-]*)?$ ]] || { echo "ERROR: QUIVERSTONE_SCRIPT_BASE must be an https URL" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
URL="$SCRIPT_BASE/quiverstone-onboard.sh"
HTTP_CODE="$(curl -sS -L -o "$TMP/quiverstone-onboard.sh" -w '%{http_code}' "$URL" 2>"$TMP/curl.err" || true)"
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: could not download the Quiverstone onboarding script (HTTP ${HTTP_CODE:-none}) from $URL. $(tr -d '\n' <"$TMP/curl.err")" >&2
  exit 1
fi
bash "$TMP/quiverstone-onboard.sh" --role-type org-inventory "$@"
