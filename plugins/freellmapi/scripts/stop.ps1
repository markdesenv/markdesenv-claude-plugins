# Para o FreeLLMAPI iniciado pelo start.ps1.
$Root    = if ($env:FREELLMAPI_DIR) { $env:FREELLMAPI_DIR } else { Join-Path $HOME 'freellmapi' }
$PidFile = Join-Path $Root 'freellmapi.pid'

if (-not (Test-Path $PidFile)) { Write-Host 'Nenhum PID salvo: nada para parar.'; exit 0 }
$procId = [int](Get-Content $PidFile)
$p = Get-Process -Id $procId -ErrorAction SilentlyContinue
# Só encerra se o PID ainda for um processo node (evita matar outro processo que reaproveitou o PID).
if ($p -and $p.ProcessName -eq 'node') {
  Stop-Process -Id $procId -Force
  Write-Host "FreeLLMAPI parado (PID $procId)."
} else {
  Write-Host 'O processo salvo não está mais rodando.'
}
Remove-Item $PidFile -ErrorAction SilentlyContinue
