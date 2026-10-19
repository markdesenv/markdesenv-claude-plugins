#!/usr/bin/env bash
# Instala o FreeLLMAPI via Docker Compose, com imagem fixada e porta presa em localhost.
# Não executa nenhum script remoto (substitui o "curl | bash" oficial).
set -euo pipefail

FREELLMAPI_VERSION="${FREELLMAPI_VERSION:-v0.16.5}"
FREELLMAPI_DIR="${FREELLMAPI_DIR:-$HOME/freellmapi}"
FREELLMAPI_PORT="${FREELLMAPI_PORT:-3001}"
IMAGE="ghcr.io/tashfeenahmed/freellmapi:${FREELLMAPI_VERSION}"

die() { echo "ERRO: $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || die "Docker não encontrado. Instale o Docker Desktop/Engine e rode de novo."
docker compose version >/dev/null 2>&1 || die "Plugin 'docker compose' não encontrado."
docker info >/dev/null 2>&1 || die "O daemon do Docker não está rodando."

mkdir -p "$FREELLMAPI_DIR"
chmod 700 "$FREELLMAPI_DIR"
cd "$FREELLMAPI_DIR"

# .env: só cria se não existir, para nunca sobrescrever a chave de criptografia.
if [ ! -f .env ]; then
  if command -v openssl >/dev/null 2>&1; then
    key="$(openssl rand -hex 32)"
  else
    key="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  fi
  umask 077
  cat > .env <<EOF
# Gerado pelo plugin freellmapi. Guarde este arquivo: sem a chave, as chaves
# de provedores salvas no banco ficam ilegíveis.
ENCRYPTION_KEY=${key}
PORT=${FREELLMAPI_PORT}
EOF
  echo "Criado $FREELLMAPI_DIR/.env com uma ENCRYPTION_KEY nova."
else
  echo "Mantendo $FREELLMAPI_DIR/.env existente."
fi

cat > docker-compose.yml <<EOF
# Gerado pelo plugin freellmapi. Versão fixada; altere FREELLMAPI_VERSION e rode o install de novo para atualizar.
services:
  freellmapi:
    image: ${IMAGE}
    env_file:
      - .env
    environment:
      NODE_ENV: production
      PORT: 3001
    ports:
      - "127.0.0.1:${FREELLMAPI_PORT}:3001"
    volumes:
      - freellmapi-data:/app/server/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:3001/api/ping').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      start_period: 15s
      retries: 3
volumes:
  freellmapi-data:
EOF

echo "Baixando $IMAGE ..."
docker compose pull
docker compose up -d

echo -n "Aguardando o serviço responder"
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${FREELLMAPI_PORT}/api/ping" >/dev/null 2>&1; then
    echo
    echo "FreeLLMAPI ${FREELLMAPI_VERSION} no ar em http://127.0.0.1:${FREELLMAPI_PORT}"
    echo "Próximos passos:"
    echo "  1. Abra o painel, crie a conta admin e cadastre as chaves dos provedores."
    echo "  2. Copie a chave unificada (freellmapi-...) na página Keys."
    exit 0
  fi
  echo -n "."
  sleep 2
done
echo
die "O serviço não respondeu em 60s. Veja os logs: cd $FREELLMAPI_DIR && docker compose logs --tail 50"
