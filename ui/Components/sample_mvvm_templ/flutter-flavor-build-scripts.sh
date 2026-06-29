#!/bin/bash

# build_flavors.sh
#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PLATFORMS=("android" "ios")
FLAVORS=("dev" "staging" "prod")

# Secret Rotation Configuration
SECRET_ROTATION_INTERVAL_DAYS=30
ENCRYPTION_KEY_LENGTH=32

# Function to generate cryptographically secure secrets
generate_secret() {
  openssl rand -base64 $ENCRYPTION_KEY_LENGTH
}

# Secret Rotation Logic
rotate_secrets() {
  local flavor=$1
  local current_date=$(date +%s)
  local last_rotation_file=".$flavor_secret_rotation"

  # Check if rotation is needed
  if [ -f "$last_rotation_file" ]; then
    local last_rotation=$(cat "$last_rotation_file")
    local days_since_rotation=$(( (current_date - last_rotation) / (24 * 3600) ))
    
    if [ "$days_since_rotation" -lt "$SECRET_ROTATION_INTERVAL_DAYS" ]; then
      echo -e "${YELLOW}Skipping secret rotation for $flavor (too recent)${NC}"
      return
    fi
  fi

  # Generate new secrets
  local new_api_key=$(generate_secret)
  local new_encryption_key=$(generate_secret)

  # Update secret management system
  flutter_secure_storage_update \
    --flavor "$flavor" \
    --api-key "$new_api_key" \
    --encryption-key "$new_encryption_key"

  # Record rotation timestamp
  echo "$current_date" > "$last_rotation_file"
  
  echo -e "${GREEN}Secrets rotated successfully for $flavor${NC}"
}

# Build function for each platform and flavor
build_app() {
  local platform=$1
  local flavor=$2

  echo -e "${YELLOW}Building $platform app for $flavor flavor${NC}"

  # Rotate secrets before build
  rotate_secrets "$flavor"

  case "$platform" in
    "android")
      flutter build apk \
        --flavor "$flavor" \
        --target "lib/main_$flavor.dart"
      ;;
    "ios")
      flutter build ios \
        --flavor "$flavor" \
        --target "lib/main_$flavor.dart"
      ;;
    *)
      echo "Unsupported platform: $platform"
      exit 1
      ;;
  esac
}

# Main build script
main() {
  for flavor in "${FLAVORS[@]}"; do
    for platform in "${PLATFORMS[@]}"; do
      build_app "$platform" "$flavor"
    done
  done
}

# Execute main script
main

# Additional deployment script
#!/bin/bash
deploy_to_stores() {
  local flavor=$1

  case "$flavor" in
    "dev")
      fastlane distribute_internal
      ;;
    "staging")
      fastlane distribute_beta
      ;;
    "prod")
      fastlane distribute_production
      ;;
  esac
}

# Comprehensive secret management wrapper
secret_management() {
  local action=$1
  local flavor=$2

  case "$action" in
    "rotate")
      rotate_secrets "$flavor"
      ;;
    "backup")
      backup_secrets "$flavor"
      ;;
    "restore")
      restore_secrets "$flavor"
      ;;
    *)
      echo "Invalid secret management action"
      exit 1
      ;;
  esac
}

# GitHub Actions workflow integration
# .github/workflows/build_and_deploy.yml
name: Flutter CI/CD with Secret Rotation
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Rotate Secrets
        run: ./scripts/build_flavors.sh rotate
      
      - name: Build and Test
        run: |
          flutter pub get
          flutter test
          ./scripts/build_flavors.sh
      
      - name: Deploy to Stores
        run: ./scripts/deploy.sh
