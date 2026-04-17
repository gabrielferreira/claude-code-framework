---
name: onboarding
description: Guia contextualizado do fluxo de trabalho para devs novos no projeto
user_invocable: true
---
<!-- framework-tag: v2.49.3 framework-file: skills/onboarding/SKILL.md -->

# /onboarding — Guia de como trabalhar neste projeto

Gera um guia contextualizado explicando o fluxo de trabalho, comandos, skills e convenções **deste projeto específico**. Lê os artefatos reais do projeto e monta o guia com informações concretas — sem placeholders genéricos.

## Quando usar

- Dev novo entrando no projeto
- Retomando projeto após longa ausência
- Quer entender o fluxo completo de trabalho com o framework
- Precisa explicar para outro dev como funciona

## Quando NÃO usar

- Quer mapear a arquitetura do código → usar `/map-codebase`
- Quer entender uma feature específica → ler specs em `.claude/specs/`
- Quer configurar o framework → usar `/setup-framework`

## Fluxo

### Passo 1 — Coletar contexto do projeto

Ler os seguintes artefatos (na ordem):

1. **`CLAUDE.md`** — extrair:
   - `## O que é este projeto` → nome, descrição, stack
   - `## Comandos` → comandos de dev, test, lint, build
   - `## Skills — ler ANTES de codificar` → skills instaladas e quando usar
   - `## Agents — executar sob demanda` → agents disponíveis
   - `## Testes e coverage` → política de testes
   - `## Padrões` → convenções de código
   - `## Estrutura` → layout do projeto
   - `## Monorepo` (se existir) → sub-projetos, distribuição, camadas
   - `## Integração Notion (specs)` (se existir) → modo Notion ativo

2. **`PROJECT_CONTEXT.md`** (se existir) — extrair:
   - `## Restrições inegociáveis` → o que nunca mudar
   - `## Stack técnica` → tabela de tecnologias
   - `## Decisões arquiteturais já tomadas` → decisões fixas

3. **`.claude/SETUP_REPORT.md`** (se existir) — extrair:
   - Skills instaladas com tipo (Core/Recomendada)
   - Agents instalados com modelo atribuído
   - Configurações: threshold de coverage, modelo de specs

4. **`docs/SKILLS_MAP.md`** (se existir) — extrair:
   - Pipeline de orquestração (ordem das skills)
   - Dependências entre skills

5. **Listar `.claude/skills/`** — confirmar quais skills estão realmente instaladas no projeto

6. **Listar `.claude/agents/`** — confirmar quais agents estão realmente instalados

### Passo 2 — Gerar o guia

Montar o output em markdown no chat seguindo esta estrutura. **Usar dados reais extraídos no Passo 1 — nunca placeholders.**

