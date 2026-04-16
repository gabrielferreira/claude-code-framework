---
name: upgrade-framework
description: Converte projeto de modo light para modo full do claude-code-framework
user_invocable: true
---
<!-- framework-tag: v2.47.1 framework-file: skills/upgrade-framework/SKILL.md -->

# /upgrade-framework — Upgrade light → full

Converte um projeto em modo light para modo full, instalando arquivos faltantes aditivamente e enriquecendo artefatos existentes. Preserva todas as customizacoes.

## Quando usar

- Projeto cresceu e precisa de mais skills, agents ou docs
- Time aumentou e precisa de cobertura completa (PRDs, orchestration, reports)
- Quer habilitar features full (monorepo, Notion, sub-agents)

## Quando NAO usar

- Projeto ja esta em modo full → usar `/update-framework`
- Quer apenas instalar um agent/skill especifico → copiar manualmente do framework source
- Projeto nao tem framework instalado → usar `/setup-framework`

## Uso

```
/upgrade-framework
```

Executar na raiz do repositorio.

---

## Fase 0 — Validacao

1. **Verificar framework instalado:** `.claude/` deve existir. Se nao: "Framework nao encontrado. Use `/setup-framework` primeiro."
2. **Detectar modo atual:**
   - Ler `> Modo:` em `.claude/SETUP_REPORT.md`
   - Fallback: grep `<!-- framework-mode:` em `CLAUDE.md`
   - Fallback: heuristica (< 50% dos arquivos full existem → assume light)
3. **Se ja full:** "Projeto ja esta em modo full. Use `/update-framework` para atualizar."
4. **Comparar versao:** ler `framework-tag` dos arquivos instalados vs VERSION do framework source. Se versao instalada < source → recomendar `/update-framework` primeiro para atualizar os arquivos core antes de instalar os full.
5. **Localizar framework source:** mesma logica do setup (templates embutidos ou path do clone).

## Fase 1 — Inventario

1. Ler `MANIFEST.md` do framework source com coluna Tier.
2. Para cada arquivo tier=`full`: verificar se ja existe no projeto.
3. Apresentar resumo:

```
Inventario do upgrade light → full:

  Ja instalados (core):           {N} arquivos
  Ja instalados manualmente (full): {M} arquivos
  Disponiveis para instalar:      {K} arquivos

  Novos agents:     {lista}
  Novas skills:     {lista}
  Novos docs:       {lista}
  Novos scripts:    {lista}
  Novos templates:  {lista}

Continuar com o upgrade? [Sim/Nao]
```

## Fase 2 — Perguntas adicionais

Perguntar apenas o que e necessario para features full que nao existiam no light:

1. **PRD opt-in?** "Quer habilitar o sistema de PRDs (Product Requirements Documents)? Util para features grandes com multiplas specs." [Sim/Nao]
2. **Monorepo?** "O projeto e um monorepo com sub-projetos? (Se sim, configurar suporte a L0/L2/L3+)" [Sim/Nao]
   - Se sim: rodar deteccao de sub-projetos (mesma logica da Fase 0 passo 6 do setup)
3. **Delta markers?** "Quer habilitar marcadores delta ([ADDED]/[MODIFIED]/[REMOVED]) nas specs? Util para specs que alteram codigo existente (brownfield)." [Sim/Nao]
4. **Sub-agent orchestration?** "Quer habilitar orchestracao de sub-agents (context-fresh, task-runner, execution-plan)? Util para items Medios+ com decomposicao em tasks." [Sim/Nao]
5. **Skills condicionais** nao detectadas no setup original? (dba-review, ux-review, seo-performance)

## Fase 3 — Instalacao

Para cada arquivo tier=`full` que nao existe no projeto:

1. **Copiar respeitando estrategia do MANIFEST:**
   - `structural` → copiar template, manter `{Adaptar:}` placeholders para o usuario preencher
   - `overwrite` → copiar direto
   - `manual` → mostrar diff, perguntar
   - `skip` → criar com template vazio (backlog-format, DESIGN_TEMPLATE)

