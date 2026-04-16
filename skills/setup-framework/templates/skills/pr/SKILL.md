---
name: pr
description: Preenche PR template com contexto de spec + diff e abre via gh pr create
user_invocable: true
---
<!-- framework-tag: v2.46.0 framework-file: skills/pr/SKILL.md -->

# /pr — Pull Request com contexto de spec

Preenche o template de PR com informacoes extraidas da spec e do diff da branch, e abre o PR via `gh pr create` apos confirmacao do usuario.

## Quando usar

- Ao concluir implementacao de uma spec e querer abrir PR
- Apos rodar definition-of-done e verify.sh com sucesso
- Quando quiser PR pre-preenchido com rastreabilidade spec -> PR

## Quando NAO usar

- Quick task sem spec — usar o fluxo normal de PR do Claude Code
- Branch sem commits (nada para abrir PR)
- Quando quiser fazer push direto (proibido pelo framework, mas a skill nao se aplica)

## Uso

```
/pr
/pr --base develop
/pr --draft
/pr --base develop --draft
```

Exemplos:
- `/pr` — detecta spec automaticamente, propoe PR para main
- `/pr --base develop` — PR para branch develop em vez de main
- `/pr --draft` — abre como draft PR

## Instrucoes

### Passo 0 — Validar pre-condicoes

1. **Branch atual nao e main/develop:**
   ```bash
   git branch --show-current
   ```
   Se for `main` ou `develop` → abortar: "Voce esta na branch principal. Crie uma branch de feature antes de abrir PR."

2. **Existem commits na branch:**
   ```bash
   git log main..HEAD --oneline
   ```
   Se vazio → abortar: "Nenhum commit na branch atual em relacao a main."

3. **Working directory limpo:**
   ```bash
   git status --porcelain
   ```
   Se tem mudancas nao commitadas → avisar: "Ha mudancas nao commitadas. Commitar antes de abrir PR? (sim/nao)"

4. **`gh` CLI disponivel:**
   ```bash
   gh --version
   ```
   Se nao encontrado → abortar: "GitHub CLI (`gh`) nao encontrado. Instalar: https://cli.github.com/"

5. **Autenticado no gh:**
   ```bash
   gh auth status
   ```
   Se nao autenticado → abortar: "Nao autenticado no GitHub CLI. Rodar `gh auth login`."

---

### Passo 1 — Coletar diff e commits

1. **Determinar base branch:**
   - Se `--base` fornecido → usar o valor
   - Senao → detectar branch principal: `main` ou `develop` (verificar qual existe)

2. **Coletar commits:**
   ```bash
   git log {base}..HEAD --oneline --format="%h %s"
   ```

3. **Coletar diff resumido:**
   ```bash
   git diff {base}..HEAD --stat
   ```

4. **Coletar diff completo** (para analise, nao para o PR):
   ```bash
   git diff {base}..HEAD
   ```

---

### Passo 2 — Localizar spec associada

Buscar a spec que esta sendo implementada, na seguinte ordem de prioridade:

1. **STATE.md** — ler `.claude/specs/STATE.md`, secao "Execucao ativa". Se tem spec em andamento, usar essa.

2. **Branch name** — extrair ID da branch (ex: `feat/AUTH-5-sso-login` → `AUTH-5`). Buscar em `SPECS_INDEX.md` ou `.claude/specs/` por match de ID.

3. **Spec mais recente na branch** — buscar arquivos `.claude/specs/*.md` modificados nos commits da branch:
   ```bash
   git diff {base}..HEAD --name-only -- '.claude/specs/*.md'
   ```

4. **Se nenhuma spec encontrada:**
   - Informar: "Nenhuma spec associada encontrada. O PR sera preenchido apenas com informacoes do diff."
   - Continuar sem spec (fallback para diff-only)

Se spec encontrada, ler o conteudo completo.

---

### Passo 3 — Detectar template de PR

1. **Verificar se `.github/pull_request_template.md` existe** no projeto
   - Se sim → ler o template e usar suas secoes como estrutura
   - Se nao → usar formato padrao de `docs/GIT_CONVENTIONS.md` (secao "Pull Requests"):

```markdown
## O que muda
{resumo}

## Por que
{contexto}

## Como testar
{passos}

## Checklist
- [ ] Testes passando
- [ ] Coverage nos modulos criticos
- [ ] Sem secrets no codigo
- [ ] Conventional commit no titulo
```

---

### Passo 4 — Gerar titulo do PR

Titulo segue Conventional Commits: `type(scope): descricao`

1. **Analisar commits da branch** — identificar o type predominante:
   - Maioria `feat:` → `feat`
   - Maioria `fix:` → `fix`
   - Misto → usar o type do commit mais significativo (feature > fix > refactor > docs > chore)

2. **Extrair scope** — da spec (dominio/modulo) ou dos arquivos modificados (diretorio mais frequente)

3. **Descricao** — resumo em 1 frase do que o PR entrega:
   - Se tem spec: usar titulo da spec
   - Se nao: sintetizar dos commits

