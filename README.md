# markdesenv-claude-plugins

Marketplace de plugins do Claude Code mantido por **markdesenv**.

## Plugins

| Plugin | O que faz |
|---|---|
| [`freellmapi`](plugins/freellmapi) | Instala, verifica e usa o [FreeLLMAPI](https://github.com/tashfeenahmed/freellmapi): um gateway local, compatível com OpenAI e Anthropic, que junta os planos gratuitos de vários provedores de LLM com fallback automático. |

## Instalação

No Claude Code:

```
/plugin marketplace add markdesenv/markdesenv-claude-plugins
/plugin install freellmapi@markdesenv-plugins
```

## Plugin `freellmapi`

### Comandos

- `/freellmapi:install [versão] [--docker]` instala ou atualiza o gateway em `~/freellmapi`. No Windows, o padrão é rodar direto no Node (sem Docker e sem admin); no Linux/macOS, usa Docker.
- `/freellmapi:start` e `/freellmapi:stop` iniciam e param o gateway (modo Node). Pare quando não estiver usando para liberar memória.
- `/freellmapi:status` verifica se o gateway responde e, com `FREELLMAPI_API_KEY` definida, se a chave unificada é aceita.

A skill `freellmapi` é ativada sozinha quando você pede para usar LLMs gratuitos, apontar um SDK para o gateway ou rodar o Claude Code através dele.

### Requisitos

- Windows (modo Node): Node >= 20.18 e < 25, e git.
- Modo Docker: Docker Desktop (Windows/macOS) ou Docker Engine com `docker compose` (Linux).
- Para os exemplos de código: Python ou Node com o SDK `openai`.

### Diferenças em relação ao instalador oficial

| | Instalador oficial | Este plugin |
|---|---|---|
| Execução | `curl ... \| bash` (script remoto) | Script versionado neste repositório |
| Imagem | `:latest` | Fixada (`v0.16.5`), atualização explícita |
| Rede | `127.0.0.1` por padrão | Sempre `127.0.0.1` |
| `.env` | Gerado | Gerado uma vez, com permissão só do dono, nunca sobrescrito |

### Uso rápido

```bash
export FREELLMAPI_API_KEY=freellmapi-...   # chave unificada da página Keys
```

```python
from openai import OpenAI
import os
client = OpenAI(base_url="http://127.0.0.1:3001/v1", api_key=os.environ["FREELLMAPI_API_KEY"])
print(client.chat.completions.create(model="auto", messages=[{"role": "user", "content": "Olá"}]).choices[0].message.content)
```

Claude Code pelo gateway, sem gravar credenciais em disco:

```bash
npx -y freellmapi@0.8.1 launch
```

### Cuidados

- Não gera cota extra: só soma o que cada plano gratuito já oferece.
- Alguns planos gratuitos podem usar prompts para treino. Não envie dados sensíveis.
- Faça backup de `~/freellmapi/.env`. Sem a `ENCRYPTION_KEY`, as chaves salvas ficam ilegíveis.
- O gateway é single-user. Não o exponha na internet.

## Créditos

O FreeLLMAPI é de [Tashfeen Ahmed](https://github.com/tashfeenahmed/freellmapi), sob licença MIT. Este repositório não inclui código dele; o plugin apenas instala a imagem oficial e documenta o uso.

## Licença

MIT
