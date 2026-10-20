# Para o FreeLLMAPI iniciado pelo start.ps1.
$Root    = if ($env:FREELLMAPI_DIR) { $env:FREELLMAPI_DIR } else { Join-Path $HOME 'freellmapi' }
$PidFile = Join-Path $Root 'freellmapi.pid'

if (-not (Test-Path $PidFile)) { Write-Host 'Nenhum PID salvo: nada para parar.'; exit 0 }
$procId = [int](Get-Content $PidFile)
$p = Get-Process -Id $procId -ErrorAction SilentlyContinue
# O PID salvo é do cmd que hospeda o node. Só encerra se ainda for esse cmd
# (evita matar outro processo que reaproveitou o PID) e derruba a árvore inteira.
$cim = Get-CimInstance Win32_Process -Filter "ProcessId=$procId" -ErrorAction SilentlyContinue
if ($p -and $cim -and $cim.CommandLine -match 'server\\dist\\index\.js') {
  taskkill /PID $procId /T /F | Out-Null
  Write-Host "FreeLLMAPI parado (PID $procId)."
} else {
  Write-Host 'O processo salvo não está mais rodando.'
}
Remove-Item $PidFile -ErrorAction SilentlyContinue