4. **Formato final:** `type(scope): descricao em portugues` (max 72 caracteres)

Exemplo: `feat(auth): implementar login via SSO com SAML`

---

### Passo 5 — Preencher corpo do PR

Preencher cada secao do template (detectado ou fallback) com informacoes da spec e do diff:

#### Se tem spec

| Secao do template | Fonte |
|---|---|
| **O que muda** | Sintetizar dos Requisitos Funcionais da spec + resumo do diff (arquivos tocados, linhas adicionadas/removidas) |
| **Por que** | Secao "Contexto" da spec — motivacao e problema que resolve |
| **Como testar** | Derivar dos "Criterios de aceitacao" da spec — transformar cada criterio em passo de teste manual |
| **Checklist** | Manter items do template + adicionar items especificos da spec (ex: "Migration aplicada", "Env var configurada") |
| **Spec** | Link para a spec: `Spec: [{ID}](.claude/specs/{arquivo})` |

#### Se nao tem spec (diff-only)

| Secao do template | Fonte |
|---|---|
| **O que muda** | Sintetizar dos commits e do diff stat |
| **Por que** | Inferir dos commit messages (se seguem Conventional Commits, o contexto esta la) |
| **Como testar** | Listar arquivos de teste modificados/criados. Se nenhum → "Sem testes automatizados adicionados." |
| **Checklist** | Manter items padrao do template |

**Regras de preenchimento:**
- NUNCA inventar informacao que nao esta na spec ou no diff
- Se uma secao nao tem informacao suficiente, deixar `{A preencher — nao encontrei informacao na spec/diff}` em vez de inventar
- Manter formato markdown limpo e conciso
- Se a spec tem secao "Notas — Decisoes do /discuss", incluir resumo das decisoes no PR

---

### Passo 6 — Apresentar preview e confirmar

Mostrar ao usuario o PR completo antes de criar:

```
PR Preview:
─────────────────────────────────
Titulo: {titulo}
Base: {base branch}
Draft: {sim/nao}

Corpo:
{corpo completo do PR}
─────────────────────────────────

Opcoes:
1. Criar PR como esta
2. Editar titulo
3. Editar corpo (dizer o que mudar)
4. Cancelar
```

**NUNCA executar `gh pr create` sem confirmacao explicita.** Aguardar o usuario escolher opcao 1.

Se o usuario escolher editar (2 ou 3):
- Aplicar a edicao
- Mostrar preview atualizado
- Perguntar novamente

---

### Passo 7 — Criar o PR

1. **Push da branch** (se ainda nao foi feito):
   ```bash
   git push -u origin $(git branch --show-current)
   ```

2. **Criar PR via gh:**
   ```bash
   gh pr create --title "{titulo}" --base {base} --body "$(cat <<'EOF'
   {corpo}
   EOF
   )"
   ```
   Se `--draft` → adicionar flag `--draft`

3. **Informar resultado:**
   ```
   PR criado: {url}
   Titulo: {titulo}
   Base: {base} ← {branch}
   Status: {aberto|draft}
   ```

---

### Passo 8 — Pos-criacao

1. **Se a spec existe e tem status diferente de "concluida":**
   - Sugerir: "Quer atualizar o status da spec para 'em revisao'?" (se o projeto usa state machine de spec)

2. **Se STATE.md tem execucao ativa:**
   - Sugerir: "Quer atualizar STATE.md para refletir que o PR foi aberto?"

## Checklist

- [ ] Pre-condicoes validadas (branch, commits, working directory, gh CLI)
- [ ] Diff e commits coletados
- [ ] Spec localizada (ou modo diff-only ativado)
- [ ] Template de PR detectado (ou fallback para GIT_CONVENTIONS)
- [ ] Titulo gerado seguindo Conventional Commits
- [ ] Corpo preenchido com informacoes da spec e/ou diff
- [ ] Preview mostrado ao usuario
- [ ] Confirmacao explicita obtida antes de `gh pr create`
- [ ] PR criado com sucesso (URL informada)

## Regras

1. **NUNCA executar `gh pr create` sem confirmacao explicita.** Mostrar preview completo e aguardar.
2. **NUNCA inventar conteudo.** Se nao tem spec e o diff nao da informacao suficiente, deixar placeholder explicito.
3. **Titulo segue Conventional Commits.** Sempre `type(scope): descricao`.
4. **Spec e fonte primaria, diff e complementar.** Quando tem spec, ela domina o conteudo. Diff complementa com detalhes tecnicos.
5. **Template do projeto tem prioridade.** Se `.github/pull_request_template.md` existe, seguir suas secoes. Se nao, usar fallback de GIT_CONVENTIONS.md.
6. **Push so com confirmacao.** Se a branch ainda nao foi pushed, avisar antes de fazer push.
7. **Rastreabilidade.** Se tem spec, sempre incluir link no corpo do PR.
8. **Idioma.** Titulo e corpo em portugues (padrao do framework), a menos que o projeto tenha convencao diferente.
