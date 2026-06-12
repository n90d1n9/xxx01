#!/usr/bin/env bash
# ---------------------------------------------------------
# generate_from_template.sh – generic template processor
# ---------------------------------------------------------
# This script scans the directory where it resides for any file
# ending with ".master" (e.g. set.pubspec.yaml.master, config.json.master).
# For each such file it:
#   1. Backs up an existing target file (same name without the .master suffix).
#   2. Expands **all** environment‑variable placeholders (${VAR}) using
#      envsubst (so any ${KY_LIBRARIES}, ${HOME}, etc. will be replaced).
#   3. Writes the result to the target file in the *same directory* as the
#      template (the "rot" or root of the generator).
#
# Usage: run the script from its own directory (no arguments required).
# ---------------------------------------------------------

# Load workspace environment variables (so ${KY_LIBRARIES} is defined)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../set_env.sh"

# Ensure envsubst is available – it ships with GNU gettext on macOS via brew
if ! command -v envsubst >/dev/null 2>&1; then
  echo "❌ envsubst not found. Install it (brew install gettext) and ensure it's in PATH."
  exit 1
fi

# Iterate over all *.master files in the script directory
shopt -s nullglob
for TEMPLATE_PATH in "${SCRIPT_DIR}"/*.master; do
  TEMPLATE_NAME="$(basename "${TEMPLATE_PATH}")"
  # Target file = same name without the .master suffix
  TARGET_NAME="${TEMPLATE_NAME%.master}"
  TARGET_PATH="${SCRIPT_DIR}/${TARGET_NAME}"

  # Backup existing target if it exists
  if [[ -f "${TARGET_PATH}" ]]; then
    cp "${TARGET_PATH}" "${TARGET_PATH}.bak"
    echo "🔐 Backup created: ${TARGET_PATH}.bak"
  fi

  # Perform variable substitution using envsubst
  envsubst < "${TEMPLATE_PATH}" > "${TARGET_PATH}"
  echo "✅ Generated ${TARGET_NAME} from ${TEMPLATE_NAME}"
done

exit 0
