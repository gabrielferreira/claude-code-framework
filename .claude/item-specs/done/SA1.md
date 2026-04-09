# SA1 — Skill `/map-codebase`

**Contexto:** ao adotar o framework num projeto existente, o dev não tem onde registrar stack, padrões e pontos de atenção do codebase. Sem esse mapa, o Claude parte do zero a cada sessão e pode propor mudanças inconsistentes com as convenções já estabelecidas.

**Abordagem:** skill que executa análise paralela do projeto (stack, arquitetura, convenções, concerns) e popula o `PROJECT_CONTEXT.md`. Rodar uma vez no onboarding ou quando o projeto mudar significativamente.

Saída esperada: stack identificado, padrões de código, arquivos críticos, áreas de risco (tech debt, acoplamentos), sugestão de preenchimento do `PROJECT_CONTEXT.md`.

**Critérios de aceitação:**
- [ ] skill `/map-codebase` em `.claude/skills/map-codebase/README.md`
- [ ] análise cobre: stack, estrutura de diretórios, padrões, dependências principais, áreas de risco
- [ ] saída é um rascunho pronto para colar no `PROJECT_CONTEXT.md`
- [ ] setup-framework e update-framework cientes da skill

**Status:** dev em andamento (2026-04-09).
