---
description: Para o FreeLLMAPI para liberar memória
allowed-tools: Bash
---

- Windows (modo Node): `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/stop.ps1"`
- Modo Docker: `docker compose down` dentro de `~/freellmapi` (os dados ficam no volume).

Responda em uma linha.
