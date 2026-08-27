#!/usr/bin/env bash

CERT_PATH="$1"
KEY_PATH="$2"

# Ambil dari env (dengan fallback nilai default jika env kosong)
APISIX_ADMIN_URL="${APISIX_ADMIN_URL:-http://127.0.0.1:9180}"
APISIX_ADMIN_KEY="${APISIX_ADMIN_KEY:-edd1c9f034335f136f87ad84b625c8f1}"
DOMAIN_NAME="${DOMAIN_NAME:-app.local}"
SSL_ID="${SSL_ID:-1}"

CERT=$(cat "$CERT_PATH" | sed ':a;N;$!ba;s/\n/\\n/g')
KEY=$(cat "$KEY_PATH" | sed ':a;N;$!ba;s/\n/\\n/g')

curl -i "$APISIX_ADMIN_URL/apisix/admin/ssls/$SSL_ID" \
  -H "X-API-KEY: $APISIX_ADMIN_KEY" \
  -X PUT -d "{
    \"snis\": [\"$DOMAIN_NAME\"],
    \"cert\": \"$CERT\",
    \"key\": \"$KEY\"
  }"