```markdown
# Como trabalhar neste projeto

## Sobre o projeto

{Nome e descrição do CLAUDE.md}
- **Stack:** {stack real — ex: Node.js, TypeScript, PostgreSQL, React}
- **Domínio:** {domínio do PROJECT_CONTEXT — ex: fintech, e-commerce, SaaS}

## Comandos do dia a dia

| Comando | O que faz |
|---|---|
| `{comando dev}` | Servidor de desenvolvimento |
| `{comando test}` | Rodar testes |
| `{comando lint}` | Lint e formatação |
| `{comando build}` | Build de produção |

## Fluxo de trabalho

### 1. Início de sessão

O Claude lê o CLAUDE.md automaticamente ao iniciar. Para retomar trabalho:
- Ler `.claude/specs/STATE.md` para ver o que estava em andamento
- Se tem item ativo, continuar de onde parou

### 2. Criar trabalho novo

**Escolher o caminho certo:**

{Incluir APENAS os caminhos disponíveis (skills instaladas):}

| Situação | Comando | O que acontece |
|---|---|---|
| Fix trivial (typo, config, ≤3 arquivos) | `/quick` | Implementa direto sem spec |
| Escopo vago, domínio novo, gray areas | `/discuss` | Scout + decisões + spec gerada |
| Tarefa clara, escopo definido | `/spec` | Cria spec estruturada |

{Se usa Notion:}
> Specs são criadas na database do Notion via MCP. O `/spec` detecta automaticamente.

{Se repo mode:}
> Specs ficam em `.claude/specs/` e são rastreadas no `SPECS_INDEX.md`.

### 3. Implementar

Pipeline recomendado (ajustar conforme tamanho):

{Extrair do SKILLS_MAP — listar só skills instaladas. Exemplo:}

`spec-driven → research (se Grande) → execution-plan → {skills de domínio} → testing → definition-of-done → pr`

**Skills de domínio disponíveis neste projeto:**

| Skill | Quando usar |
|---|---|
| {skill real} | {descrição real do CLAUDE.md} |

### 4. Finalizar

1. Rodar testes: `{comando de test real}`
2. Verificação: `bash scripts/verify.sh`
3. Abrir PR: `/pr` {ou processo manual se /pr não instalado}
4. Fechar no backlog: `/backlog-update done {id}`

## Skills instaladas

| Skill | Tipo | Quando usar |
|---|---|---|
| {skill} | {Core/Recomendada/Domínio} | {quando usar — do CLAUDE.md} |

## Agents disponíveis

| Agent | Modelo | Quando usar |
|---|---|---|
| {agent} | {opus/sonnet/haiku} | {quando usar — do CLAUDE.md} |

## Restrições importantes

{Extrair de ## Restrições inegociáveis do PROJECT_CONTEXT.md}

- {restrição 1}
- {restrição 2}

{Se não existir PROJECT_CONTEXT.md, omitir esta seção}

## Monorepo

{Incluir SOMENTE se ## Monorepo existe no CLAUDE.md}

Sub-projetos deste monorepo:

| Sub-projeto | Path | Stack |
|---|---|---|
| {sub-projeto} | {path} | {stack} |

**Como navegar:** cada sub-projeto tem seu CLAUDE.md L2 com regras específicas. Skills/agents podem estar na raiz (L0) ou por sub-projeto (L2).

## Referências

- `CLAUDE.md` — regras completas do projeto
- `PROJECT_CONTEXT.md` — contexto de negócio e restrições
- `docs/SPEC_DRIVEN_GUIDE.md` — guia detalhado do workflow de specs
- `docs/SKILLS_MAP.md` — dependências entre skills
- `.claude/specs/STATE.md` — estado atual do trabalho
```

## Checklist

- [ ] CLAUDE.md lido e dados extraídos
- [ ] PROJECT_CONTEXT.md lido (se existir)
- [ ] SETUP_REPORT.md lido (se existir)
- [ ] Skills e agents listados são os realmente instalados (verificado via `.claude/skills/` e `.claude/agents/`)
- [ ] Comandos são os reais do projeto (não placeholders)
- [ ] Output gerado no chat (não criou arquivo)
- [ ] Se monorepo, seção de sub-projetos incluída
- [ ] Se Notion mode, mencionado no fluxo

## Regras

1. **Output no chat, não em arquivo.** O guia é gerado e mostrado — não criar `.md` no projeto.
2. **Dados reais, nunca placeholders.** Se um campo não tem informação, omitir a linha — não usar `{adaptar}`.
3. **Só listar o que está instalado.** Verificar `.claude/skills/` e `.claude/agents/` antes de incluir na tabela.
4. **Linguagem para humanos.** Público é dev novo no projeto, não o Claude. Ser direto e prático.
5. **Não duplicar docs existentes.** Linkar para SPEC_DRIVEN_GUIDE, SKILLS_MAP, etc. em vez de copiar conteúdo.
6. **Seções condicionais.** Omitir seções inteiras se não se aplicam (Monorepo, Notion, Restrições).
