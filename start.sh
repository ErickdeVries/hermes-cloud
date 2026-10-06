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

echo "[start.sh] wrote ${CFG} (provider=${PROVIDER}, model=${MODEL})"
exec hermes gateway run