<!-- framework-tag: v2.46.1 framework-file: light:docs/QUICK_START.md -->
<!-- framework-mode: light -->
# Quick Start — {NOME_DO_PROJETO}

## Fluxo básico

1. **Recebeu demanda?** → Classificar:
   - Trivial (typo, config, 1-2 linhas)? → `/quick` — implementar direto
   - Não trivial? → Continuar abaixo

2. **Criar spec:** `/spec {ID} {Título}`
   - Preencher: contexto, o que fazer, critérios de aceitação

3. **Implementar:** seguindo `.claude/skills/spec-driven/README.md`
   - Ler spec → verificar código atual → implementar → testar

4. **Verificar:** `bash scripts/verify.sh` — zero falhas

5. **Fechar:** aplicar Definition of Done → commitar → `/backlog-update {ID} done`

6. **PR:** `/pr` — abre Pull Request com contexto da spec

## Comandos úteis

| Comando | O que faz |
|---------|-----------|
| `/spec {ID} {Título}` | Cria nova spec |
| `/backlog-update {ID} add {título}` | Adiciona item ao backlog |
| `/backlog-update {ID} done` | Marca item como concluído |
| `/quick` | Fast-path para tarefas triviais |
| `/resume` | Retoma sessão após crash/timeout |
| `/pr` | Abre Pull Request |

## Onde encontrar

| Recurso | Local |
|---------|-------|
| Backlog | `.claude/specs/backlog.md` |
| Specs ativas | `.claude/specs/` + `SPECS_INDEX.md` |
| Estado atual | `.claude/specs/STATE.md` |
| Skills | `.claude/skills/` |
| Agents | `.claude/agents/` |

## Quer mais?

O framework tem modo **full** com ~86 arquivos: PRDs, 16 agents, 26 skills, docs completos, orchestration de sub-agents, reports HTML. Para expandir: `/upgrade-framework`
