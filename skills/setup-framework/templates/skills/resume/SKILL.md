---
name: resume
description: Retomada estruturada apos crash, timeout ou context limit via STATE.md e execution-plan
user_invocable: true
---
<!-- framework-tag: v2.37.3 framework-file: skills/resume/SKILL.md -->
# /resume — Retomada estruturada

> Use esta skill ao iniciar sessão nova após crash, timeout ou context limit.
> Reconstrói contexto a partir do STATE.md e execution-plan sem inventar estado.

## Quando usar

- Ao iniciar sessão nova após crash ou timeout da sessão anterior
- Quando a sessão anterior atingiu context limit no meio de uma task
- Ao retomar trabalho após pausa longa com STATE.md ativo

## Quando NÃO usar

- Para iniciar sessão em projeto sem STATE.md ativo (nada para retomar)
- Para revisar o que foi feito historicamente — usar `git log` para isso
- Se a task foi concluída na sessão anterior — iniciar nova task normalmente

## Protocolo de retomada (4 passos)

### Passo 1 — Ler STATE.md

Abrir `.claude/specs/STATE.md` e extrair:

- **Fase atual:** qual fase está em "Execução ativa" (`idle` / `plan` / `implement` / `verify` / `done`)
- **Task em execução:** ID e título
- **Entry/exit criteria** da fase atual
- **Log de transições:** sequência de fases já percorridas
- **Último contexto registrado** (se houver campo "Último checkpoint")

Se STATE.md não existe ou está vazio → informar ao dev e aguardar decisão. Não assumir nada.

### Passo 2 — Ler execution-plan (se existir)

Verificar se existe `.claude/specs/{id}-plan.md` (onde `{id}` é a task em execução no STATE.md).

- **Se existe:** ler e mapear tasks como ✅ concluídas (marcadas `[x]`) vs ⬜ pendentes
- **Se não existe:** registrar que não há plan — resumo virá só do STATE.md

### Passo 3 — Apresentar resumo

Apresentar ao dev:

```
## Resumo da sessão anterior

**Task:** {ID} — {Título}
**Fase:** {fase atual no STATE.md}
**Progresso:**
- ✅ {tasks concluídas do plan, se existir}
- ⬜ {tasks pendentes}

**Próximo passo previsto:** {último item pendente ou next step registrado no STATE.md}

**Incertezas:** {campos vazios ou inconsistências encontradas, se houver}
```

Exemplo concreto de resumo bem formado:

```
## Resumo da sessão anterior

**Task:** AUTH-12 — Implementar refresh token com rotação
**Fase:** implement
**Progresso:**
- ✅ Criar tabela refresh_tokens (migration rodada)
- ✅ Endpoint POST /auth/refresh — geração de novo token
- ⬜ Endpoint DELETE /auth/logout — invalidar token
- ⬜ Testes de integração

**Próximo passo previsto:** Implementar DELETE /auth/logout em auth.routes.ts

**Incertezas:** nenhuma
```

### Passo 4 — Confirmar antes de continuar

Perguntar ao dev:

1. O resumo está correto?
2. Pode continuar de onde parou, ou precisa de ajuste primeiro?

**Só prosseguir após confirmação explícita.** Se o dev corrigir algo, registrar a correção no STATE.md antes de continuar.

## Checklist

- [ ] Abriu `.claude/specs/STATE.md` e extraiu fase atual, task em execução e log de transições?
- [ ] Verificou se existe `.claude/specs/{id}-plan.md` para a task ativa?
- [ ] Apresentou resumo com task, fase, progresso (✅/⬜) e próximo passo previsto?
- [ ] Declarou explicitamente qualquer campo vazio ou inconsistência no STATE.md?
- [ ] Aguardou confirmação do dev antes de continuar?
- [ ] Atualizou STATE.md se o dev corrigiu informações durante a retomada?

## Regras

1. **Nunca inventar estado** — se STATE.md não tem a informação, declarar lacuna e perguntar
2. **Não prosseguir sem confirmação** — o dev precisa validar o resumo antes de continuar
3. **Atualizar STATE.md** se o dev corrigir informações durante a retomada
4. **Execution-plan ausente não é erro** — funcionar normalmente com só STATE.md
