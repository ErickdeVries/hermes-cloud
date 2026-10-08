#!/bin/sh
# Bootstrap Hermes gateway config from Helipod Variables.
# Writes /opt/data/config.yaml from env, then hands off to the gateway.
set -e

CFG="${HERMES_HOME:-/opt/data}/config.yaml"

if [ -z "${OPENAI_BASE_URL:-}" ]; then
  echo "[start.sh] ERROR: OPENAI_BASE_URL env is required (set it in Helipod Variables)." >&2
  exit 1
fi
if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "[start.sh] ERROR: OPENAI_API_KEY env is required (set it in Helipod Variables)." >&2
  exit 1
fi

MODEL="${HERMES_MODEL:-bang-jago2}"
PROVIDER="${HERMES_PROVIDER:-9router-combo}"
mkdir -p "$(dirname "$CFG")"

# Optional fallback provider — tried only when the primary fails.
# Set HERMES_FALLBACK_URL + HERMES_FALLBACK_MODEL (+ optional HERMES_FALLBACK_KEY_ENV,
# defaulting to the primary key env) to enable.
FALLBACK_URL="${HERMES_FALLBACK_URL:-}"
FALLBACK_MODEL="${HERMES_FALLBACK_MODEL:-}"
FALLBACK_KEY_ENV="${HERMES_FALLBACK_KEY_ENV:-OPENAI_API_KEY}"

cat > "$CFG" <<EOF
model:
  default: "${MODEL}"
  provider: "${PROVIDER}"
  api_mode: chat_completions
  base_url: "${OPENAI_BASE_URL}"
  key_env: OPENAI_API_KEY
providers:
  ${PROVIDER}:
    name: ${PROVIDER}
    base_url: "${OPENAI_BASE_URL}"
    model: "${MODEL}"
    key_env: OPENAI_API_KEY
EOF

# Append fallback_providers only if fallback URL+model are configured.
if [ -n "${FALLBACK_URL}" ] && [ -n "${FALLBACK_MODEL}" ]; then
  cat >> "$CFG" <<EOF
fallback_providers:
- provider: custom
  model: "${FALLBACK_MODEL}"
  base_url: "${FALLBACK_URL}"
  api_mode: chat_completions
  key_env: ${FALLBACK_KEY_ENV}
EOF
  echo "[start.sh] fallback enabled -> ${FALLBACK_MODEL} @ ${FALLBACK_URL} (key_env=${FALLBACK_KEY_ENV})"
else
  echo "[start.sh] no fallback configured"
fi

echo "[start.sh] wrote ${CFG} (provider=${PROVIDER}, model=${MODEL})"
exec hermes gateway run