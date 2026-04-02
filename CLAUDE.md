# CLAUDE.md — claude-code-framework (desenvolvimento)

Este arquivo e para quem **desenvolve o framework**. NAO e copiado para projetos — projetos recebem o `CLAUDE.template.md` customizado pelo setup.

## O que e este projeto

Framework de specs, skills, agents e verificacao para projetos com Claude Code. Gera estrutura completa via `/setup-framework` e mantém atualizado via `/update-framework`. Suporta Notion nativo via MCP.

## Estrutura do repo

```
claude-code-framework/
├── CLAUDE.md                  ← ESTE ARQUIVO (dev do framework)
├── CLAUDE.template.md         ← Template que vira CLAUDE.md nos projetos
├── PROJECT_CONTEXT.md         ← Template de contexto
├── SPECS_INDEX.template.md    ← Template do indice de specs
├── MANIFEST.md                ← Fonte de verdade: o que vai pro projeto e como
├── VERSION                    ← Versao atual (semver)
├── .claude-plugin/
│   └── plugin.json            ← Manifesto para instalacao via plugin
├── agents/                    ← Agents source (copiados como overwrite)
├── skills/
│   ├── setup-framework/       ← Skill de setup (inclui templates/)
│   │   └── templates/         ← Copia de todos os arquivos que vao pro projeto
│   ├── update-framework/      ← Skill de update
│   ├── spec-creator/          ← Skill /spec (dual-mode: repo + Notion)
│   ├── backlog-update/        ← Skill /backlog-update (dual-mode)
│   └── {outras}/              ← Skills de dominio (testing, code-quality, etc.)
├── docs/                      ← Docs source
├── specs/                     ← Templates de spec (TEMPLATE.md, DESIGN_TEMPLATE.md)
└── scripts/
    ├── verify.sh              ← Copiado pro projeto (manual)
    ├── reports.sh             ← Copiado pro projeto (manual)
    └── install-skills.sh      ← NAO copiado — instalacao pessoal
```

## Regra de ouro: source + templates em sincronia

Todo arquivo que vai pro projeto existe em **dois lugares**:
1. **Source** (raiz): `agents/security-audit.md`, `skills/testing/README.md`, etc.
2. **Template** (copia): `skills/setup-framework/templates/agents/security-audit.md`, etc.

**Sempre que editar um source, copiar para o template correspondente.** O setup usa os templates, o update usa o source via git diff. Se divergirem, o framework quebra.

```bash
# Exemplo: editou agents/security-audit.md
cp agents/security-audit.md skills/setup-framework/templates/agents/security-audit.md
```

## Posicao do framework-tag

Todo arquivo distribuido pro projeto deve ter um header `<!-- framework-tag: vX.Y.Z framework-file: {path} -->`. A posicao depende do tipo de arquivo:

| Tipo | Posicao | Motivo |
|---|---|---|
| Docs, templates de spec, indexes (sem frontmatter YAML) | **Linha 1** | Nada precede |
| Skills e agents (com frontmatter YAML `---`...`---`) | **Primeira linha apos o fechamento `---`** | Frontmatter precisa ficar no topo para ser parseado |

Arquivos skip (STATE.md, backlog.md) e arquivos internos do framework (CLAUDE.md, MANIFEST.md, CHANGELOG.md, README.md, VERSION) **nao levam** framework-tag.

Quando o `framework-tag` aparece dentro de blocos de codigo (exemplos, instrucoes), nao e considerado tag real — o `validate-tags.sh` ignora conteudo dentro de code fences.

## MANIFEST.md

E a fonte de verdade sobre o que vai pro projeto e com qual estrategia:
- **overwrite** — substitui direto (agents, templates de spec, plugin.json)
- **structural** — preserva conteudo customizado, adiciona/remove secoes (skills, docs)
- **manual** — mostra diff, nunca aplica sozinho (scripts, CLAUDE.md, PROJECT_CONTEXT.md)
- **skip** — nunca toca (backlog, specs do projeto, STATE.md)

Consultar o MANIFEST antes de adicionar qualquer arquivo novo ao framework.

## Arquivos que NAO vao pro projeto

| Arquivo | Proposito |
|---|---|
| `CLAUDE.md` (este) | Dev do framework |
| `README.md` | Documentacao do repo |
| `scripts/install-skills.sh` | Instalacao pessoal |
| `.claude-plugin/plugin.json` | Vai como overwrite (e do framework, nao do projeto) |

Documentados no MANIFEST na secao "Scripts do framework (nao copiados)".

## Conventional Commits (obrigatorio)

Todos os commits seguem Conventional Commits. O processo de release depende disso para detectar o bump correto.

