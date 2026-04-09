<!-- framework-tag: v2.22.0 framework-file: docs/SKILLS_MAP.md -->
# Mapa de dependencias entre skills

> Referencia visual de como as skills do framework se relacionam.
> Use para decidir quais skills consultar antes e durante a implementacao.

## Fluxo principal (ordem recomendada)

```
spec-driven → {skill de dominio} → testing → definition-of-done → docs-sync
```

O fluxo comeca com `spec-driven` (que spec implementar), passa pelas skills de dominio relevantes ao contexto (ex: `dba-review` se toca banco, `security-review` se toca auth), segue para `testing` e `definition-of-done`, e finaliza com `docs-sync`.

## Dependencias especificas

| Skill | Depende de | Complementa |
|---|---|---|
| testing | spec-driven (specs definem o que testar) | golden-tests, code-quality |
| code-quality | — | dba-review (se toca DB), testing |
| security-review | — | definition-of-done (security e pre-requisito) |
| dba-review | — | code-quality, performance-profiling |
| mock-mode | testing (mocks sao para testes) | api-testing |
| api-testing | testing | mock-mode, security-review |
| dependency-audit | — | security-review |
| performance-profiling | — | dba-review, code-quality |
| ux-review | — | seo-performance, component-audit (agent) |
| seo-performance | — | ux-review |
| docs-sync | definition-of-done | — |
| golden-tests | testing | — |
| syntax-check | — | code-quality |

## Legenda

- **Depende de:** a skill listada deve ser consultada/executada ANTES.
- **Complementa:** skills que agregam valor quando usadas juntas, sem ordem obrigatoria.
- Skills sem dependencia podem ser executadas a qualquer momento do fluxo.

## Skills de suporte (fora do fluxo principal)

| Skill | Quando usar |
|---|---|
| logging | Qualquer implementacao que adicione ou modifique logs |
| execution-plan | Ao planejar implementacao de spec Grande/Complexa |
| bug-investigation | Ao investigar bug antes de criar spec de correcao |
| backlog-update | Apos concluir spec ou identificar trabalho adicional |
| spec-creator (`/spec`) | Ao criar nova spec antes de iniciar implementacao |
| prd-creator | Ao criar PRD antes de quebrar em specs |
