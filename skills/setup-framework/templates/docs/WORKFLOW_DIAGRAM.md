<!-- framework-tag: v2.21.0 framework-file: docs/WORKFLOW_DIAGRAM.md -->
# Workflow do Claude Code Framework

Diagrama visual de como o framework funciona — do setup inicial ao uso diário e atualizações.

---

## Visão geral de alto nível

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      CLAUDE-CODE-FRAMEWORK (repo)                       │
│                                                                         │
│  Sources:  agents/  skills/  docs/  specs/  scripts/                    │
│  Templates: skills/setup-framework/templates/ (cópia dos sources)       │
│  Config:   MANIFEST.md  VERSION  CLAUDE.template.md                     │
└────────────────────┬───────────────────────┬────────────────────────────┘
                     │                       │
            /setup-framework          /update-framework
             (primeira vez)            (atualizações)
                     │                       │
                     ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        PROJETO DO USUÁRIO                               │
│                                                                         │
│  CLAUDE.md          ← regras, skills, agents, comandos                  │
│  PROJECT_CONTEXT.md ← contexto do projeto                               │
│  SPECS_INDEX.md     ← índice de specs                                   │
│  .claude/                                                               │
│    ├── agents/      ← auditorias (read-only)                            │
│    ├── skills/      ← workflows de desenvolvimento                      │
│    ├── specs/       ← specs ativas + backlog + STATE.md                  │
│    └── prds/        ← PRDs (opt-in)                                     │
│  docs/              ← documentação do projeto                           │
│  scripts/           ← verify.sh, reports.sh                             │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Setup (`/setup-framework`)

Wizard interativo que implanta o framework num repositório existente.

```
┌──────────────────────────────────────────────────────────────────┐
│                     /setup-framework                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Fase 0 ─ Pré-requisitos                                        │
│  │  • Localizar templates do framework                           │
│  │  • Validar que está na raiz do repo (.git/)                   │
│  │  • Detectar re-run vs primeira vez                            │
│  │  • Detectar monorepo                                          │
│  ▼                                                               │
│  Fase 1 ─ Análise do repositório                                 │
│  │  • Detectar stack (backend, frontend, fullstack)              │
│  │  • Detectar DB, frontend público, CI                          │
│  │  • Mapear estrutura de diretórios                             │
│  ▼                                                               │
│  Fase 2 ─ Perguntas interativas                                  │
│  │  • Confirmar stack detectada                                  │
│  │  • Coletar comandos (dev, test, build)                        │
│  │  • Definir regras de segurança                                │
│  │  • Escolher skills condicionais (dba, ux, seo)               │
│  │  • Configurar Notion (se MCP disponível)                      │
│  ▼                                                               │
│  Fase 3 ─ Geração de arquivos                                    │
│  │  • Copiar agents (structural — preserva customização)          │
│  │  • Copiar skills com {placeholders} preenchidos               │
│  │  • Gerar CLAUDE.md a partir do template                       │
│  │  • Criar specs/, docs/, scripts/                              │
│  │  • Gerar SETUP_REPORT.md                                      │
│  ▼                                                               │
│  Fase 4 ─ Auditoria de completude                                │
│     • Verificar arquivos, agents, skills, seções                 │
│     • Oferecer auto-fix para findings                            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. Uso diário (fluxo spec-driven)

O ciclo de desenvolvimento com o framework instalado.

```
                    ┌─────────────────┐
                    │  Nova feature /  │
                    │  bug / tarefa    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Ler STATE.md    │  ← memória entre sessões
                    └────────┬────────┘
                             │
                             ▼
                 ┌───────────────────────┐
                 │ Existe spec para isso?│
                 └───────┬───────┬───────┘
                    Sim  │       │  Não
                         │       │
                         │       ▼
                         │  ┌──────────────────┐
                         │  │ Tarefa trivial?   │
                         │  │ (<3 arquivos,     │
                         │  │  <30min)          │
                         │  └──┬────────┬───────┘
                         │  Sim│        │Não
                         │     │        ▼
                         │     │  ┌──────────────┐
                         │     │  │ /spec — Criar │
                         │     │  │  spec antes   │
                         │     │  │  de codar     │
                         │     │  └──────┬───────┘
                         │     │         │
                         ▼     ▼         ▼
                    ┌─────────────────────────┐
                    │  Ler skill(s) aplicável │  ← ANTES de codar
                    │  (testing, code-quality, │
                    │   security-review, etc.) │
                    └────────────┬────────────┘
                                │
                                ▼
                    ┌─────────────────────────┐
                    │      Implementar        │
                    │  (seguindo spec + skill) │
                    └────────────┬────────────┘
                                │
                                ▼
                    ┌─────────────────────────┐
                    │   verify.sh             │  ← obrigatório antes de commit
                    │   (lint + test + build)  │
                    └──────┬─────────┬────────┘
                      Pass │         │ Fail
                           │         │
                           │         ▼
                           │   ┌───────────┐
                           │   │ Corrigir   │──┐
                           │   └───────────┘  │
                           │         ▲        │
                           │         └────────┘
                           ▼
                    ┌─────────────────────────┐
                    │      git commit         │
                    │  (conventional commits)  │
                    └────────────┬────────────┘
                                │
                                ▼
                    ┌─────────────────────────┐
                    │  Atualizar STATE.md     │  ← decisões, blockers,
                    │  + backlog se necessário │     próximos passos
                    └─────────────────────────┘
