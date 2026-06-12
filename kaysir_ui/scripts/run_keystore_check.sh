#!/bin/bash

keytool -list -v \
 -keystore release.keystore \
 -storepass "M!ku0n3Ummah"


alias=$(keytool -list -keystore release.keystore -storepass "$MIKU_STORE_PASSWORD" 2>/dev/null | grep ', PrivateKeyEntry' | cut -d',' -f1)
echo "Detected alias: $alias"

