# Contribuindo com o claude-code-framework

Guia de onboarding para quem vai **desenvolver o framework** — diferente do README.md, que é para quem instala o framework em projetos.

---

## Leitura obrigatória antes de começar

Nesta ordem:

| # | Arquivo | O que explica |
|---|---------|--------------|
| 1 | `CLAUDE.md` | Regras de desenvolvimento, estrutura do repo, processo de release, padrões para criar skills e agents |
| 2 | `.claude/TASK_CHECKLIST.md` | Checklist que toda tarefa deve cumprir antes de ser considerada concluída |
| 3 | `MANIFEST.md` | O que vai para projetos, com qual estratégia (overwrite/structural/manual/skip) |
| 4 | `BACKLOG.md` | O que está pendente, o que foi descartado e por quê, ordem de execução sugerida — e índice para specs detalhadas (seção `## Detalhes por item`) |

> O Claude lê `CLAUDE.md` e `.claude/TASK_CHECKLIST.md` automaticamente a cada sessão. Quando trabalhar com Claude Code neste repo, esses arquivos já estarão no contexto.

---

## O que é este repo (perspectiva de dev)

Este é o **repo-fonte** do framework. Projetos que usam o framework **não editam aqui** — eles recebem uma cópia via `/setup-framework` e atualizações via `/update-framework`.

Isso significa que qualquer mudança aqui chega a projetos reais de outras pessoas. A regra mais importante do repo:

> **Todo arquivo distribuído existe em dois lugares: source (raiz) e `skills/setup-framework/templates/`.  
> Editar um sem editar o outro quebra o framework.**

---

## Estrutura do repo (perspectiva de dev)

```
claude-code-framework/
├── CLAUDE.md                    ← Regras de dev do framework (leia primeiro)
├── CLAUDE.template.md           ← Template que vira CLAUDE.md nos projetos
├── MANIFEST.md                  ← Fonte de verdade: o que vai pro projeto e como
├── VERSION                      ← Versão atual (semver)
├── BACKLOG.md                   ← Roadmap de evolução do framework
├── CONTRIBUTING.md              ← Este arquivo
├── CHANGELOG.md                 ← Histórico de versões
├── .claude/
│   ├── TASK_CHECKLIST.md        ← Checklist de tarefas (não distribuído)
│   └── settings.local.json      ← Settings locais (gitignored)
├── agents/                      ← Source dos agents (→ templates/agents/)
├── skills/
│   ├── setup-framework/         ← Skill de setup + templates/
│   │   └── templates/           ← Espelho de tudo que vai pro projeto
│   ├── update-framework/        ← Skill de update
│   ├── spec-creator/            ← Skill /spec (dual-mode: repo + Notion)
│   ├── backlog-update/          ← Skill /backlog-update (dual-mode)
│   └── {outras}/                ← Skills de domínio
├── docs/                        ← Docs source (→ templates/docs/)
├── migrations/                  ← Guias de migração entre versões
└── scripts/
    ├── verify.sh                ← Copiado pro projeto
    ├── reports.sh               ← Copiado pro projeto
    ├── install-skills.sh        ← Instalação pessoal (não copiado)
    ├── validate-tags.sh         ← Validação de framework-tags (CI)
    ├── check-sync.sh            ← Validação de sincronia source↔template (CI)
    └── test-setup.sh            ← Simulação de setup em repo fake (CI)
```

---

## Setup local

```bash
# 1. Clonar o repo
git clone https://github.com/estrategiahq/claude-code-framework.git
cd claude-code-framework

# 2. Instalar as skills de gestão no seu Claude Code pessoal
./scripts/install-skills.sh

# 3. Verificar que tudo está em ordem
bash scripts/validate-tags.sh && bash scripts/check-sync.sh && bash scripts/test-setup.sh
```

Para testar mudanças num projeto real:
```bash
# Em um repo de teste separado
/setup-framework   # instala o framework
# faça uma mudança no framework e bump de versão
/update-framework  # verifica que detecta e aplica corretamente
```

