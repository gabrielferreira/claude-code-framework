# CLAUDE.md — claude-code-framework (desenvolvimento)

Este arquivo e para quem **desenvolve o framework**. NAO e copiado para projetos — projetos recebem o `CLAUDE.template.md` customizado pelo setup.

@.claude/TASK_CHECKLIST.md

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

## Posicao do framework-tag

Todo arquivo distribuido pro projeto deve ter um header `<!-- framework-tag: vX.Y.Z framework-file: {path} -->`. A posicao depende do tipo de arquivo:

| Tipo | Posicao | Motivo |
|---|---|---|
| Docs, templates de spec, indexes (sem frontmatter YAML) | **Linha 1** | Nada precede |
| Skills e agents (com frontmatter YAML `---`...`---`) | **Primeira linha apos o fechamento `---`** | Frontmatter precisa ficar no topo para ser parseado |

Arquivos **nao distribuidos** nao levam framework-tag. A regra geral: se o arquivo nao aparece no MANIFEST.md (ou aparece como `skip`), nao leva tag. Exemplos:

- Arquivos skip do projeto: `STATE.md`, `backlog.md`
- Arquivos internos do framework (repo-fonte): `CLAUDE.md`, `MANIFEST.md`, `CHANGELOG.md`, `README.md`, `VERSION`, `CONTRIBUTING.md`, `references/ECOSYSTEM.md`, `.claude/TASK_CHECKLIST.md`, `.claude/item-specs/*.md`

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
- **CHANGELOG atualizado?** Adicionar entrada para a nova versao com commits agrupados por tipo (feat/fix/docs), **incluindo apenas mudancas que chegam ao usuario final** (skills, agents, templates, docs distribuidos, scripts copiados para projetos). Omitir mudancas internas (BACKLOG, CONTRIBUTING, TASK_CHECKLIST, ECOSYSTEM, item-specs, CI, scripts de validacao do framework). Se `CHANGELOG.md` nao existe, criar.
- **Framework-tags consistentes?** Rodar `scripts/validate-tags.sh` (ou `grep -r "framework-tag:" --include="*.md"`) e confirmar que todos apontam para a mesma versao.

### 2. Determinar o bump

Ler os commits desde a ultima tag:
```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline --format="%s"
```

Analisar **semanticamente** (nao so por prefixo), **considerando apenas o que chega ao usuario final** (projetos que instalaram o framework):

- Algum commit muda skill, agent, template, doc ou script distribuido para projetos? → conta para o bump
- Commit afeta so arquivos internos do framework (BACKLOG.md, CONTRIBUTING.md, TASK_CHECKLIST.md, ECOSYSTEM.md, item-specs, CI, scripts de validacao)? → **nao conta para o bump**

Regras de bump:
- Algum commit chega ao usuario e quebra compatibilidade? → **major**
- Algum commit chega ao usuario e adiciona funcionalidade nova? → **minor**
- Todos os commits que chegam ao usuario sao correcoes ou ajustes? → **patch**
- So commits internos desde a ultima tag? → **sem release** (aguardar mudancas que cheguem ao usuario)

Mostrar brevemente: commits separados por "chega ao usuario" vs "interno", bump detectado, versao resultante. Se o bump for claro, aplicar direto. So pausar se houver duvida real entre niveis.

### 3. Aplicar o bump

1. **VERSION** — atualizar com a nova versao
2. **plugin.json** — atualizar campo `version`
3. **plugin.json template** — copiar para `skills/setup-framework/templates/.claude-plugin/plugin.json` (CI valida que ambos tem a mesma versao)
4. **Framework-tags** — atualizar todos os `<!-- framework-tag: vX.Y.Z -->` nos .md:
   ```bash
   grep -rl "framework-tag: v" --include="*.md" . | xargs sed -i '' "s/framework-tag: v[0-9]*\.[0-9]*\.[0-9]*/framework-tag: vNOVA/g"
   ```
5. **Sincronizar templates** — apos atualizar tags, copiar todos os sources afetados para templates (o sed so atualiza sources, nao templates). Rodar `bash scripts/check-sync.sh` para confirmar.
6. **Commit** com mensagem `release: vX.Y.Z`
7. **Tag** — `git tag vX.Y.Z`
8. **Push** — perguntar ao usuario antes de `git push && git push --tags`

### 4. Gerar migration

Apos o bump e antes do commit de release, gerar o arquivo de migration para esta versao. Migrations sao guias de atualizacao manual — como migrations de banco de dados, mas para o framework.

