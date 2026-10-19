---
name: freellmapi
description: Use quando o usuário quiser chamar LLMs de graça, configurar o FreeLLMAPI, apontar código (SDK OpenAI/Anthropic) ou o Claude Code para o gateway local, ou resolver problemas de rate limit/fallback entre provedores gratuitos.
---

# FreeLLMAPI

Gateway self-hosted (MIT, github.com/tashfeenahmed/freellmapi) que junta os planos gratuitos de vários provedores (Groq, Gemini, Mistral, OpenRouter, Cerebras, NVIDIA etc.) atrás de um único endpoint. Ele escolhe o modelo, faz fallback quando um provedor bate o limite e guarda as chaves criptografadas (AES-256-GCM em SQLite).

## Fatos operacionais

- URL local padrão: `http://127.0.0.1:3001`. Painel no mesmo endereço.
- Health check: `GET /api/ping`.
- Endpoints de inferência: `/v1/chat/completions` (OpenAI), `/v1/messages` (Anthropic), `/v1/models`.
- Autenticação dos clientes: chave unificada `freellmapi-...`, exibida na página **Keys** do painel. Não é a chave de nenhum provedor.
- Modelo `auto` deixa o roteador escolher; também existem cadeias nomeadas como `auto:coding`.
- Instalação: comando `/freellmapi:install`. Verificação: `/freellmapi:status`.

## Usar a partir de código

Python (SDK OpenAI):

```python
import os
from openai import OpenAI

client = OpenAI(base_url="http://127.0.0.1:3001/v1", api_key=os.environ["FREELLMAPI_API_KEY"])
resp = client.chat.completions.create(model="auto", messages=[{"role": "user", "content": "Olá"}])
print(resp.choices[0].message.content)
```

Node (SDK OpenAI):

```js
import OpenAI from "openai";
const client = new OpenAI({ baseURL: "http://127.0.0.1:3001/v1", apiKey: process.env.FREELLMAPI_API_KEY });
```

Sempre leia a chave de variável de ambiente. Nunca a escreva no código nem em arquivos versionados.

## Usar com o Claude Code

Prefira o launcher, que injeta as credenciais só no processo filho e não grava nada em disco:

```bash
FREELLMAPI_API_KEY=freellmapi-... npx -y freellmapi@0.8.1 launch
```

Alternativa persistente (grava config, com backup do arquivo anterior): `npx -y freellmapi@0.8.1 setup-claude --url http://127.0.0.1:3001 --api-key <chave>`. Use `--dry-run` antes para mostrar o que mudaria.

Fixe a versão da CLI (`freellmapi@0.8.1`) em vez de `npx freellmapi` solto.

## Limites que precisam ser ditos ao usuário

- Não cria cota extra: soma só o que cada plano gratuito já dá. Modelos gratuitos variam em qualidade e disponibilidade.
- Planos gratuitos de alguns provedores podem usar os prompts para treino. Não mande dados sensíveis de clientes ou da empresa por ele.
- É single-user. Mantenha a porta em `127.0.0.1`. Só exponha na rede (`HOST_BIND=0.0.0.0`) em rede confiável e nunca na internet.
- Perder a `ENCRYPTION_KEY` (no `.env` em `~/freellmapi`) torna as chaves salvas ilegíveis. Oriente a guardar uma cópia segura.

## Problemas comuns

- `/api/ping` não responde: `cd ~/freellmapi && docker compose ps` e `docker compose logs --tail 50`.
- 401 em `/v1/*`: a chave usada não é a unificada, ou foi regenerada no painel.
- 429/503 frequentes: todos os provedores da cadeia bateram limite. Cadastre mais chaves ou espere o reset diário.
- Atualizar: `/freellmapi:install v0.X.Y` com a nova versão. O `.env` e o volume de dados são mantidos.
