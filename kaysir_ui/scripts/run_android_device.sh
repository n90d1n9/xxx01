#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
Usage:
  ./run_android_device.sh [--host ORIGIN] [--realm REALM]

Notes:
  - If --host is provided, the app will use gateway-style routes:
    ORIGIN/<realm>/auth, ORIGIN/<realm>/chat, ORIGIN/<realm>/ws, etc.
  - If --host is not provided, the script falls back to direct service ports
    on the detected LAN IP (identity 7101, chat 7109, mina signaling 2443).
EOF
}

HOST_ORIGIN=""
TENANT_REALM="${TENANT_REALM:-tsiqahub}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST_ORIGIN="$2"
      shift 2
      ;;
    --realm)
      TENANT_REALM="$2"
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

if ! command -v adb >/dev/null 2>&1; then
  echo "[ERROR] adb not found. Please install Android platform tools."
  exit 1
fi

get_host_ip() {
  local ip=""
  if command -v ipconfig >/dev/null 2>&1; then
    ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
    if [ -z "$ip" ]; then
      ip="$(ipconfig getifaddr en1 2>/dev/null || true)"
    fi
  fi
  if [ -z "$ip" ] && command -v ifconfig >/dev/null 2>&1; then
    ip="$(ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}')"
  fi
  echo "$ip"
}

can_reach_host() {
  local host="$1"
  local port="${2:-7101}"
  if [ -z "$host" ]; then
    return 1
  fi
  # Try TCP connect using bash built-in /dev/tcp (fast, no extra deps).
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/${host}/${port}" >/dev/null 2>&1
}

select_device() {
  local devices=()
  while read -r line; do
    [ -z "$line" ] && continue
    devices+=("$line")
  done < <(adb devices -l | awk 'NR>1 && $2=="device" {print $1}')
  if [ ${#devices[@]} -eq 0 ]; then
    echo "[ERROR] No Android device detected. Connect a device or start an emulator."
    exit 1
  fi
  if [ ${#devices[@]} -eq 1 ]; then
    echo "${devices[0]}"
    return
  fi
  echo "[INFO] Multiple devices detected:"
  local idx=1
  for dev in "${devices[@]}"; do
    echo "  [$idx] $dev"
    idx=$((idx + 1))
  done
  local choice=""
  while true; do
    read -r -p "Select device (1-${#devices[@]}): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#devices[@]}" ]; then
      echo "${devices[$((choice - 1))]}"
      return
    fi
    echo "Invalid selection."
  done
}

DEVICE_ID="${ANDROID_DEVICE_ID:-$(select_device)}"
AUTO_DETECTED_IP="$(get_host_ip)"
DEFAULT_BACKEND_HOST="${DEFAULT_BACKEND_HOST:-192.168.8.184}"

# IMPORTANT:
# Use "auto" by default so the app aligns with backend canonical user IDs.
# "username" can create legacy/duplicate DM rooms (uuid vs username) and can
# block strict E2EE sending when peer keys are published under UUID.
CHAT_USER_ID_SOURCE="${CHAT_USER_ID_SOURCE:-auto}"

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
    --dart-define=TENANT_REALM="$TENANT_REALM"
    --dart-define=AUTH_BASE_URL="${ORIGIN}/${TENANT_REALM}/auth"
    --dart-define=CHAT_BASE_URL="${ORIGIN}/${TENANT_REALM}/chat"
    --dart-define=CHAT_WS_BASE_URL="${WS_SCHEME}://${HOSTPORT}/${TENANT_REALM}/chat"
    --dart-define=MINA_SIGNALING_WS_URL="${WS_SCHEME}://${HOSTPORT}/${TENANT_REALM}/ws"
    --dart-define=MINA_NOTIFICATION_WS_URL="${WS_SCHEME}://${HOSTPORT}/${TENANT_REALM}/notifications/ws"
    --dart-define=ADMIN_BASE_URL="${ORIGIN}/${TENANT_REALM}/admin"
  )
  HOST_IP="$HOSTPORT"
else
  if [ -n "${BACKEND_HOST:-}" ]; then
    HOST_IP="$BACKEND_HOST"
  elif [ -n "$DEFAULT_BACKEND_HOST" ] && can_reach_host "$DEFAULT_BACKEND_HOST" 7101; then
    HOST_IP="$DEFAULT_BACKEND_HOST"
  else
    HOST_IP="$AUTO_DETECTED_IP"
  fi
  if [ -z "$HOST_IP" ]; then
    echo "[ERROR] Could not determine host IP. Set BACKEND_HOST manually."
    exit 1
  fi

  # Direct microservice ports (dev/local).
  EXTRA_DEFINES+=(
    --dart-define=BACKEND_HOST="$HOST_IP"
    --dart-define=TENANT_REALM="$TENANT_REALM"
    --dart-define=AUTH_BASE_URL="http://${HOST_IP}:7101"
    --dart-define=CHAT_BASE_URL="http://${HOST_IP}:7109"
    --dart-define=CHAT_WS_BASE_URL="ws://${HOST_IP}:7109"
    --dart-define=MINA_SIGNALING_WS_URL="${MINA_SIGNALING_WS_URL:-ws://${HOST_IP}:2443/ws}"
  )
fi

echo "[INFO] Using device: $DEVICE_ID"
echo "[INFO] Using host IP: $HOST_IP"
if [ -n "$AUTO_DETECTED_IP" ]; then
  echo "[INFO] Auto-detected IP: $AUTO_DETECTED_IP"
fi
if [ -n "$DEFAULT_BACKEND_HOST" ]; then
  echo "[INFO] Default BACKEND_HOST: $DEFAULT_BACKEND_HOST"
fi
echo "[INFO] TENANT_REALM=$TENANT_REALM CHAT_USER_ID_SOURCE=$CHAT_USER_ID_SOURCE"

flutter run -d "$DEVICE_ID" \
  "${EXTRA_DEFINES[@]}" \
  --dart-define=CHAT_USER_ID_SOURCE="$CHAT_USER_ID_SOURCE"