2. **Enriquecer CLAUDE.md (transformacao, nao merge simples):**
   O CLAUDE.md light tem estrutura diferente do full (menos secoes, tabelas menores). O enriquecimento nao e merge aditivo puro — e uma **transformacao**:
   - **Substituir** o CLAUDE.md light pelo template full como base, **preservando dados customizados** (nome do projeto, stack, comandos, regras de seguranca, mindset preenchido)
   - Na pratica: ler dados customizados do CLAUDE.md light atual → gerar CLAUDE.md full com esses dados preenchidos + secoes novas com `{Adaptar:}` placeholders
   - Expandir tabela de Skills: de 11 core para todas as instaladas
   - Expandir tabela de Agents: de 5 core para todos os instalados
   - Adicionar secoes full-only: Execucao por agents, Worktrees, Modelos para sub-agents, Context budget
   - Adicionar `## Integracao Notion (specs)` se Notion foi escolhido
   - Adicionar `## Monorepo` se monorepo foi escolhido na Fase 2
   - Remover `<!-- framework-mode: light -->` (agora e full)

3. **Enriquecer TEMPLATE.md:**
   - Adicionar secoes faltantes do template full via structural merge
   - Se delta markers aceitos: adicionar secao de marcadores delta
   - Preservar customizacoes existentes nas secoes que ja existem

4. **Enriquecer backlog.md:**
   - Adicionar colunas do formato full (Sev, Impacto, Superficie, Destino, Compat, Tipo, Est, Deps, Origem)
   - Adicionar secoes: Descartados, Sugestao de execucao, Decisoes futuras, Legenda
   - Preservar itens existentes — migrar para formato expandido
   - Copiar `backlog-format.md` como referencia

5. **Enriquecer STATE.md:**
   - Adicionar secoes do formato full (phase machine, entry/exit criteria)
   - Preservar conteudo existente (em andamento, proximo, notas)

6. **Customizar com CODE_PATTERNS:**
   - Rodar mesma analise da Fase 1.6 do setup
   - Aplicar patterns detectados nas novas skills instaladas

7. **Atualizar SETUP_REPORT.md:** `> Modo: full`

## Fase 4 — Auditoria

Rodar a mesma auditoria da Fase 5b do setup (categorias 1-8) para verificar completude pos-upgrade.

## Fase 5 — UPGRADE_REPORT.md

Salvar em `.claude/UPGRADE_REPORT.md`:

```markdown
# Upgrade Report — light → full

> Data: {YYYY-MM-DD}
> Versao: {FRAMEWORK_VERSION}

## Instalados

| Arquivo | Tipo | Status |
|---|---|---|
| .claude/agents/seo-audit.md | agent | Instalado |
| .claude/skills/prd-creator/SKILL.md | skill | Instalado |
| docs/ARCHITECTURE.md | doc | Instalado |
| ... | ... | ... |

## Enriquecidos

| Arquivo | O que mudou |
|---|---|
| CLAUDE.md | +5 secoes, +11 skills na tabela, +11 agents na tabela |
| .claude/specs/TEMPLATE.md | +7 secoes (RFs, escopo, riscos, tasks, ...) |
| .claude/specs/backlog.md | +6 colunas, +4 secoes |

## Pendencias manuais

- Preencher `{Adaptar:}` placeholders nos novos arquivos
- Revisar CLAUDE.md — secoes novas podem precisar de ajuste ao contexto do projeto
```

## Regras

1. **Nunca sobrescrever customizacoes existentes.** Upgrade e aditivo — adiciona, nunca remove.
2. **Preservar conteudo do projeto.** Itens de backlog, specs, STATE.md — manter intactos.
3. **Structural merge para enriquecimento.** Adicionar secoes novas, nao substituir existentes.
4. **Nao commitar.** O usuario decide quando commitar apos revisar.
5. **V1: upgrade completo.** Cherry-pick de itens individuais fica fora do escopo.