| Prefixo | Quando | Bump |
|---|---|---|
| `feat:` | Funcionalidade nova (skill, agent, campo, secao) | minor |
| `fix:` | Correcao de bug ou instrucao errada | patch |
| `docs:` | Documentacao (README, SETUP_GUIDE, etc.) | patch |
| `refactor:` | Reestruturacao sem mudar comportamento | patch |
| `release:` | Commit gerado pelo processo de release | — |
| `feat!:` ou `BREAKING CHANGE` | Mudanca incompativel | major |

## Versionamento e release

Quando o usuario pedir para publicar, criar tag, fazer release, ou qualquer variacao disso — executar este processo automaticamente. Nao perguntar "quer que eu faca release?" — ja fazer. Mostrar a analise e o bump sugerido, e so pausar para confirmacao se houver ambiguidade real (ex: commit que pode ser minor ou major).

### 1. Validar pre-release

Antes de qualquer bump:

- **Working directory limpo?** Se nao, commitar ou pedir pro usuario decidir.
- **Source e templates em sincronia?** Comparar cada source com seu template (`diff source template`). Se divergirem, sincronizar e commitar antes.
- **MANIFEST atualizado?** Se adicionou/removeu arquivo desde a ultima release, verificar se o MANIFEST reflete isso.
- **CHANGELOG atualizado?** Adicionar entrada para a nova versao com commits agrupados por tipo (feat/fix/docs). Se `CHANGELOG.md` nao existe, criar.
- **Framework-tags consistentes?** Rodar `scripts/validate-tags.sh` (ou `grep -r "framework-tag:" --include="*.md"`) e confirmar que todos apontam para a mesma versao.

### 2. Determinar o bump

Ler os commits desde a ultima tag:
```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline --format="%s"
```

Analisar **semanticamente** (nao so por prefixo):
- Algum commit quebra compatibilidade com projetos que ja usam o framework? → **major**
- Algum commit adiciona funcionalidade nova (skill, agent, campo, secao de template)? → **minor**
- Todos os commits sao correcoes, ajustes de docs, refatoracao interna? → **patch**

Mostrar brevemente: commits, bump detectado, versao resultante. Se o bump for claro, aplicar direto. So pausar se houver duvida real entre niveis.

### 3. Aplicar o bump

1. **VERSION** — atualizar com a nova versao
2. **plugin.json** — atualizar campo `version`
3. **Framework-tags** — atualizar todos os `<!-- framework-tag: vX.Y.Z -->` nos .md:
   ```bash
   grep -rl "framework-tag: v" --include="*.md" . | xargs sed -i '' "s/framework-tag: v[0-9]*\.[0-9]*\.[0-9]*/framework-tag: vNOVA/g"
   ```
4. **Commit** com mensagem `release: vX.Y.Z`
5. **Tag** — `git tag vX.Y.Z`
6. **Push** — perguntar ao usuario antes de `git push && git push --tags`

### 4. Checklist pos-release

Verificar que tudo ficou consistente:

- [ ] `VERSION` contem a nova versao
- [ ] `plugin.json` contem a mesma versao
- [ ] `CHANGELOG.md` tem entrada para a nova versao
- [ ] `scripts/validate-tags.sh` passa sem erros
- [ ] Todos os sources estao sincronizados com templates (`diff source template`)
- [ ] Novo doc/skill/agent tem entrada no MANIFEST
- [ ] Tag criada (`git tag -l`)
- [ ] Testar em repo real: `./scripts/install-skills.sh` + `/setup-framework` funciona

## Fluxo de desenvolvimento

1. Criar worktree para a sessao
2. Fazer as mudancas nos sources
3. Sincronizar com templates — **sempre** copiar source → template correspondente
4. Atualizar MANIFEST se adicionou/removeu arquivo
5. Commitar com Conventional Commits
6. Merge na main
7. Release (processo acima)

## Regras

