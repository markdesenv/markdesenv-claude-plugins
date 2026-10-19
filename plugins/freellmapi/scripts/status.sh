#!/usr/bin/env bash
# Verifica se o FreeLLMAPI está no ar e, se houver chave unificada, lista os modelos.
set -uo pipefail

URL="${FREELLMAPI_URL:-http://127.0.0.1:3001}"
URL="${URL%/}"

if curl -fsS --max-time 5 "$URL/api/ping" >/dev/null 2>&1; then
  echo "OK: gateway respondendo em $URL"
else
  echo "FALHA: nada respondendo em $URL/api/ping"
  echo "Dica: rode /freellmapi:install ou 'docker compose up -d' em ~/freellmapi."
  exit 1
fi

if [ -z "${FREELLMAPI_API_KEY:-}" ]; then
  echo "FREELLMAPI_API_KEY não definida: pulando a checagem de /v1/models."
  exit 0
fi

# A chave vai por arquivo de config temporário, não pela linha de comando, para não aparecer em 'ps'.
cfg="$(mktemp)"
trap 'rm -f "$cfg"' EXIT
chmod 600 "$cfg"
printf 'header = "Authorization: Bearer %s"\n' "$FREELLMAPI_API_KEY" > "$cfg"

body="$(curl -fsS --max-time 15 -K "$cfg" "$URL/v1/models")" || {
  echo "FALHA: /v1/models recusou a chave unificada (confira FREELLMAPI_API_KEY)."
  exit 1
}
count="$(printf '%s' "$body" | grep -o '"id"' | wc -l | tr -d ' ')"
echo "OK: chave unificada válida, $count modelos disponíveis."
