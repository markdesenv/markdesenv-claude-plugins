---
description: Instala ou atualiza o FreeLLMAPI localmente via Docker (versão fixada, só em localhost)
argument-hint: "[versão, ex.: v0.16.5]"
allowed-tools: Bash
---

Instale o FreeLLMAPI nesta máquina usando o script do plugin. Não use o instalador oficial `curl ... | bash`.

1. Se `$ARGUMENTS` trouxer uma versão (ex.: `v0.16.5`), exporte `FREELLMAPI_VERSION` com ela antes de rodar.
2. Detecte o sistema:
   - Linux/macOS/WSL/Git Bash: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh"`
   - Windows PowerShell: `powershell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install.ps1"`
3. Se o Docker faltar ou não estiver rodando, pare e diga ao usuário o que instalar ou abrir. Não tente instalar o Docker sozinho.
4. Ao terminar, mostre a URL do painel e os próximos passos: criar a conta admin, cadastrar as chaves dos provedores e copiar a chave unificada `freellmapi-...`.

Nunca mostre, copie nem registre o conteúdo do `.env` (ele guarda a `ENCRYPTION_KEY`).
