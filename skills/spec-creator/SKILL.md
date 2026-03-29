---
name: spec-creator
description: Cria uma nova spec a partir do template, atualiza SPECS_INDEX e backlog
user_invocable: true
---

# /spec — Criar nova spec

Cria uma nova spec a partir do TEMPLATE.md, registra no SPECS_INDEX.md e no backlog.

## Uso

```
/spec {ID} {Título}
```

Exemplos:
- `/spec AUTH3 Autenticação com SSO`
- `/spec FEAT5 Dashboard de métricas`
- `/spec SEC2 Rate limiting por IP`

## Instruções

1. **Validar ID:** verificar se já existe em `SPECS_INDEX.md`. Se sim, avisar.
1b. **Classificar complexidade:** antes de criar a spec, avaliar o tamanho:
   - **Pequeno** (≤3 arquivos, <30min, sem regra de negócio): criar APENAS entrada no backlog via `/backlog-update {ID} add`. Não criar spec. Informar: "Classificado como Pequeno — só precisa de entrada no backlog." Parar aqui.
   - **Médio** (<10 tasks, escopo claro): criar spec breve — preencher apenas Contexto, Requisitos Funcionais e Critérios de aceitação. Demais seções opcionais.
   - **Grande** (multi-componente, >10 tasks): criar spec completa + oferecer: "Quer criar um design doc também? (recomendado para features grandes)"
   - **Complexo** (ambiguidade, domínio novo, >20 tasks): criar spec completa + criar design doc + sugerir fluxo RPI: "Feature complexa — recomendo pesquisar em sessão separada, planejar, e implementar em sessão limpa."
   Na dúvida, classificar para cima.
2. **Criar arquivo:** copiar `.claude/specs/TEMPLATE.md` para `.claude/specs/{id-em-kebab-case}.md`
3. **Preencher header:**
   - Título: `# {ID} — {Título}`
   - Status: `rascunho`
   - Prioridade: perguntar ao usuário
   - Data: hoje
4. **Preencher contexto:** perguntar ao usuário ou inferir da conversa
5. **Registrar no SPECS_INDEX.md:**
   - Identificar o domínio correto
   - Adicionar linha com status `rascunho`
6. **Registrar no backlog** (se não existir):
   - Usar `/backlog-update {ID} add` ou adicionar manualmente
7. **Informar o usuário:**
   - Path do arquivo criado
   - Classificação de complexidade aplicada (Pequeno/Médio/Grande/Complexo)
   - Se Grande/Complexo: lembrar de criar design doc e breakdown de tasks
   - Lembrar que spec `rascunho` precisa ser aprovada antes de implementar

## Regras

- Spec criada sempre começa como `rascunho`
- Sempre registrar no SPECS_INDEX.md
- Sempre registrar no backlog (se item não existe ainda)
- Nomes de arquivo: `{id-kebab-case}.md` (ex: `auth3-sso.md`, `feat5-dashboard.md`)
- Seções obrigatórias do template devem ser mantidas (podem ficar com placeholder)
- Pequeno = sem spec (só backlog)
- Grande/Complexo = oferecer design doc (`.claude/specs/{id}-design.md`)
- Complexo = sugerir fluxo RPI (research → plan → implement em sessões separadas)
