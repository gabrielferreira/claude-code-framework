---
name: backlog-update
description: Atualiza o backlog — adiciona, conclui ou edita itens seguindo o padrão do projeto
user_invocable: true
---
<!-- framework-tag: v2.24.0 framework-file: skills/backlog-update/SKILL.md -->

# /backlog-update — Atualizar backlog

Atualiza o backlog do projeto seguindo o padrão de classificações e regras definidos no CLAUDE.md.

## Uso

```
/backlog-update {ID} {ação}
```

Ações disponíveis:
- `add` — Adicionar novo item pendente
- `done` — Marcar como concluído (mover de Pendentes -> Concluídos)
- `update` — Editar campos de um item existente

Exemplos:
- `/backlog-update FEAT2 add`
- `/backlog-update SEC7 done`
- `/backlog-update T1 update`

## Instruções

### Passo 0 — Detectar modo (repo ou Notion)

Verificar se o `CLAUDE.md` do projeto contém a seção `## Integracao Notion (specs)`.
- **Se sim:** modo Notion — ler e atualizar specs direto no Notion via MCP
- **Se não:** modo repo — usar backlog.md local

---

### Modo Repo (backlog local)

**Passo 0 — Bootstrap check:** Se `.claude/specs/backlog.md` não existe, criar com estrutura padrão:
```markdown
# Backlog — {NOME_DO_PROJETO}

> Última atualização: {data de hoje}

## Pendentes

| ID | Fase | Item | Sev. | Impacto | Tipo | Camadas | Compl. | Est. | Deps | Origem | Spec |
|---|---|---|---|---|---|---|---|---|---|---|---|

## Concluídos

| ID | Item | Concluído em |
|---|---|---|

## Decisões futuras

| ID | Decisão | Gatilho para reavaliar | Recomendação | Ref |
|---|---|---|---|---|

## Notas

{Nenhuma nota por enquanto.}
```

#### Ação: `add`

1. Verificar se o ID já existe no backlog — se sim, avisar e perguntar
2. Perguntar ao usuário (usando AskUserQuestion quando possível):
   - **Item:** descrição curta (1 frase, máx 2 linhas)
   - **Fase:** F1 | F2 | F3 | T
   - **Severidade:** 🔴 Crítico | 🟠 Alto | 🟡 Médio | ⚪ Baixo
   - **Impacto:** 👤 Usuário | 🛡️ Segurança | 💰 Negócio | 🔧 Interno
   - **Tipo:** Feature | Bug | Segurança | Regra de Negócio | Refatoração | Testes | Docs | Análise | Infra
   - **Camadas:** `FE` `BE` `DB` `IA` `DOC` `INF` (múltiplas)
   - **Complexidade:** 🟢 Baixa | 🟡 Média | 🔴 Alta
   - **Estimativa:** 15min | 30min | 1h | 2h | 4h | 1d | 2d | 1sem
   - **Dependências:** IDs ou `—`
   - **Origem:** Sessão | Backlog | Auditoria | Incidente | Feedback | PRD | Externo (default: `Sessão`)
   - **Spec:** nome do arquivo se existir, ou `—`
3. Ler `.claude/specs/backlog.md`
4. Inserir nova linha na seção da fase correta, ordenado por severidade (🔴 > 🟠 > 🟡 > ⚪)
5. Atualizar `Última atualização` no header

#### Ação: `done`

1. Ler `.claude/specs/backlog.md`
2. Encontrar o item com o ID informado na tabela Pendentes
3. Se não encontrar, avisar e abortar
4. Remover a linha da tabela Pendentes
5. Adicionar na tabela Concluídos (topo, mais recente primeiro):
   ```
   | {ID} | {descrição resumida} | {data de hoje YYYY-MM-DD} |
   ```
6. Se existir spec associada:
   - Se `.claude/specs/done/` não existe, criar antes de mover
   - Mover arquivo de `.claude/specs/` para `.claude/specs/done/`
   - Atualizar status da spec para `concluída`
   - Atualizar path no `SPECS_INDEX.md`
