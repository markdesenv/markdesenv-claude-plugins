---
description: Inicia o FreeLLMAPI em segundo plano (modo Node no Windows)
allowed-tools: Bash
---

- Windows (modo Node): `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/start.ps1"`
- Modo Docker: `docker compose up -d` dentro de `~/freellmapi`.

Responda em uma linha com a URL ou com o erro. Se falhar, mostre as últimas linhas de `~/freellmapi/logs/server.err.log`.
