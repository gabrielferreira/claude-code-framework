<!-- framework-tag: v2.49.3 framework-file: skills/update-framework/STRUCTURAL_MERGE_DETAILS.md -->
# Structural Merge Details — update-framework

> Receita mecanica de merge structural + filtros pre-aplicacao + verificacao pos-aplicacao.
> Carregado pelo SKILL.md quando ha arquivos com estrategia structural ou renames na lista de mudancas.

---

## 3.0 Filtros pre-aplicacao (ANTES de aplicar qualquer arquivo)

**Esta fase e OBRIGATORIA e deve ser executada ANTES de qualquer outra sub-fase (3.1, 3.2, etc.).**

### Passo 0 — Resolucao de templates por modo framework

Se `FRAMEWORK_MODE=light` (detectado na Fase 0.4):
- Para cada arquivo `structural` que precisa de merge: buscar template em `${FRAMEWORK_PATH}/../templates-light/{path}` primeiro. Se nao existe, usar `${FRAMEWORK_PATH}/{path}`.
- Isso garante que o merge usa o template correto (ex: CLAUDE.md light, spec-driven light) em vez de adicionar secoes full-only ao projeto light.
- Arquivos tier=`full` que nao existem no projeto: **skip silencioso** (ja filtrado na Fase 0.4).
- Arquivos tier=`full` que existem no projeto: atualizar normalmente usando template full (`${FRAMEWORK_PATH}/{path}`).

Se `FRAMEWORK_MODE=full`: usar apenas `${FRAMEWORK_PATH}/{path}` (comportamento atual).

> **Se Notion detectado:** ver `NOTION_UPDATE_DETAILS.md` para Passos 1-4 (detectar modo spec, remover arquivos locais, limpar CLAUDE.md refs, excluir da lista de aplicacao).

---

## 3.1b Aplicar renames

Antes do merge structural, aplicar renames declarados na secao "Renames" do MANIFEST. Renames sao arquivos que mudaram de path entre versoes (ex: `README.md` -> `SKILL.md` ao converter skill passiva em slash command).

Para cada rename cuja versao "Desde" > versao instalada no projeto:

1. **Se projeto tem o path antigo:**
   a. **Backup:** copiar arquivo antigo para `.claude/.update-backup/{tag}/{path-antigo}`
   b. **Ler** conteudo customizado do arquivo antigo
   c. **Merge structural** com o template do path novo:
      - Frontmatter YAML: usar do template (novo — nao existia no arquivo antigo)
      - Framework-tag: usar do template (atualizado)
      - Secoes H2/H3: mesmo algoritmo do 3.2 (preservar customizacoes do projeto, adicionar secoes novas do framework)
   d. **Salvar** resultado no path novo
   e. **Deletar** arquivo antigo
   f. **Informar** ao dev: "Renomeado: {antigo} -> {novo} (customizacoes preservadas)"

2. **Se projeto ja tem o path novo:** skip (ja migrado)
3. **Se nenhum dos dois existe:** tratar como arquivo novo (copiar template na Fase 3.4)

---

## 3.2 Aplicar structural — receita mecanica

> **REGRA CRITICA:** O merge structural NUNCA substitui conteudo customizado. Secoes existentes no projeto sao INTOCAVEIS. O merge so ADICIONA secoes novas e PERGUNTA sobre removidas.

Para cada arquivo `structural`, seguir esta receita:

### Passo 0 — Short-circuit

Comparar framework-tag do projeto com framework-tag do source:
- Se **iguais** -> SKIP (nada mudou neste arquivo). Atualizar tag e seguir pro proximo.
- Se **diferentes** -> continuar com merge.

**Economia:** em update tipico, ~80% dos arquivos structural nao mudaram entre versoes — short-circuit evita analise desnecessaria.

### Passo 1 — Backup

Copiar arquivo atual para `.claude/.update-backup/{tag}/{path}` ANTES de qualquer alteracao.

### Passo 2 — Extrair headers

```
Usar Grep no source: grep -n "^## \|^### " source.md -> lista_source[]
Usar Grep no projeto: grep -n "^## \|^### " projeto.md -> lista_projeto[]
```

Emitir ambos os Greps em paralelo (mesma mensagem).

### Passo 3 — Calcular diff de secoes

```
NOVAS     = headers em lista_source que NAO estao em lista_projeto
REMOVIDAS = headers em lista_projeto que NAO estao em lista_source
EXISTENTES = headers em ambas as listas
```

