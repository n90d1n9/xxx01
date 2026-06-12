#!/bin/bash

set -euo pipefail

# Extract version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')

echo "Detected version: $VERSION"


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat <<'EOF'
Usage: ./build-android-production.sh [OPTIONS]

Build tsiqahub Android release with backend host/ip injected.

Options:
  --profile PROFILE   production or demo. Default: production
                       demo injects OFFLINE_MODE=true and uses dummy data.
  --host HOST          Required backend host or IP for production.
                       Optional for demo. Default demo host: localhost:7100
  --realm REALM        Tenant realm. Default: tsiqahub
  --type TYPE          apk or aab. Default: apk
  --clean              Run flutter clean first
  --pub-get            Run flutter pub get before build
  --no-pub-get         Skip flutter pub get
  --chat-user-id-source VALUE
                       Default: auto
  --mina-ws URL        Override Mina signaling websocket URL
  --install            Install the built APK to a connected device via adb
  --help, -h           Show this help

Examples:
  ./build-android-production.sh --profile demo
  ./build-android-production.sh --profile production --host [IP_ADDRESS]
  ./build-android-production.sh --host api.tsiqahub.com --type aab --clean
EOF
}

BUILD_PROFILE="production"
HOST=""
REALM="tsiqahub"
BUILD_TYPE="apk"
RUN_CLEAN=false
RUN_PUB_GET=true
CHAT_USER_ID_SOURCE="auto"
MINA_WS=""
INSTALL_AFTER_BUILD=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            BUILD_PROFILE="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        --realm)
            REALM="$2"
            shift 2
            ;;
        --type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --clean)
            RUN_CLEAN=true
            shift
            ;;
        --pub-get)
            RUN_PUB_GET=true
            shift
            ;;
        --no-pub-get)
            RUN_PUB_GET=false
            shift
            ;;
        --chat-user-id-source)
            CHAT_USER_ID_SOURCE="$2"
            shift 2
            ;;
        --mina-ws)
            MINA_WS="$2"
            shift 2
            ;;
        --install)
            INSTALL_AFTER_BUILD=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo
            usage
            exit 1
            ;;
    esac
done

if [[ "$BUILD_PROFILE" != "production" && "$BUILD_PROFILE" != "demo" ]]; then
    print_error "--profile must be 'production' or 'demo'"
    exit 1
fi

OFFLINE_MODE=false
OUTPUT_KIND="release"
if [[ "$BUILD_PROFILE" == "demo" ]]; then
    OFFLINE_MODE=true
    OUTPUT_KIND="demo"
    if [[ -z "$HOST" ]]; then
        HOST="localhost:7100"
    fi
fi

if [[ -z "$HOST" ]]; then
    print_error "--host is required for production builds"
    echo
    usage
    exit 1
fi

if [[ "$BUILD_TYPE" != "apk" && "$BUILD_TYPE" != "aab" ]]; then
    print_error "--type must be 'apk' or 'aab'"
    exit 1
fi

# Accept both "api.example.com" and "https://api.example.com".
HOST_RAW="${HOST%/}"
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

AUTH_BASE_URL="${ORIGIN}/${REALM}/auth"
CHAT_BASE_URL="${ORIGIN}/${REALM}/chat"
CHAT_WS_BASE_URL="${WS_SCHEME}://${HOSTPORT}/${REALM}/chat"
MINA_SIGNALING_WS_URL="${MINA_WS:-${WS_SCHEME}://${HOSTPORT}/${REALM}/ws}"
ADMIN_BASE_URL="${ORIGIN}/${REALM}/admin"

# Build metadata to verify installs on device.
BUILD_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
BUILD_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

print_header "Tsiqahub UI Android Build"
echo "Project: $SCRIPT_DIR"
echo "Profile: $BUILD_PROFILE"
echo "Offline mode: $OFFLINE_MODE"
echo "Host: $HOST"
echo "Origin: $ORIGIN"
echo "Realm: $REALM"
echo "Type: $BUILD_TYPE"
echo "Auth URL: $AUTH_BASE_URL"
echo "Chat URL: $CHAT_BASE_URL"
echo "Mina WS: $MINA_SIGNALING_WS_URL"
echo "Admin URL: $ADMIN_BASE_URL"

if [[ "$RUN_CLEAN" == true ]]; then
    print_header "Cleaning previous build"
    flutter clean
fi

if [[ "$RUN_PUB_GET" == true ]]; then
    print_header "Fetching dependencies"
    flutter pub get
fi

BUILD_CMD=(flutter build)
if [[ "$BUILD_TYPE" == "aab" ]]; then
    BUILD_CMD+=(appbundle)
else
    BUILD_CMD+=(apk)
fi
BUILD_CMD+=(
    --release
    --no-tree-shake-icons
    --dart-define=OFFLINE_MODE="$OFFLINE_MODE"
    --dart-define=API_BASE_URL="$ORIGIN"
    --dart-define=AUTO_DETECT_HOST=false
    --dart-define=BACKEND_HOST="$HOSTPORT"
    --dart-define=TENANT_REALM="$REALM"
    --dart-define=AUTH_BASE_URL="$AUTH_BASE_URL"
    --dart-define=CHAT_BASE_URL="$CHAT_BASE_URL"
    --dart-define=CHAT_WS_BASE_URL="$CHAT_WS_BASE_URL"
    --dart-define=MINA_SIGNALING_WS_URL="$MINA_SIGNALING_WS_URL"
    --dart-define=CHAT_USER_ID_SOURCE="$CHAT_USER_ID_SOURCE"
    --dart-define=ADMIN_BASE_URL="$ADMIN_BASE_URL"
    --dart-define=BUILD_SHA="$BUILD_SHA"
    --dart-define=BUILD_TIME="$BUILD_TIME"
)

print_header "Building Android release"
"${BUILD_CMD[@]}"


if [[ "$BUILD_TYPE" == "aab" ]]; then
    OUTPUT_PATH="$HOME/Library/CloudStorage/Dropbox/proyek/Tsiqahub/tsiqahub-$OUTPUT_KIND-v$VERSION.aab"

     cp ../build/app/outputs/bundle/release/app-release.aab "$OUTPUT_PATH"
else
    OUTPUT_PATH="$HOME/Library/CloudStorage/Dropbox/proyek/Tsiqahub/tsiqahub-$OUTPUT_KIND-v$VERSION.apk"
     cp ../build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_PATH"
fi


if [[ ! -f "$OUTPUT_PATH" ]]; then
    print_error "Build finished but expected output was not found: $OUTPUT_PATH"
    exit 1
fi

print_success "Android $BUILD_PROFILE build completed"
echo "Output: $OUTPUT_PATH"

if [[ "$INSTALL_AFTER_BUILD" == true && "$BUILD_TYPE" == "apk" ]]; then
    if ! command -v adb >/dev/null 2>&1; then
        print_error "adb not found in PATH; cannot --install"
        exit 1
    fi
    print_header "Installing APK via adb"
    adb devices
    adb install -r ../build/app/outputs/flutter-apk/app-release.apk
    print_success "Installed to device"
fi
