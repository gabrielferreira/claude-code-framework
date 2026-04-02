<!-- framework-tag: v2.10.0 framework-file: docs/QUICK_START.md -->
# Quick Start — claude-code-framework

> Em 5 minutos voce tera: CLAUDE.md configurado, backlog pronto, skills de dominio instaladas e um fluxo spec-driven funcionando no seu projeto.

---

## Pre-requisitos

- Repositorio git inicializado (pode estar vazio)
- Claude Code instalado e funcionando

---

## Instalacao

Escolha uma das opcoes (detalhes completos no [README](../README.md)):

| Opcao | Comando | Quando usar |
|---|---|---|
| **Por projeto** | `cp -r /path/claude-code-framework/skills/setup-framework .claude/skills/setup-framework` | Uso pontual num repo |
| **Personal** | `./scripts/install-skills.sh` (do clone do framework) | Disponivel em todos os seus projetos |
| **Plugin** | `claude plugin install claude-code-framework` | Times com Claude Code Team |

---

## Setup

Na raiz do seu projeto, execute:

```
/setup-framework
```

O wizard vai:
1. **Analisar o repositorio** — detecta stack, estrutura, ferramentas
2. **Fazer perguntas** — nome do projeto, convencoes, integracao Notion (opcional)
3. **Gerar arquivos** — CLAUDE.md, PROJECT_CONTEXT.md, SPECS_INDEX.md, skills, agents, docs, scripts

Ao final, voce recebe um relatorio do que foi criado e o que ficou pendente.

---

## Primeiro ciclo

### 1. Criar uma spec

```
/spec
```

Descreva a feature ou tarefa. O comando gera uma spec estruturada em `.claude/specs/` com criterios de aceite, escopo e definicao de done.

### 2. Implementar

Trabalhe normalmente com o Claude Code. A spec serve como contexto — o Claude sabe o que precisa ser feito e quando esta pronto.

### 3. Fechar a spec

```
/backlog-update done
```

Marca a spec como concluida no backlog e atualiza o SPECS_INDEX.md.

Pronto — esse e o ciclo basico. Repita para cada entrega.

---

## Proximos passos

- **[Guia de Setup](SETUP_GUIDE.md)** — detalhes de cada opcao de instalacao e configuracao avancada
- **[Guia Spec-Driven](SPEC_DRIVEN_GUIDE.md)** — fluxo completo de specs, backlog e verificacao

---

*Para atualizar o framework no futuro: `/update-framework`*
