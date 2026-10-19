---
description: Verifica se o FreeLLMAPI está no ar e se a chave unificada funciona
allowed-tools: Bash
---

Rode `bash "${CLAUDE_PLUGIN_ROOT}/scripts/status.sh"`.

O script lê `FREELLMAPI_URL` (padrão `http://127.0.0.1:3001`) e, se existir, `FREELLMAPI_API_KEY`. Não peça a chave ao usuário no chat e não a escreva em arquivos; se ela não estiver no ambiente, informe só o resultado do ping.

Resuma o resultado em uma ou duas linhas. Em caso de falha, sugira `/freellmapi:install` ou ver os logs com `docker compose logs --tail 50` em `~/freellmapi`.
