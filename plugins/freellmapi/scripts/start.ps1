# Inicia o FreeLLMAPI (modo Node) em segundo plano, sem janela, só em 127.0.0.1.
$ErrorActionPreference = 'Stop'

$Root    = if ($env:FREELLMAPI_DIR) { $env:FREELLMAPI_DIR } else { Join-Path $HOME 'freellmapi' }
$App     = Join-Path $Root 'app'
$EnvFile = Join-Path $Root '.env'
$PidFile = Join-Path $Root 'freellmapi.pid'
$Port    = (Select-String -Path $EnvFile -Pattern '^PORT=(\d+)' -ErrorAction SilentlyContinue).Matches.Groups[1].Value
if (-not $Port) { $Port = '3001' }
$Ping    = "http://127.0.0.1:$Port/api/ping"

function Test-Up { try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 $Ping | Out-Null; $true } catch { $false } }

if (-not (Test-Path (Join-Path $App 'server\dist\index.js'))) { throw 'FreeLLMAPI não instalado. Rode install-node.ps1 primeiro.' }
if (Test-Up) { Write-Host "Já está rodando em http://127.0.0.1:$Port"; exit 0 }

$env:NODE_ENV = 'production'
$env:FREEAPI_ENV_PATH = $EnvFile
$logs = Join-Path $Root 'logs'
$p = Start-Process -FilePath (Get-Command node).Source -ArgumentList 'server\dist\index.js' `
  -WorkingDirectory $App -WindowStyle Hidden -PassThru `
  -RedirectStandardOutput (Join-Path $logs 'server.log') -RedirectStandardError (Join-Path $logs 'server.err.log')
$p.Id | Set-Content $PidFile

for ($i = 0; $i -lt 30; $i++) {
  if (Test-Up) { Write-Host "FreeLLMAPI no ar em http://127.0.0.1:$Port (PID $($p.Id))"; exit 0 }
  if ($p.HasExited) { break }
  Start-Sleep -Seconds 1
}
Write-Host '--- últimas linhas do log de erro ---'
Get-Content (Join-Path $logs 'server.err.log') -Tail 20 -ErrorAction SilentlyContinue
throw "O servidor não respondeu em 30s. Logs em $logs"
