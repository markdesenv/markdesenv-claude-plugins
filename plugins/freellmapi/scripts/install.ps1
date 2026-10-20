# Instala o FreeLLMAPI via Docker Compose no Windows, com imagem fixada e porta presa em localhost.
# Não executa nenhum script remoto (substitui o "curl | bash" oficial).
$ErrorActionPreference = 'Stop'

$Version = if ($env:FREELLMAPI_VERSION) { $env:FREELLMAPI_VERSION } else { 'v0.16.5' }
$Dir     = if ($env:FREELLMAPI_DIR)     { $env:FREELLMAPI_DIR }     else { Join-Path $HOME 'freellmapi' }
$Port    = if ($env:FREELLMAPI_PORT)    { $env:FREELLMAPI_PORT }    else { '3001' }
$Image   = "ghcr.io/tashfeenahmed/freellmapi:$Version"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker não encontrado. Instale o Docker Desktop e rode de novo.' }
docker compose version *> $null; if ($LASTEXITCODE -ne 0) { throw "Plugin 'docker compose' não encontrado." }
docker info *> $null;            if ($LASTEXITCODE -ne 0) { throw 'O Docker Desktop não está rodando.' }

New-Item -ItemType Directory -Force -Path $Dir | Out-Null
Set-Location $Dir

if (-not (Test-Path .env)) {
  $bytes = New-Object byte[] 32
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  $key = -join ($bytes | ForEach-Object { $_.ToString('x2') })
  @"
# Gerado pelo plugin freellmapi. Guarde este arquivo: sem a chave, as chaves
# de provedores salvas no banco ficam ilegíveis.
ENCRYPTION_KEY=$key
PORT=$Port
"@ | Set-Content -Encoding ascii .env
  # Restringe o .env ao usuário atual.
  icacls .env /inheritance:r /grant:r "$($env:USERNAME):(R,W)" | Out-Null
  Write-Host "Criado $Dir\.env com uma ENCRYPTION_KEY nova."
} else {
  Write-Host "Mantendo $Dir\.env existente."
}

@"
# Gerado pelo plugin freellmapi. Versão fixada; altere FREELLMAPI_VERSION e rode o install de novo para atualizar.
services:
  freellmapi:
    image: $Image
    env_file:
      - .env
    environment:
      NODE_ENV: production
      PORT: 3001
    ports:
      - "127.0.0.1:${Port}:3001"
    volumes:
      - freellmapi-data:/app/server/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped
volumes:
  freellmapi-data:
"@ | Set-Content -Encoding ascii docker-compose.yml

Write-Host "Baixando $Image ..."
docker compose pull; if ($LASTEXITCODE -ne 0) { throw 'Falha no docker compose pull.' }
docker compose up -d; if ($LASTEXITCODE -ne 0) { throw 'Falha no docker compose up.' }

for ($i = 0; $i -lt 30; $i++) {
  try {
    Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 "http://127.0.0.1:$Port/api/ping" | Out-Null
    Write-Host "FreeLLMAPI $Version no ar em http://127.0.0.1:$Port"
    Write-Host 'Próximos passos:'
    Write-Host '  1. Abra o painel, crie a conta admin e cadastre as chaves dos provedores.'
    Write-Host '  2. Copie a chave unificada (freellmapi-...) na página Keys.'
    exit 0
  } catch { Start-Sleep -Seconds 2 }
}
throw "O serviço não respondeu em 60s. Veja os logs: cd $Dir; docker compose logs --tail 50"