---

## Fluxo de contribuição

**Nunca commitar diretamente na `main`.** Todo trabalho entra via Pull Request.

```bash
# 1. Criar branch
git checkout -b feat/nome-da-feature   # ou fix/, docs/, refactor/

# 2. Trabalhar nos sources
# Lembrar: source + template sempre em sincronia (ver TASK_CHECKLIST.md)

# 3. Validar localmente antes do PR
bash scripts/validate-tags.sh && bash scripts/check-sync.sh && bash scripts/test-setup.sh

# 4. Commitar (Conventional Commits obrigatório)
git commit -m "feat: descrição da mudança"

# 5. Abrir PR para main
git push -u origin feat/nome-da-feature
gh pr create
```

O CI roda os 3 scripts de validação automaticamente em todo PR. Se passar localmente, passa no CI.

---

## Conventional Commits

| Prefixo | Quando usar | Bump de versão |
|---------|------------|----------------|
| `feat:` | Skill nova, agent novo, campo novo, seção nova | minor |
| `fix:` | Correção de bug ou instrução errada | patch |
| `docs:` | Documentação (README, guias, etc.) | patch |
| `refactor:` | Reestruturação sem mudar comportamento | patch |
| `feat!:` | Breaking change | major |

---

## Regras essenciais

As regras completas estão no `CLAUDE.md`. As mais críticas:

1. **Source + template sempre em sincronia** — ao editar qualquer source, copiar para o template correspondente em `skills/setup-framework/templates/`
2. **MANIFEST atualizado** — arquivo novo no framework = entrada no MANIFEST com estratégia
3. **Setup E update cobertos** — mudança deve funcionar para projetos novos (setup) e existentes (update)
4. **Dual-mode** — skills `spec-creator` e `backlog-update` têm modo repo e modo Notion; mudanças devem funcionar nos dois
5. **Docs revisadas ao finalizar** — `docs/SKILLS_MAP.md`, `docs/WORKFLOW_DIAGRAM.md`, `CLAUDE.template.md` (e seus dois mirrors)

---

## Por onde começar

1. Consulte a seção **"Sugestão de execução — Wave 1"** no `BACKLOG.md` para o próximo item de maior impacto.
2. Se o item tiver entrada em **`## Detalhes por item`** do BACKLOG.md, leia o arquivo `.claude/item-specs/{ID}.md` antes de começar — decisões de abordagem e restrições já estão documentadas lá.
3. Se não tiver detalhe, o item ainda não foi refinado — pode abrir uma sessão de discussão antes de implementar.

Se preferir algo mais isolado (sem dependências), Wave 3 e Wave 4 têm itens independentes que podem ser implementados em qualquer ordem.

## Fluxo spec-driven simplificado

O framework usa um spec-driven simplificado para seu próprio desenvolvimento. Specs de itens do backlog vivem em `.claude/item-specs/{ID}.md` — arquivos pequenos, carregados cirurgicamente quando necessário.

Ao refinar um item (em sessão de discussão com o Claude ou com o time), criar ou atualizar `.claude/item-specs/{ID}.md` com:
- Por que o item existe e que problema resolve
- A abordagem escolhida (e alternativas descartadas)
- Critérios de aceitação verificáveis
- Restrições e gates

O BACKLOG.md mantém apenas o índice (`## Detalhes por item`) com links para os arquivos.

Ao concluir o item, deletar o arquivo de spec e remover do índice (o contexto fica no commit).

---

## Dúvidas sobre decisões passadas

Antes de propor algo, verifique:
- **`BACKLOG.md` → Descartados** — o item pode já ter sido avaliado e descartado com motivo documentado
- **`BACKLOG.md` → Decisões futuras** — pode ser uma decisão intencionalmente adiada com gatilho definido
- **`CHANGELOG.md`** — histórico de o que foi implementado e quando
