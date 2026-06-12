#!/usr/bin/env sh
set -eu

# Build and run the native artifact host example against Waraq's static library.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CRATE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

cd "$CRATE_DIR"

PROFILE=${PROFILE:-debug}
TARGET_DIR=${CARGO_TARGET_DIR:-"$CRATE_DIR/../target"}
CC_BIN=${CC:-cc}
CXX_BIN=${CXX:-c++}

case "$PROFILE" in
    debug)
        cargo build --offline
        ;;
    release)
        cargo build --offline --release
        ;;
    *)
        echo "PROFILE must be 'debug' or 'release', got: $PROFILE" >&2
        exit 1
        ;;
esac

LIB="$TARGET_DIR/$PROFILE/libwaraq_core.a"
C_OUT="$TARGET_DIR/$PROFILE/artifact_host_workflow_example"
SYMBOLS_OUT="$TARGET_DIR/$PROFILE/artifact_api_symbols_smoke"
CPP_OUT="$TARGET_DIR/$PROFILE/artifact_header_cpp_smoke"

if [ ! -f "$LIB" ]; then
    echo "missing static library: $LIB" >&2
    exit 1
fi

set -- "$CC_BIN" -std=c11 -Wall -Wextra -Werror \
    "$SCRIPT_DIR/artifact_host_workflow.c" \
    -I "$CRATE_DIR" \
    "$LIB" \
    -o "$C_OUT"

case "$(uname -s)" in
    Linux*)
        set -- "$@" -ldl -lpthread -lm
        ;;
esac

"$@"
"$C_OUT"

set -- "$CC_BIN" -std=c11 -Wall -Wextra -Werror \
    "$SCRIPT_DIR/artifact_api_symbols_smoke.c" \
    -I "$CRATE_DIR" \
    "$LIB" \
    -o "$SYMBOLS_OUT"

case "$(uname -s)" in
    Linux*)
        set -- "$@" -ldl -lpthread -lm
        ;;
esac

"$@"
"$SYMBOLS_OUT"

set -- "$CXX_BIN" -std=c++17 -Wall -Wextra -Werror \
    "$SCRIPT_DIR/artifact_header_cpp_smoke.cpp" \
    -I "$CRATE_DIR" \
    "$LIB" \
    -o "$CPP_OUT"

case "$(uname -s)" in
    Linux*)
        set -- "$@" -ldl -lpthread -lm
        ;;
esac

"$@"
"$CPP_OUT"

printf '%s\n' "artifact_host_workflow_example ok"
printf '%s\n' "artifact_api_symbols_smoke ok"
printf '%s\n' "artifact_header_cpp_smoke ok"