```

---

## 3. Agents (auditoria sob demanda)

Agents são read-only: geram relatórios, nunca aplicam fixes diretamente.

```
                     ┌──────────────────────┐
                     │   Invocar agent      │
                     │   (sub-agent Claude) │
                     └──────────┬───────────┘
                                │
              ┌─────────────────┼──────────────────┐
              ▼                 ▼                   ▼
    ┌──────────────┐  ┌──────────────┐   ┌──────────────────┐
    │security-audit│  │ code-review  │   │ coverage-check   │
    │              │  │              │   │                  │
    │ OWASP top 10 │  │ qualidade,   │   │ gaps de          │
    │ vulnerab.    │  │ patterns     │   │ cobertura        │
    └──────┬───────┘  └──────┬───────┘   └────────┬─────────┘
           │                 │                    │
           └─────────────────┼────────────────────┘
                             ▼
                    ┌─────────────────┐
                    │   Relatório     │
                    │   com findings  │
                    │   🔴🟠🟡⚪      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Criar item no   │
                    │ backlog ou spec │  ← nunca fix direto
                    └─────────────────┘

  Agents disponíveis:
  ┌────────────────────┬──────────────────────────────┐
  │ security-audit     │ Vulnerabilidades OWASP       │
  │ code-review        │ Qualidade e padrões          │
  │ coverage-check     │ Gaps de cobertura de testes  │
  │ spec-validator     │ Spec completa e consistente? │
  │ backlog-report     │ Estado do backlog            │
  │ component-audit    │ Componentes UI (frontend)    │
  │ seo-audit          │ SEO e performance (frontend) │
  │ product-review     │ PRD vs implementação         │
  │ refactor-agent     │ Oportunidades de refactoring │
  │ test-generator     │ Sugestões de testes          │
  └────────────────────┴──────────────────────────────┘