1. **Obter o diff entre a tag anterior e HEAD:**
   ```bash
   git diff ${TAG_ANTERIOR}..HEAD --name-status
   ```

2. **Classificar cada arquivo pelo MANIFEST** (overwrite/structural/manual/skip/new/removed)

3. **Gerar `migrations/v{ANTERIOR}-to-v{NOVA}.md`** usando o template `migrations/MIGRATION_TEMPLATE.md`:
   - Para cada arquivo **overwrite**: listar o path e descrever o que mudou (resumo do diff)
   - Para cada arquivo **structural**: listar secoes H2/H3 adicionadas ou removidas. **Alem disso**, identificar **mudancas de conteudo dentro de secoes existentes** (ex: tabela reescrita, regra adicionada, linguagem alterada). Para cada mudanca intra-secao significativa, incluir um bloco "content patch" com:
     - Arquivo e secao afetada
     - Texto antigo (resumo ou trecho)
     - Texto novo (completo)
     - Motivo da mudanca
     > **Importante:** o merge structural do update so adiciona/remove secoes — nao atualiza conteudo dentro de secoes existentes. Mudancas intra-secao precisam ser documentadas no migration para que o usuario aplique manualmente.
   - Para cada arquivo **manual**: incluir o diff relevante para o usuario decidir
   - Para cada arquivo **novo**: descrever o que e, para que serve, e quando e relevante
   - Para cada arquivo **removido**: explicar o motivo e apontar substituto
   - Agrupar por estrategia, na ordem: overwrite → structural (secoes novas) → structural (content patches) → manual → novos → removidos
   - Omitir secoes vazias (ex: se nao tem arquivos removidos, nao incluir a secao)

4. **Validar:** o migration deve ser auto-contido — alguem sem acesso ao Claude Code consegue ler e aplicar cada passo manualmente.

5. **Incluir o migration no commit de release** (mesmo commit que VERSION, plugin.json e framework-tags).

> **Nota:** migrations nao sao geradas retroativamente. A primeira migration sera criada na proxima release apos esta funcionalidade ser adicionada.

### 5. Checklist pos-release

Verificar que tudo ficou consistente:

- [ ] `VERSION` contem a nova versao
- [ ] `plugin.json` contem a mesma versao
- [ ] `CHANGELOG.md` tem entrada para a nova versao
- [ ] `migrations/v{ANTERIOR}-to-v{NOVA}.md` existe e esta completo
- [ ] `scripts/validate-tags.sh` passa sem erros
- [ ] Todos os sources estao sincronizados com templates (`diff source template`)
- [ ] Novo doc/skill/agent tem entrada no MANIFEST
- [ ] Tag criada (`git tag -l`)
- [ ] Testar em repo real: `./scripts/install-skills.sh` + `/setup-framework` funciona

## Fluxo de desenvolvimento

**Regra de branch:** nunca commitar diretamente na main. Todo trabalho acontece em branch separada e entra via Pull Request revisado.

1. Criar branch a partir da main: `git checkout -b feat/nome-da-feature` (ou `fix/`, `docs/`, etc.)
2. Criar worktree para a sessao se preferir isolamento: `git worktree add ../worktree-nome branch`
3. Fazer as mudancas nos sources (sources + templates em sincronia — ver TASK_CHECKLIST.md item 1)
4. Atualizar MANIFEST se adicionou/removeu arquivo (ver TASK_CHECKLIST.md item 2)
5. Antes do PR, perguntar ao usuario se quer rodar as validacoes localmente:
   ```bash
   bash scripts/validate-tags.sh && bash scripts/check-sync.sh && bash scripts/test-setup.sh
   ```
   Os tres scripts rodam automaticamente no CI (GitHub Actions) em todo push/PR na main, mas rodar antes localmente evita feedback loop lento.
6. Commitar com Conventional Commits e abrir Pull Request para main
7. Aguardar CI passar e revisao antes de mergear
8. Release (processo acima) — feito na main apos merge

## Regras

> Para a checklist completa de verificação durante execução de tarefas, ver `@.claude/TASK_CHECKLIST.md` (carregado automaticamente).