7. Atualizar `Última atualização`
8. Se `STATE.md` existir (`.claude/specs/STATE.md`):
   - Remover blockers (B-NNN) relacionados ao item concluído
   - Verificar se alguma "Ideia adiada" pode ser promovida a item no backlog
   - Sugerir registrar lição aprendida (L-NNN) se houve algo não óbvio durante a implementação
   - Se existir design doc associado (`.claude/specs/{id}-design.md`): atualizar status para `implementado`
   - Se o projeto usa PRDs (sinal: existe `.claude/prds/PRDS_INDEX.md`) e a spec tiver `> PRD pai: {ID}` no header: verificar no `PRDS_INDEX.md` se todas as specs vinculadas ao PRD estão concluídas. Se sim, sugerir marcar o PRD como `concluido` e mover para `.claude/prds/done/`. Se o projeto nao usa PRDs, pular esta verificacao

#### Ação: `update`

1. Ler `.claude/specs/backlog.md`
2. Encontrar o item com o ID informado
3. Perguntar quais campos alterar
4. Aplicar mantendo ordem por severidade
5. Atualizar `Última atualização`

#### Após qualquer ação (add, done, update)

Se existir `scripts/backlog-report.cjs`, regenerar o relatório HTML:
```bash
node scripts/backlog-report.cjs
```

---

### Modo Notion (specs externas via MCP)

Quando a seção `## Integracao Notion (specs)` existe no CLAUDE.md, o backlog é a própria database do Notion.

**Ler configuração do CLAUDE.md:**
- `data_source_id` — ID da collection no Notion

#### Ação: `add`

1. Perguntar ao usuário:
   - Título, Fase, Severidade, Impacto, Tipo, Camadas, Complexidade, Estimativa
   - Nota: Dependências, Origem e Spec não se aplicam no Notion — esses campos são gerenciados via properties da database
2. **Criar página no Notion** usando `notion-create-pages`:
   ```
   parent: { data_source_id: "{data_source_id}" }
   pages: [{
     properties: {
       "Título": "{título}",
       "Status": "rascunho",
       "Fase": "{fase}",
       "Severidade": "{severidade}",
       "Impacto": "{impacto}",
       "Tipo": "{tipo}",
       "Camadas": "{camadas}",
       "Complexidade": "{complexidade}",
       "Estimativa": "{estimativa}",
       "Projeto": "{nome do projeto}",
       "Spec detail": "sem spec"
     }
   }]
   ```
   Nota: **não usar template** no `add` do backlog — templates são usados apenas pelo `/spec` quando a spec vai ser detalhada.
3. Informar URL da página criada

#### Ação: `done`

1. **Buscar a spec no Notion** — usar `notion-search` ou buscar por título/ID na database
2. **Resolver identidade do responsável** — chamar `notion-get-users` com `user_id: "self"` para obter o usuário da sessão atual
3. **Atualizar propriedades** via `notion-update-page`:
   ```
   command: "update_properties"
   properties: {
     "Status": "concluída",
     "date:Concluída em:start": "{data de hoje YYYY-MM-DD}",
     "date:Concluída em:is_datetime": 0,
     "Responsavel": "{user_id obtido no passo 2}"
   }
   ```
4. Se existir SPECS_INDEX.md local, atualizar status lá também

#### Ação: `update`

1. **Buscar a spec no Notion** — por título ou ID
2. Perguntar quais campos alterar
3. **Atualizar propriedades** via `notion-update-page` com os campos informados

#### Após qualquer ação

Se existir `scripts/backlog-report.cjs`, regenerar o relatório HTML local.

---

## Regras

- **Nunca** riscar itens — sempre mover de Pendentes para Concluídos (repo) ou atualizar Status (Notion)
- **Nunca** deixar item em Pendentes e Concluídos ao mesmo tempo
- Seguir classificações do CLAUDE.md seção "Classificações do backlog"
- **Modo repo:** ao concluir item com spec, sempre mover a spec e atualizar SPECS_INDEX
- **Modo Notion:** ao concluir (`done`), atualizar Status, Concluída em **e Responsavel** (via `notion-get-users self`) direto na página do Notion
- **Sempre** regenerar `docs/backlog-report.html` ao final (se script existir)
