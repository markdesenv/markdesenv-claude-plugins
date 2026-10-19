---
description: Instala ou atualiza o FreeLLMAPI localmente (Node no Windows, Docker no Linux/macOS)
argument-hint: "[versão, ex.: v0.16.5] [--docker]"
allowed-tools: Bash
---

Instale o FreeLLMAPI nesta máquina usando os scripts do plugin. Não use o instalador oficial `curl ... | bash`.

1. Se `$ARGUMENTS` trouxer uma versão (ex.: `v0.16.5`), exporte `FREELLMAPI_VERSION` com ela antes de rodar.
2. Escolha o modo:
   - **Windows (padrão: Node, sem Docker e sem admin):** `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-node.ps1"` e depois `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/start.ps1"`. Requer Node >= 20.18 e < 25, além de git.
   - **Windows com `--docker`:** `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install.ps1"`.
   - **Linux/macOS:** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh"` (Docker).
3. Se faltar Node, git ou Docker, pare e diga ao usuário o que instalar. Não instale essas ferramentas sem pedir.
4. Ao terminar, mostre a URL do painel e os próximos passos: criar a conta admin, cadastrar as chaves dos provedores e copiar a chave unificada `freellmapi-...`.

Nunca mostre, copie nem registre o conteúdo do `.env` (ele guarda a `ENCRYPTION_KEY`).