1. **Testar mudancas num repo real** antes de publicar. Instalar via `install-skills.sh` e rodar `/setup-framework` ou `/update-framework` num repo de teste.
2. **Agents sao read-only.** Todos tem `worktree: false`. Se criar agent que edita codigo, marcar `worktree: true`.
3. **O framework nao configura MCP.** Setup/update apenas usam o MCP Notion se ja estiver configurado. Nunca pedir token ou configurar autenticacao.
4. **CLAUDE.md do projeto e intocavel por overwrite.** Sempre `manual` — mostrar diff, nunca aplicar sozinho.
5. **Agents definem `model:` no frontmatter.** Ao criar ou editar agent, escolher modelo pela complexidade:
   - `opus` — raciocinio profundo, consequencia real de erro (ex: security). Usar com parcimonia.
   - `sonnet` — checklists estruturados, analise com heuristicas claras. Default recomendado para novos agents.
   - `haiku` — leitura e formatacao sem julgamento complexo.
   Regra pratica: se o agent tem checklist com thresholds numericos → sonnet. Se precisa correlacionar findings ou julgar severidade → opus. Se so le e formata → haiku.
   Incluir `model-rationale:` no frontmatter com 1 frase justificando a escolha (ex: `model-rationale: checklist com thresholds numericos, sem julgamento subjetivo`). Isso garante rastreabilidade e facilita revisao.
6. **Skills devem ter exemplos concretos.** Toda skill deve conter pelo menos 1 exemplo concreto por bloco de codigo, alem dos placeholders `{Adaptar:...}`. Placeholders sozinhos nao sao suficientes — o exemplo concreto serve de referencia para quem customiza no projeto.
7. **Docs portaveis sincronizados com skills.** Quando editar `skills/prd-creator/SKILL.md` ou `prds/PRD_TEMPLATE.md`, verificar se `docs/PRD_PORTABLE_PROMPT.md` precisa da mesma mudanca. O doc portavel e a versao standalone do workflow da skill — metodologia, classificacao de complexidade, template de saida e regras devem refletir o que a skill faz. Aplicar a mesma logica para futuros docs portaveis de outras skills.

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

## Gestao do BACKLOG.md

O `BACKLOG.md` e o roadmap do framework. Deve ser auto-contido — qualquer sessao nova consegue ler e saber o que fazer sem perguntar.

### Estrutura obrigatoria

O arquivo tem **7 secoes fixas**, nesta ordem:

1. **Pendentes** — tabelas por fase, com colunas: `ID | Item | Sev. | Impacto | Superfície | Destino | Compat. | Tipo | Est. | Deps | Origem`
2. **Concluidos** — tabela com `ID | Item | Concluido em`
3. **Descartados** — tabela com `ID | Item | Descartado em | Motivo` — nunca deletar, mover aqui com motivo
4. **Sugestao de execucao** — itens pendentes organizados em waves por impacto e interdependencia. Prioridade: Wave 1 (muda fluxo/template/spec) antes de Wave 2+ (isolados, automacao, infra)
5. **Decisoes futuras** — parking lot estrategico com gatilho e recomendacao
6. **Detalhes por item** — indice com links para `.claude/item-specs/{ID}.md` (ver secao abaixo)
7. **Legenda** — referencia de colunas, valores e distincao Fase vs Wave

### Estrutura de Fase vs Wave

- **Fase** = agrupamento tematico (por area de feature: Context Engineering, Autonomia, Skills novos, etc.). Agrupa itens por dominio, nao define ordem de execucao.
- **Wave** (secao "Sugestao de execucao") = ordem de prioridade de implementacao. Wave 1 primeiro porque muda artefatos que outros itens consomem. Um item de Fase 3 pode estar na Wave 1 se for bloqueador; um item de Fase 1 pode estar na Wave 4 se for isolado.

### Ao adicionar item novo

1. Classificar com todas as colunas (Sev, Impacto, Superficie, Destino, Compat., Tipo, Est, Deps, Origem)
2. Colocar na fase tematica correta (Fase 1-4, Testes, Operacoes)
3. **Classificar Superficie:**
   - `🔺 Fluxo` — muda artefato, template, skill ou fluxo que o dev toca no dia a dia (template de spec, gate, ordem de execucao, formato de arquivo)
   - `⬜ Bastidor` — roda por baixo sem mudar como o dev trabalha (automacao, tooling, CI, instalacao, agents novos independentes)
4. **Classificar Destino:**
   - `🏠 Framework` — beneficia o desenvolvimento/manutencao do proprio framework (CI, scripts, testes internos, processo de release)
   - `📦 Projeto` — beneficia quem instala e usa o framework num projeto real (skills, agents, templates, fluxos, instalacao)
