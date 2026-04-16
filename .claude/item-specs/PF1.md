# PF1 — Defaults inteligentes (inferência da Fase 1)

**Contexto:** a Fase 1 do setup detecta stack, DB, frontend, CI, test runner, comandos, mas a Fase 2 pergunta tudo do zero — não aproveita nada do que já sabe. Cada pergunta é texto livre sem defaults. Resultado: 20-30 perguntas que poderiam ser 1 confirmação.

**Abordagem:** Fase 1 produz um `DETECTION_SUMMARY` estruturado. Nova Fase 1.8 apresenta TUDO detectado de uma vez e pede confirmação em bloco. Se "Sim": pula Fase 2 inteira e vai direto pra Fase 3.

**Regras de inferência (Fase 1 → defaults):**

| Detectado | Default | Confiança |
|---|---|---|
| `package.json` name | Nome do projeto | Alta |
| `package.json` com react/vue/angular | Frontend=sim, ux-review=sim | Alta |
| `go.mod`/`requirements.txt`/`Gemfile` | Backend=sim | Alta |
| `migrations/` ou `prisma/` ou `schema.sql` | DB=sim, dba-review=sim | Alta |
| `.github/workflows/` | CI=GitHub Actions | Alta |
| `package.json scripts.test` | Test runner detectado | Alta |
| `package.json scripts.dev` | Dev command detectado | Alta |
| `pages/`/`app/` com SSR/SSG | Frontend público=sim, seo-performance=sim | Média |
| 1 package.json na raiz, sem packages/apps/ | Single-repo | Alta |
| Sem `.claude/prds/` | PRD=não | Alta |

**Apresentação (Fase 1.8):**

```
📋 Detecção automática:

  Projeto:    meu-app (package.json)
  Stack:      Node.js + React + TypeScript
  DB:         PostgreSQL (Prisma)
  Testes:     Vitest (scripts.test)
  CI:         GitHub Actions
  Tipo:       Single-repo (fullstack)
  
  Comandos detectados:
    dev:      npm run dev
    test:     npm test
    build:    npm run build
    coverage: npm run test -- --coverage

  Skills condicionais:
    ✅ dba-review (PostgreSQL detectado)
    ✅ ux-review (React detectado)
    ❌ seo-performance (sem SSR/SSG detectado)

Tudo correto? [Sim / Ajustar]
```

- Se "Sim": `FRAMEWORK_DEFAULTS = DETECTION_SUMMARY`, pular Fase 2, ir pra Fase 3
- Se "Ajustar": abrir Fase 2 com defaults pré-preenchidos (PF2)

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Nova Fase 1.8 (resumo + confirmação), Fase 2 condicional |
| Mirror | Sync |

**Critérios de aceitação:**
- [ ] Fase 1 gera DETECTION_SUMMARY com todos os campos (nome, stack, DB, testes, CI, comandos, tipo, skills condicionais)
- [ ] Fase 1.8 apresenta resumo formatado e pede confirmação
- [ ] "Sim" pula Fase 2 inteira — zero perguntas adicionais
- [ ] "Ajustar" abre Fase 2 com defaults pré-preenchidos
- [ ] Projetos com detecção ambígua (ex: Go + React sem package.json claro) fazem fallback para perguntas
- [ ] Re-run: se SETUP_REPORT existe, usar dados dele como DETECTION_SUMMARY base

**Restrições:**
- Nunca assumir sem confiança alta — se ambíguo, perguntar
- DETECTION_SUMMARY é interno (não salvo em arquivo, só memória da sessão)
- Compatibilidade: setup sem Fase 1 (edge case) → fallback para Fase 2 completa

**Deps:** nenhuma
