# PF2 — Perguntas agrupadas com opções selecionáveis

**Contexto:** hoje cada pergunta da Fase 2 do setup é uma chamada individual de AskUserQuestion com texto livre. São 20-30 round trips sequenciais. O Claude Code suporta AskUserQuestion com `options` (selecionáveis com label/description) e `multiSelect`, mas o setup não usa.

**Abordagem:** reorganizar a Fase 2 em 4 blocos temáticos, cada um com 1 AskUserQuestion usando opções clicáveis. Só executa se PF1 retornou "Ajustar" (quando detecção automática não foi suficiente).

**4 blocos:**

**Bloco 1 — Modo do framework (1 question, 2 options):**
```json
{
  "questions": [{
    "question": "Qual modo do framework?",
    "header": "Modo",
    "options": [
      {"label": "Light (Recomendado)", "description": "~31 arquivos, setup em 5 min"},
      {"label": "Full", "description": "~86 arquivos, docs completos, PRDs, monorepo"}
    ],
    "multiSelect": false
  }]
}
```

**Bloco 2 — Identidade + modelo (até 4 questions simultâneas):**
```json
{
  "questions": [
    {
      "question": "Nome do projeto?",
      "header": "Nome",
      "options": [
        {"label": "{nome-detectado}", "description": "Detectado do package.json"},
        {"label": "Outro", "description": "Digitar nome diferente"}
      ],
      "multiSelect": false
    },
    {
      "question": "Modelo de specs?",
      "header": "Specs",
      "options": [
        {"label": "Repo (Recomendado)", "description": "Specs em .claude/specs/, backlog local"},
        {"label": "Notion", "description": "Via MCP (requer configuração prévia)"},
        {"label": "Externo", "description": "Jira/Linear/GitHub Issues"}
      ],
      "multiSelect": false
    },
    {
      "question": "Coverage threshold?",
      "header": "Coverage",
      "options": [
        {"label": "80% (Recomendado)", "description": "Padrão para a maioria"},
        {"label": "90%", "description": "Alta criticidade"},
        {"label": "70%", "description": "Estágio inicial"}
      ],
      "multiSelect": false
    }
  ]
}
```

**Bloco 3 — Confirmação de stack (1 question, multiSelect pré-marcado):**
```json
{
  "questions": [{
    "question": "Stack detectada. Desmarque o que não se aplica:",
    "header": "Stack",
    "options": [
      {"label": "Node.js + React", "description": "Detectado: package.json"},
      {"label": "PostgreSQL", "description": "Detectado: migrations/"},
      {"label": "GitHub Actions", "description": "Detectado: .github/workflows/"},
      {"label": "TDD obrigatório", "description": "Padrão do framework"}
    ],
    "multiSelect": true
  }]
}
```

**Bloco 4 — Skills condicionais (1 question, multiSelect):**
```json
{
  "questions": [{
    "question": "Skills condicionais detectadas. Desmarque as que não quer:",
    "header": "Skills",
    "options": [
      {"label": "dba-review", "description": "DB detectado"},
      {"label": "ux-review", "description": "Frontend detectado"},
      {"label": "seo-performance", "description": "Frontend público detectado"}
    ],
    "multiSelect": true
  }]
}
```

**Se modo=light:** pular Blocos 3-4 (instala core automaticamente).

**Total:** 4 AskUserQuestion em vez de 20-30. Tempo: ~90s em vez de 15-30 min.

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Fase 0 passo 5 (modo) e Fase 2 inteira reescrita em blocos |
| Mirror | Sync |

**Critérios de aceitação:**
- [ ] Fase 2 usa no máximo 4 AskUserQuestion (não 20-30)
- [ ] Cada AskUserQuestion usa `options` com label/description (não texto livre)
- [ ] Bloco 3 e 4 usam `multiSelect: true`
- [ ] Defaults da PF1 (DETECTION_SUMMARY) pré-preenchem as opções
- [ ] Modo light pula Blocos 3-4
- [ ] "Outro" em qualquer opção permite texto livre como fallback
- [ ] Zero funcionalidade perdida — todas as informações coletadas hoje continuam sendo coletadas

**Restrições:**
- AskUserQuestion suporta no máximo 4 questions por chamada e 4 options por question
- Se precisar de mais de 4 options: dividir em 2 chamadas
- Notion mode pode precisar de chamada extra (notion-fetch para schema)

**Deps:** PF1 (usa DETECTION_SUMMARY como base para defaults)