5. **Classificar Compat.** — impacto de atualizacao para projetos downstream (quem ja usa o framework):
   - `✅ Aditivo` — adiciona capacidade nova sem tocar artefatos existentes (novo skill, agent, doc). Projeto desatualizado continua funcionando igual; projeto atualizado ganha a feature. Zero interferencia entre branch desatualizada e atualizada.
   - `⚠️ Migravel` — muda formato ou comportamento de artefatos existentes, mas com caminho de migracao (update-framework guia ou aplica via structural merge). Projeto que nao atualizar fica com versao antiga funcional, mas divergente.
   - `❌ Breaking` — quebra artefatos ou fluxo existente sem intervencao manual. Projeto que nao atualizar tera inconsistencia ou erros. Exige migration guide explicito no release.
6. **Atualizar a secao "Sugestao de execucao":** posicionar o item na wave adequada:
   - `🔺 Fluxo`? → Wave 1 ou 2 (fazer primeiro — muda artefatos que outros itens consomem)
   - `⬜ Bastidor`? → Wave 3+ (pode rodar em paralelo)
6. Se o item tem deps, documentar na coluna Deps e na secao de interdependencias

### Ao concluir item

1. Remover da tabela de Pendentes
2. Adicionar na tabela de Concluidos com versao e data
3. Remover da secao "Sugestao de execucao"
4. Atualizar deps de outros itens que dependiam deste (adicionar ✅)

### Ao descartar item

Nao deletar — mover para a secao "Descartados" com motivo explicito. Isso evita reabrir a mesma discussao no futuro.

1. Riscar o nome do item (~~texto~~)
2. Registrar data e motivo objetivo (ex: "conflita com filosofia X", "fora do escopo", "CE3 ja resolve")
3. Remover da tabela de Pendentes e da "Sugestao de execucao"
4. Atualizar deps de outros itens que dependiam deste

**Criterios para descartar** (nao e exaustivo):
- Conflita com a filosofia core do framework (markdown-first, revisao humana, escopo de specs)
- Ja resolvido por outro item concluido
- Fora do escopo: feature de produto diferente, nao de framework de specs
- Beneficio nao justifica complexidade para o publico-alvo atual

### Detalhes por item

Cada item com spec detalhada tem um arquivo dedicado em `.claude/item-specs/{ID}.md`. Ler antes de implementar.

**Formato obrigatorio:**

```markdown
# {ID} — {Titulo curto}

**Contexto:** por que este item existe e que problema resolve.
**Abordagem:** decisao tomada sobre como implementar. Incluir alternativas descartadas se relevante.
**Criterios de aceitacao:**
- [ ] criterio 1 — verificavel
- [ ] criterio 2

**Restricoes:** o que NAO fazer, dependencias, gates.
```

**Quando criar:** apos qualquer conversa de refinamento que produza decisoes nao obvias. Nao e necessario para itens triviais com descricao auto-explicativa.

**Quando atualizar:** sempre que uma decisao for tomada ou revisada. O arquivo deve refletir o estado atual do entendimento, nao o historico da conversa.

**Ao concluir item:** mover o arquivo para `.claude/item-specs/done/{ID}.md` — nao deletar. O arquivo serve de referencia historica para decisoes tomadas.

**Ao descartar item:** deletar o arquivo (o contexto fica no commit).

### Ao iniciar sessao de desenvolvimento do framework

Ler o BACKLOG.md — especialmente a secao "Sugestao de execucao" e `## Detalhes por item` — para saber o proximo item a implementar. Para itens com spec detalhada, ler `.claude/item-specs/{ID}.md` antes de comecar. Nao perguntar "o que fazer?" se o backlog ja tem a resposta.

## Notion (integracao nativa)

Skills `/spec` e `/backlog-update` suportam Notion via MCP. O setup detecta templates da database e gera a secao `## Integracao Notion (specs)` no CLAUDE.md do projeto.

Para testar: precisa de MCP Notion configurado no Claude Code com acesso a uma database de teste.

## Como testar

1. Clonar um repo de teste (ou criar um vazio)
2. Instalar skills: `./scripts/install-skills.sh`
3. No repo de teste: `/setup-framework` → verificar que tudo foi gerado
4. Fazer uma mudanca no framework, bumpar versao
5. No repo de teste: `/update-framework` → verificar que detecta diferenças e aplica corretamente
