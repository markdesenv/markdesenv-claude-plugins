# Instala o FreeLLMAPI a partir do código-fonte, rodando direto no Node (sem Docker, sem admin).
# Layout em $HOME\freellmapi:  app\ (código, versão fixada)  data\ (banco)  logs\  .env
$ErrorActionPreference = 'Stop'

$Version = if ($env:FREELLMAPI_VERSION) { $env:FREELLMAPI_VERSION } else { 'v0.16.5' }
$Root    = if ($env:FREELLMAPI_DIR)     { $env:FREELLMAPI_DIR }     else { Join-Path $HOME 'freellmapi' }
$Port    = if ($env:FREELLMAPI_PORT)    { $env:FREELLMAPI_PORT }    else { '3001' }
$Repo    = 'https://github.com/tashfeenahmed/freellmapi.git'
$App     = Join-Path $Root 'app'

foreach ($c in 'node', 'npm', 'git') {
  if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { throw "'$c' não encontrado no PATH." }
}
$nodeVer = [Version]((node -v).Trim().TrimStart('v'))
if ($nodeVer -lt [Version]'20.18.0' -or $nodeVer.Major -ge 25) {
  throw "Node $nodeVer não suportado. O FreeLLMAPI pede >= 20.18 e < 25."
}

# Para o servidor antes de atualizar o código.
$stop = Join-Path $PSScriptRoot 'stop.ps1'
if (Test-Path (Join-Path $Root 'freellmapi.pid')) { & $stop | Out-Null }

New-Item -ItemType Directory -Force -Path $Root, (Join-Path $Root 'data'), (Join-Path $Root 'logs') | Out-Null

if (Test-Path (Join-Path $App '.git')) {
  Write-Host "Atualizando código para $Version ..."
  git -C $App fetch --depth 1 origin "refs/tags/${Version}:refs/tags/${Version}"
  if ($LASTEXITCODE -ne 0) { throw "Falha ao buscar a tag $Version." }
  git -C $App checkout -q --force $Version
} else {
  Write-Host "Baixando FreeLLMAPI $Version ..."
  git clone -q --depth 1 --branch $Version $Repo $App
}
if ($LASTEXITCODE -ne 0) { throw 'Falha no git.' }

# npm.cmd evita o bloqueio de política de execução sobre npm.ps1.
$npm = if (Get-Command npm.cmd -ErrorAction SilentlyContinue) { 'npm.cmd' } else { 'npm' }
Push-Location $App
try {
  Write-Host 'Instalando dependências (npm ci) ...'
  & $npm ci --no-audit --no-fund --loglevel=error
  if ($LASTEXITCODE -ne 0) { throw 'Falha no npm ci.' }
  Write-Host 'Compilando (npm run build) ...'
  & $npm run build --silent
  if ($LASTEXITCODE -ne 0) { throw 'Falha no npm run build.' }
} finally { Pop-Location }

$envFile = Join-Path $Root '.env'
if (-not (Test-Path $envFile)) {
  $bytes = New-Object byte[] 32
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  $key = -join ($bytes | ForEach-Object { $_.ToString('x2') })
  $db = (Join-Path $Root 'data\freellmapi.db') -replace '\\', '/'
  @"
# Gerado pelo plugin freellmapi. Guarde uma cópia: sem a ENCRYPTION_KEY,
# as chaves de provedores salvas no banco ficam ilegíveis.
ENCRYPTION_KEY=$key
PORT=$Port
HOST=127.0.0.1
FREEAPI_DB_PATH=$db
"@ | Set-Content -Encoding ascii $envFile
  icacls $envFile /inheritance:r /grant:r "$($env:USERNAME):(R,W)" | Out-Null
  Write-Host "Criado $envFile com uma ENCRYPTION_KEY nova."
} else {
  Write-Host "Mantendo $envFile existente."
}

Write-Host "Instalação concluída ($Version). Inicie com o script start.ps1."
