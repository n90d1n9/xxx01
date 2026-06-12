#!/usr/bin/env bash
# ---------------------------------------------------------
# gen_from_template.sh
# ---------------------------------------------------------
# Generates an output file from a template file by substituting
# environment variables (like ${KY_LIBRARIES}) using envsubst.
#
# Usage:
#   ./scripts/gen_from_template.sh -i master.pubspec.yaml -o pubspec.yaml
# ---------------------------------------------------------

# Load workspace environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------

INPUT_FILE=""
OUTPUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--input) INPUT_FILE="$2"; shift ;;
        -o|--output) OUTPUT_FILE="$2"; shift ;;
        *) echo "❌ Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" ]]; then
    echo "Usage: $0 -i <template-file> -o <target-file>"
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Input file not found: $INPUT_FILE"
    exit 1
fi

if ! command -v envsubst >/dev/null 2>&1; then
  echo "❌ envsubst not found. Please install it."
  exit 1
fi

# Expand environment variables using envsubst, and replace any tilde (~)
# at the start of a path with the absolute home directory, because
# Flutter's pub get cannot parse paths starting with ~.
envsubst < "$INPUT_FILE" | sed "s|~/|$HOME/|g" > "$OUTPUT_FILE"

echo "✅ Successfully generated $OUTPUT_FILE from $INPUT_FILE"
exit 0
