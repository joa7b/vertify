#!/bin/bash
# ---------------------------------------------------------------------------
# update-evolution-webhook.sh
#
# Detects the current ngrok public URL and updates the webhook URL
# on an existing Evolution API instance.
#
# Usage:
#   ./scripts/update-evolution-webhook.sh <instance_name>
#
# Environment variables (with defaults):
#   NGROK_API_URL       - ngrok local API  (default: http://127.0.0.1:4040)
#   EVOLUTION_API_URL   - Evolution API URL (default: http://localhost:8082)
#   EVOLUTION_API_KEY   - Evolution API key (default: evolution_api_key_default)
#   WEBHOOK_PATH        - Path appended to ngrok URL (default: /modules/evolution-api/webhook)
# ---------------------------------------------------------------------------
set -euo pipefail

INSTANCE_NAME="${1:-}"
if [ -z "$INSTANCE_NAME" ]; then
    echo "Usage: $0 <instance_name>"
    exit 1
fi

NGROK_API_URL="${NGROK_API_URL:-http://127.0.0.1:4040}"
EVOLUTION_API_URL="${EVOLUTION_API_URL:-http://localhost:8082}"
EVOLUTION_API_KEY="${EVOLUTION_API_KEY:-evolution_api_key_default}"
WEBHOOK_PATH="${WEBHOOK_PATH:-/modules/evolution-api/webhook}"

# ---- Step 1: Get the current ngrok public URL ----
echo "[1/3] Fetching ngrok tunnel URL from ${NGROK_API_URL} ..."

NGROK_RESPONSE=$(curl -sf "${NGROK_API_URL}/api/tunnels" 2>/dev/null) || {
    echo "ERROR: Could not reach ngrok API at ${NGROK_API_URL}"
    echo "       Make sure ngrok is running: ngrok http 3000"
    exit 1
}

# Extract the first https tunnel URL
NGROK_PUBLIC_URL=$(echo "$NGROK_RESPONSE" | grep -oP '"public_url"\s*:\s*"https://[^"]+' | head -1 | sed 's/"public_url"\s*:\s*"//')

if [ -z "$NGROK_PUBLIC_URL" ]; then
    echo "ERROR: No HTTPS tunnel found in ngrok response."
    echo "       Response: $(echo "$NGROK_RESPONSE" | head -c 300)"
    exit 1
fi

WEBHOOK_URL="${NGROK_PUBLIC_URL}${WEBHOOK_PATH}"
echo "       ngrok URL: ${NGROK_PUBLIC_URL}"
echo "       Webhook:   ${WEBHOOK_URL}"

# ---- Step 2: Update the webhook on the Evolution API instance ----
echo "[2/3] Updating webhook for instance '${INSTANCE_NAME}' ..."

HTTP_CODE=$(curl -s -o /tmp/evo-webhook-response.json -w "%{http_code}" \
    -X POST \
    "${EVOLUTION_API_URL}/webhook/set/${INSTANCE_NAME}" \
    -H "apikey: ${EVOLUTION_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
        \"enabled\": true,
        \"url\": \"${WEBHOOK_URL}\",
        \"webhook_by_events\": false,
        \"webhook_base64\": false,
        \"events\": [
            \"MESSAGES_UPSERT\",
            \"CONNECTION_UPDATE\",
            \"MESSAGES_UPDATE\"
        ]
    }")

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "       Success (HTTP ${HTTP_CODE})"
else
    echo "       FAILED (HTTP ${HTTP_CODE})"
    echo "       Response: $(cat /tmp/evo-webhook-response.json)"
    exit 1
fi

# ---- Step 3: Verify ----
echo "[3/3] Verifying webhook configuration ..."

curl -sf \
    "${EVOLUTION_API_URL}/webhook/find/${INSTANCE_NAME}" \
    -H "apikey: ${EVOLUTION_API_KEY}" | python3 -m json.tool 2>/dev/null || \
    echo "       (could not pretty-print response — verify manually)"

echo ""
echo "Done! Webhook for '${INSTANCE_NAME}' now points to:"
echo "  ${WEBHOOK_URL}"
echo ""
echo "Send a WhatsApp message to test. Check server logs with:"
echo "  docker logs -f server 2>&1 | grep '\\[EvoAPI\\]'"