### Passo 4 — Aplicar

- **NOVAS:** extrair conteudo da secao do source (desde header ate proximo header de mesmo nivel ou superior) -> APPEND ao final do arquivo do projeto, na posicao equivalente. Se a secao nova e H3, inserir dentro do H2 correspondente.
- **REMOVIDAS:** perguntar ao usuario: "Secao '{nome}' foi removida do framework. Remover do seu projeto? [Sim/Nao]"
- **EXISTENTES:** NAO TOCAR. Conteudo do projeto e sagrado. Zero analise de conteudo, zero heuristica de customizacao.

### Passo 5 — Finalizar

1. Atualizar framework-tag na linha 1 para a nova versao
2. Verificar: todas as secoes que existiam no backup continuam existindo no resultado. Se alguma sumiu -> **reverter para backup** e reportar erro.
3. Registrar no relatorio: secoes adicionadas, secoes removidas (se usuario confirmou), secoes preservadas

---

## 3.2b Aplicar content patches (mudancas intra-secao)

Apos o merge structural, verificar se o migration desta versao contem **content patches** — mudancas de conteudo dentro de secoes existentes que o merge structural nao aplica automaticamente.

1. **Ler o migration** (`migrations/v{ANTERIOR}-to-v{NOVA}.md`) e localizar a secao "Content patches" (se existir)
2. **Para cada content patch:**
   - Identificar o arquivo e secao afetada
   - Verificar se o arquivo esta no projeto
   - Mostrar ao usuario: texto antigo -> texto novo + motivo da mudanca
   - Perguntar: "Aplicar esta mudanca? [S/n/ver diff]"
   - Se sim: aplicar a substituicao no arquivo do projeto
   - Se nao: registrar no relatorio como "patch nao aplicado — revisar manualmente"
3. **Se o migration nao tem content patches:** pular esta fase

> **Por que content patches existem:** o merge structural preserva conteudo customizado — isso e correto. Mas quando o framework muda uma regra, tabela ou instrucao DENTRO de uma secao existente (ex: reescreve a tabela de classificacao, torna TDD condicional), essa mudanca precisa ser surfaced manualmente. Content patches sao o mecanismo para isso.

---

## 3.5 Verificacao pos-aplicacao (OBRIGATORIA)

Apos aplicar TODOS os merges structural (Fase 3.2), rodar esta verificacao automatica antes de qualquer outra fase:

1. **Para cada arquivo structural que foi tocado:**
   - Ler o arquivo resultante
   - Ler o backup em `.claude/.update-backup/{tag}/{path}`
   - **Comparar secao por secao:**
     - Se uma secao no backup tinha conteudo customizado (libs reais, paths reais, exemplos adaptados) e a secao no resultado tem conteudo generico/placeholder -> **REGRESSAO DETECTADA**
   - **Indicadores de regressao:**
     - Backup tinha `elogger` -> resultado tem `console.log` ou `log.Printf`
     - Backup tinha `erros.Wrap` -> resultado tem `fmt.Errorf`
     - Backup tinha branches reais (main, release, sandbox) -> resultado tem `develop`, `feature/*`
     - Backup tinha framework de teste real (Vitest, Pytest) -> resultado tem `{Jest / Vitest}`
     - Backup tinha exemplos Go -> resultado tem exemplos JS/TS
     - Qualquer troca de linguagem de exemplos de codigo

2. **Se detectou regressao:**
   - **Restaurar o arquivo do backup** imediatamente: `cp backup resultado`
   - Avisar: "REGRESSAO DETECTADA em {arquivo}: secao {secao} teve conteudo customizado substituido por generico. Arquivo restaurado do backup. Secoes novas do framework NAO foram adicionadas."
   - Registrar no relatorio como "FALHA — merge revertido"
   - **Tentar novamente com merge mais conservador:** adicionar APENAS as secoes novas (que nao existiam no backup) sem tocar nas existentes

3. **Se nao detectou regressao:**
   - Registrar no relatorio como "OK — conteudo customizado preservado"

> **Por que isso existe:** em execucoes anteriores o update substituiu conteudo customizado (ex: elogger -> console.log, branches reais -> genericas). Esta verificacao e a ultima barreira de seguranca contra esse tipo de regressao.

---

## 3.6 Remover obsoletos

1. Confirmar com o usuario antes de cada remocao
2. Se o arquivo foi customizado pelo projeto (tem conteudo alem do template), avisar
3. Deletar o arquivo
