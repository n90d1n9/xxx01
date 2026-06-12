#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./run_android.sh [--host ORIGIN] [--realm REALM] [--device DEVICE_ID]

Examples:
  ./run_android.sh
  ./run_android.sh --host http://localhost:7100
  ./run_android.sh --host https://api.tsiqahubone.com --realm tsiqahub --device emulator-5554
EOF
}

HOST_ORIGIN=""
REALM="tsiqahub"
DEVICE_ID="emulator-5554"
CHAT_USER_ID_SOURCE="${CHAT_USER_ID_SOURCE:-auto}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST_ORIGIN="$2"
      shift 2
      ;;
    --realm)
      REALM="$2"
      shift 2
      ;;
    --device)
      DEVICE_ID="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

EXTRA_DEFINES=()
if [[ -n "$HOST_ORIGIN" ]]; then
  HOST_RAW="${HOST_ORIGIN%/}"
  SCHEME=""
  HOSTPORT=""
  if [[ "$HOST_RAW" == *"://"* ]]; then
    SCHEME="${HOST_RAW%%://*}"
    HOSTPORT="${HOST_RAW#*://}"
  else
    SCHEME="http"
    HOSTPORT="$HOST_RAW"
  fi
  HOSTPORT="${HOSTPORT%%/*}"
  ORIGIN="${SCHEME}://${HOSTPORT}"
  WS_SCHEME="ws"
  if [[ "$SCHEME" == "https" ]]; then
    WS_SCHEME="wss"
  fi
  EXTRA_DEFINES+=(
    --dart-define=BACKEND_HOST="$HOSTPORT"
    --dart-define=TENANT_REALM="$REALM"
    --dart-define=AUTH_BASE_URL="${ORIGIN}/${REALM}/auth"
    --dart-define=CHAT_BASE_URL="${ORIGIN}/${REALM}/chat"
    --dart-define=CHAT_WS_BASE_URL="${WS_SCHEME}://${HOSTPORT}/${REALM}/chat"
    --dart-define=MINA_SIGNALING_WS_URL="${WS_SCHEME}://${HOSTPORT}/${REALM}/ws"
    --dart-define=MINA_NOTIFICATION_WS_URL="${WS_SCHEME}://${HOSTPORT}/${REALM}/notifications/ws"
    --dart-define=ADMIN_BASE_URL="${ORIGIN}/${REALM}/admin"
  )
fi

flutter run -d "$DEVICE_ID" \
  "${EXTRA_DEFINES[@]}" \
  --dart-define=CHAT_USER_ID_SOURCE="$CHAT_USER_ID_SOURCE"
