<!-- framework-tag: v2.48.0 framework-file: light:skills/definition-of-done/README.md -->
<!-- framework-mode: light -->
# Skill: Definition of Done — {NOME_DO_PROJETO}

> Aplicar ANTES de qualquer commit de entrega.

## Quando usar

- Antes de commitar qualquer feature, bugfix ou refatoração
- Como gate final de qualidade

## Quando NÃO usar

- Quick tasks (typo, bump, config) — verify.sh basta
- Spikes ou exploração sem compromisso de entrega

## Checklist universal

Aplicar **todos** os itens antes de commitar:

### Código

- [ ] Testes passando — zero falhas
- [ ] Coverage ≥ {X}% nos módulos alterados
- [ ] `bash scripts/verify.sh` — zero ❌
- [ ] Sem TODOs não-rastreados no código novo
- [ ] Sem console.log/print de debug no código final
- [ ] Error handling explícito (sem catch genérico)

### Spec

- [ ] Cada critério de aceitação da spec verificado no código (1 a 1)
- [ ] Se spec tem restrições → confirmadas (nada violado)
- [ ] Status da spec atualizado

### Git

- [ ] Commits seguem Conventional Commits
- [ ] Cada commit é atômico (uma mudança lógica por commit)
- [ ] Branch nomeada conforme `docs/GIT_CONVENTIONS.md`

### Segurança (se aplicável)

- [ ] Input sanitizado
- [ ] Sem secrets no código
- [ ] Queries com prepared statements

## Após o checklist

Se todos os itens passam:
1. Commitar com mensagem Conventional Commits
2. Atualizar backlog: `/backlog-update {ID} done`
3. Mover spec para done/

Se algum item falha:
1. Corrigir antes de commitar
2. Se não é corrigível agora: documentar no commit e criar item no backlog