```

---

## 4. Update (`/update-framework`)

Atualiza o framework já instalado quando sai versão nova.

```
┌──────────────────────────────────────────────────────────────────┐
│                    /update-framework                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Fase 0 ─ Localizar e validar                                    │
│  │  • Encontrar framework source                                 │
│  │  • Ler versão instalada (framework-tags nos arquivos)         │
│  │  • Comparar: instalada vs source                              │
│  │  • Se iguais → "Nada a fazer"                                 │
│  │  • Detectar perfil do projeto (stack, DB, frontend)           │
│  ▼                                                               │
│  Fase 1 ─ Análise de diferenças                                  │
│  │  • git diff entre tags (Added/Modified/Deleted)               │
│  │  • Classificar cada arquivo pela estratégia do MANIFEST:      │
│  │                                                               │
│  │    ┌───────────┬────────────────────────────────────┐         │
│  │    │ overwrite │ Substitui direto (plugin, migrat.)  │         │
│  │    │ structural│ Preserva conteúdo, add/rm seções   │         │
│  │    │ manual    │ Mostra diff, nunca aplica sozinho   │         │
│  │    │ skip      │ Nunca toca (backlog, STATE, specs)  │         │
│  │    └───────────┴────────────────────────────────────┘         │
│  │                                                               │
│  │  • Gerar relatório de mudanças agrupado por estratégia        │
│  ▼                                                               │
│  Fase 2 ─ Confirmação                                            │
│  │  1. Aplicar tudo                                              │
│  │  2. Só automáticos (overwrite + novos)                        │
│  │  3. Selecionar por arquivo                                    │
│  │  4. Dry run                                                   │
│  │  5. Cancelar                                                  │
│  ▼                                                               │
│  Fase 3 ─ Aplicação                                              │
│  │  • overwrite  → cp direto do source                           │
│  │  • structural → merge por seções H2/H3                        │
│  │  • manual     → diff + confirmação individual                 │
│  │  • novos      → filtrar por relevância, perguntar             │
│  │  • removidos  → confirmar antes de deletar                    │
│  ▼                                                               │
│  Fase 4 ─ Extras                                                 │
│  │  • Monorepo (atualizar sub-projetos)                          │
│  │  • Notion (sync templates de database)                        │
│  │  • PRD (opt-in, migração se estrutura antiga)                 │
│  ▼                                                               │
│  Fase 5 ─ Relatório + Auditoria                                  │
│     • Salvar UPDATE_REPORT.md                                    │
│     • Auditoria de completude (mesmos checks do setup)           │
│     • Auto-fix para findings corrigíveis                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 5. Ciclo completo (do framework ao projeto e de volta)

```
┌─────────────────┐
│  Desenvolvedor   │
│  do framework    │
└────────┬────────┘
         │
         │  1. Edita sources (agents/, skills/, docs/)
         │  2. Sincroniza source → template
         │  3. Atualiza MANIFEST se necessário
         │  4. Commit (conventional commits)
         │  5. Release (bump VERSION, tags, CHANGELOG)
         │
         ▼
┌─────────────────────────────┐
│  claude-code-framework repo │
│  v2.10.0                    │
└────────────┬────────────────┘
             │
     ┌───────┴────────┐
     │                │
     ▼                ▼
┌──────────┐   ┌───────────┐
│  Projeto │   │  Projeto  │
│  novo    │   │  existente│
└────┬─────┘   └─────┬─────┘
     │               │
  /setup-         /update-
  framework       framework
     │               │
     ▼               ▼
┌─────────────────────────┐
│     Projeto com         │
│     framework ativo     │
│                         │
│  Dia a dia:             │
│  • /spec → criar specs  │
│  • Skills → guiar dev   │
│  • Agents → auditar     │
│  • verify.sh → validar  │
│  • STATE.md → memória   │
│  • /backlog-update      │
└─────────────────────────┘
```

---

## 6. Estratégias de atualização (MANIFEST)

Como cada tipo de arquivo é tratado no update:

```
  Framework Source                          Projeto
  ─────────────────                         ────────────────────

  agents/security-audit.md  ──structural─▶  .claude/agents/security-audit.md
  (preserva model: e {Adaptar:})            (seções novas adicionadas)

  skills/testing/README.md  ──structural─▶  .claude/skills/testing/README.md
  (seções novas/removidas)                  (conteúdo customizado preservado)

  scripts/verify.sh         ──manual─────▶  scripts/verify.sh
  (mostra diff)                             (usuário decide cada mudança)

  backlog.md                ──skip───────▶  .claude/specs/backlog.md
  STATE.md                                  (nunca tocado — 100% do projeto)
```

---

## 7. Notion (integração opcional)

```
┌──────────────┐     MCP Notion      ┌──────────────────┐
│  Notion DB   │◄───────────────────▶│  Claude Code      │
│  (specs)     │     (se config.)    │  no projeto       │
└──────────────┘                     └──────────────────┘
       │                                      │
       │  Templates mapeados                  │
       │  por complexidade                    │
       │  (P/M/G/GG)                          │
       ▼                                      ▼
  ┌─────────┐                          ┌──────────┐
  │ /spec   │  cria spec local +       │/backlog- │  sincroniza
  │         │  página no Notion        │update    │  backlog.md
  └─────────┘                          └──────────┘  com Notion
```
