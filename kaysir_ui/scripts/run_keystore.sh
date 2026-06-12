#!/bin/bash

# Validate that required env vars are set
: "${TSIQAHUB_KEY_ALIAS:?Need to set TSIQAHUB_KEY_ALIAS}"
: "${TSIQAHUB_KEY_PASSWORD:?Need to set TSIQAHUB_KEY_PASSWORD}"

keytool -genkeypair -v \
 -keystore release.keystore \
 -alias tsiqahub \
 -keyalg RSA \
 -keysize 2048 \
 -validity 10000 \
 -storepass "$TSIQAHUB_KEY_PASSWORD" \
 -keypass "$TSIQAHUB_KEY_PASSWORD" \
 -dname "CN=TSIQAHUB, OU=TSIQAHUB, O=TSIQAHUB, L=Bandung, S=Jawa Barat, C=Indonesia"

