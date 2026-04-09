<!-- framework-tag: v2.27.0 framework-file: docs/SKILLS_MAP.md -->
# Mapa de dependencias entre skills

> Referencia visual de como as skills do framework se relacionam.
> Use para decidir quais skills consultar antes e durante a implementacao.

## Fluxo principal (ordem recomendada)

```
spec-driven → research (se Grande/Complexo) → execution-plan (com waves) → context-fresh (se sub-agents) → {skill de dominio} → testing → definition-of-done → docs-sync
```

O fluxo comeca com `spec-driven` (que spec implementar). Para itens Grande/Complexo, passa por `research` (investigar codebase antes de planejar). Depois `execution-plan` (decompor em partes e derivar waves de execucao) e `context-fresh` (despachar waves para sub-agents, se o projeto usa). Segue pelas skills de dominio relevantes ao contexto (ex: `dba-review` se toca banco, `security-review` se toca auth), e finaliza com `testing`, `definition-of-done` e `docs-sync`.

## Dependencias especificas

| Skill | Depende de | Complementa |
|---|---|---|
| research | spec-driven (item classificado antes de pesquisar) | execution-plan (achados alimentam o plan) |
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
| context-fresh | execution-plan (decomposicao pronta) | spec-driven, definition-of-done. Waves de execucao do execution-plan alimentam o despacho |
| map-codebase | — | execution-plan (arquitetura informa o plan), spec-creator (escopo e impacto), /discuss (PROJECT_CONTEXT enriquecido torna scout mais preciso) |

## Legenda

- **Depende de:** a skill listada deve ser consultada/executada ANTES.
- **Complementa:** skills que agregam valor quando usadas juntas, sem ordem obrigatoria.
- Skills sem dependencia podem ser executadas a qualquer momento do fluxo.

## Skills de suporte (fora do fluxo principal)

| Skill | Quando usar |
|---|---|
| logging | Qualquer implementacao que adicione ou modifique logs |
| research | Ao investigar codebase antes de planejar (Grande/Complexo, dominio novo) |
| execution-plan | Ao planejar implementacao de spec Medio+ (3+ arquivos) |
| context-fresh | Ao despachar tasks para sub-agents com contexto limpo (Medio+ com sub-agents) |
| bug-investigation | Ao investigar bug antes de criar spec de correcao |
| backlog-update | Apos concluir spec ou identificar trabalho adicional |
| spec-creator (`/spec`) | Ao criar nova spec antes de iniciar implementacao |
| prd-creator | Ao criar PRD antes de quebrar em specs |
| map-codebase (`/map-codebase`) | Ao iniciar sessao em projeto desconhecido ou após longa ausência — mapear stack, arquitetura, convencoes e concerns antes de planejar |
