---
name: quick
description: Quick task — implementação direta sem spec para correções triviais
user_invocable: true
---
<!-- framework-tag: v2.41.0 framework-file: skills/quick/SKILL.md -->

# /quick — Quick Task (fast-path)

Implementação direta sem spec, sem STATE.md, sem DoD completo. Para correções triviais que não justificam cerimônia.

## Quando usar

- Typo, fix de texto, ajuste de mensagem
- Bump de dependência
- Ajuste de config (env, lint, CI)
- Rename sem mudança de lógica
- Fix de 1-2 linhas sem nova lógica de negócio

## Quando NÃO usar (redirecionar para spec-driven)

- Toca lógica de negócio (nova regra, novo fluxo, mudança de comportamento)
- Toca auth, pagamentos ou dados sensíveis
- Cria nova abstração, módulo ou componente
- Altera schema de banco
- Afeta mais de 3 arquivos

> **Na dúvida, não é quick task.** Usar `/spec` ou seguir `spec-driven`.

## Fluxo

1. **Validar critérios** — a mudança se encaixa nos critérios acima?
   - Se sim → continuar
   - Se não → informar: "Isso não é quick task porque {motivo}. Use `/spec` para criar uma spec."

2. **Implementar** — fazer a mudança diretamente

3. **Testar** — rodar testes relevantes. Se quebrou algo, a mudança não era trivial — parar e criar spec.

4. **Verificar** — `bash scripts/verify.sh`

5. **Commitar** — Conventional Commits (`fix:`, `docs:`, `chore:`, etc.)

6. **PR** — abrir PR para main (nunca push direto)

## Checklist

- [ ] Mudança se encaixa nos critérios de quick task (não toca lógica de negócio, auth, schema, ≤3 arquivos)
- [ ] Implementação concluída
- [ ] Testes relevantes passando (se quebrou → não é quick task, criar spec)
- [ ] `verify.sh` executado sem erros
- [ ] Commit com Conventional Commits
- [ ] PR aberto para main (nunca push direto)

## Regras

1. **Sem spec.** Não criar spec, não atualizar SPECS_INDEX.
2. **Sem STATE.md.** Não atualizar STATE.md.
3. **verify.sh obrigatório.** Sem exceções.
4. **Se complicou, parar.** Se durante a implementação perceber que é mais complexo do que parecia → parar, desfazer, criar spec via `/spec`.
5. **Backlog pós-facto.** Se a quick task revelou trabalho adicional, registrar no backlog após o commit.