1. **Nunca editar so o template sem editar o source** (ou vice-versa). Sempre os dois.
2. **Nunca adicionar arquivo ao framework sem entrada completa no MANIFEST.** Cada entrada deve ter: path no projeto, template source, e estrategia (overwrite/structural/manual/skip). Se o arquivo vai para projetos, a copia em `skills/setup-framework/templates/` tambem e obrigatoria (vinculando com a regra 1).
3. **Testar mudancas num repo real** antes de publicar. Instalar via `install-skills.sh` e rodar `/setup-framework` ou `/update-framework` num repo de teste.
4. **Skills dual-mode (repo + Notion):** `/spec` e `/backlog-update` detectam `## Integracao Notion (specs)` no CLAUDE.md do projeto. Qualquer mudanca nessas skills precisa funcionar nos dois modos.
5. **Agents sao read-only.** Todos tem `worktree: false`. Se criar agent que edita codigo, marcar `worktree: true`.
6. **O framework nao configura MCP.** Setup/update apenas usam o MCP Notion se ja estiver configurado. Nunca pedir token ou configurar autenticacao.
7. **CLAUDE.md do projeto e intocavel por overwrite.** Sempre `manual` — mostrar diff, nunca aplicar sozinho.
8. **Agents definem `model:` no frontmatter.** Ao criar ou editar agent, escolher modelo pela complexidade:
   - `opus` — raciocinio profundo, consequencia real de erro (ex: security). Usar com parcimonia.
   - `sonnet` — checklists estruturados, analise com heuristicas claras. Default recomendado para novos agents.
   - `haiku` — leitura e formatacao sem julgamento complexo.
   Regra pratica: se o agent tem checklist com thresholds numericos → sonnet. Se precisa correlacionar findings ou julgar severidade → opus. Se so le e formata → haiku.
   Incluir `model-rationale:` no frontmatter com 1 frase justificando a escolha (ex: `model-rationale: checklist com thresholds numericos, sem julgamento subjetivo`). Isso garante rastreabilidade e facilita revisao.
9. **Skills devem ter exemplos concretos.** Toda skill deve conter pelo menos 1 exemplo concreto por bloco de codigo, alem dos placeholders `{Adaptar:...}`. Placeholders sozinhos nao sao suficientes — o exemplo concreto serve de referencia para quem customiza no projeto.
10. **Docs portaveis sincronizados com skills.** Quando editar `skills/prd-creator/SKILL.md` ou `prds/PRD_TEMPLATE.md`, verificar se `docs/PRD_PORTABLE_PROMPT.md` precisa da mesma mudanca. O doc portavel e a versao standalone do workflow da skill — metodologia, classificacao de complexidade, template de saida e regras devem refletir o que a skill faz. Aplicar a mesma logica para futuros docs portaveis de outras skills.
11. **Auditoria de completude em sincronia entre setup e update.** A secao "5b. Auditoria de completude" existe tanto no `setup-framework/SKILL.md` quanto no `update-framework/SKILL.md`. As 5 categorias de checks (arquivos, agents, skills, secoes do CLAUDE.md, integridade de conteudo) devem ser identicas entre ambos. Ao adicionar ou remover um check em um, aplicar no outro. A unica diferenca permitida e o update cruzar com a lista de arquivos recem-aplicados.

## Padrao para criar agents

Ao criar um novo agent, seguir este checklist:

1. **Frontmatter obrigatorio:** `description`, `model`, `worktree`, `model-rationale`
2. **Secoes obrigatorias:** "Quando usar", "Input", "O que verificar", "Output", "Regras"
3. **Severidade padrao no output:** 🔴 critico, 🟠 alto, 🟡 medio, ⚪ info
4. **Secao "Proximos passos"** linkando para skills relacionadas (ex: security-audit → security-review skill para correcao)
5. **Sincronizar** source + template (regra 1)
6. **MANIFEST** com entrada completa (regra 2)
7. **CLAUDE.template.md** — adicionar o agent ao mapeamento na secao "Agents"

## Padrao para criar skills

Ao criar uma nova skill, seguir este checklist:

1. **Arquivo:** `README.md` dentro do diretorio da skill (`skills/{nome}/README.md`)
2. **Header:** incluir `<!-- framework-tag: vX.Y.Z framework-file: skills/{nome}/README.md -->`
3. **Secoes obrigatorias:** "Quando usar", "Quando NAO usar", "Checklist" (com checkboxes), "Regras"
4. **Exemplos concretos** antes dos placeholders (regra 9)
5. **Dependencias:** se a skill depende de outra, documentar no topo (ex: "Rodar apos code-quality")
6. **Sincronizar** source + template (regra 1)
7. **MANIFEST** com entrada completa (regra 2)
8. **CLAUDE.template.md** — adicionar a skill ao mapeamento na secao "Skills"

## Notion (integracao nativa)

Skills `/spec` e `/backlog-update` suportam Notion via MCP. O setup detecta templates da database e gera a secao `## Integracao Notion (specs)` no CLAUDE.md do projeto.

Para testar: precisa de MCP Notion configurado no Claude Code com acesso a uma database de teste.

## Como testar

1. Clonar um repo de teste (ou criar um vazio)
2. Instalar skills: `./scripts/install-skills.sh`
3. No repo de teste: `/setup-framework` → verificar que tudo foi gerado
4. Fazer uma mudanca no framework, bumpar versao
5. No repo de teste: `/update-framework` → verificar que detecta diferenças e aplica corretamente
