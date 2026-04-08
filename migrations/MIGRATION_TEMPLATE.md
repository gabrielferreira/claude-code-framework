# Migration v{FROM} → v{TO}

> Data: {YYYY-MM-DD}
> Tipo: patch | minor | major

## Resumo

{1-3 frases descrevendo o que mudou nesta versao. Copiar do CHANGELOG.}

## Pre-requisitos

- Versao atual do projeto: v{FROM}
- Se estiver em versao anterior, aplique as migrations anteriores primeiro

## Mudancas

### 🔄 Overwrite (substituir arquivo inteiro)

> Estes arquivos nao tem customizacao de projeto — basta copiar do framework.

#### {numero}. `{path no projeto}`

**O que mudou:** {descricao da mudanca}

**Como aplicar:** Copiar `{path no framework source}` para `{path no projeto}`.

```bash
# Se tem o framework clonado:
cp {framework_path}/{source} {project_path}/{dest}
```

**Impacto se nao aplicar:** {o que deixa de funcionar ou fica desatualizado}

---

### 📝 Structural — secoes novas/removidas

> Estes arquivos tem conteudo customizado pelo projeto. Apenas secoes novas/removidas sao listadas.

#### {numero}. `{path no projeto}`

**Secoes adicionadas:**

Adicionar apos a secao `## {secao anterior}`:

```markdown
## {Nova secao}

{conteudo da secao}
```

**Secoes removidas:**

Remover a secao `## {secao obsoleta}` (substituida por {alternativa}).

**Impacto se nao aplicar:** {o que perde}

---

### 🔧 Content patches — mudancas dentro de secoes existentes

> O merge structural preserva conteudo customizado — NAO atualiza conteudo dentro de secoes existentes.
> Estas mudancas precisam ser aplicadas manualmente (ou aceitas via prompt do `/update-framework`).

#### {numero}. `{path no projeto}` — secao `{nome da secao}`

**Motivo:** {por que essa mudanca foi feita — ex: "tabela de classificacao reescrita para unificar criterios", "TDD tornada condicional para projetos sem testes"}

**Texto antigo** (encontrar e substituir):
```markdown
{trecho do texto antigo — suficiente para identificar unicamente}
```

**Texto novo:**
```markdown
{texto novo completo que deve substituir o antigo}
```

**Impacto se nao aplicar:** {consequencia — ex: "projeto continua com tabela desatualizada", "skills exigem TDD mesmo que o projeto nao use"}

---

### 👀 Manual (decisao humana)

> Estes arquivos sao altamente customizados. Revise o diff e decida o que aplicar.

#### {numero}. `{path no projeto}`

**O que mudou no template:**

```diff
{diff relevante — so as linhas que mudaram no template do framework}
```

**Sugestao:** {o que recomendamos aplicar e o que pode ignorar}

---

### 🆕 Arquivos novos

> Estes arquivos foram adicionados ao framework nesta versao.

#### {numero}. `{path no projeto}` (novo)

**O que e:** {descricao do arquivo — para que serve}

**Relevante se:** {condicao — ex: "projeto usa frontend", "projeto usa PRDs"}

**Como instalar:** Copiar `{path no framework}` para `{path no projeto}`.

```bash
cp {framework_path}/{source} {project_path}/{dest}
```

**Se decidir nao instalar:** {consequencia — geralmente nenhuma, e opcional}

---

### 🗑️ Arquivos removidos

> Estes arquivos foram removidos do framework.

#### {numero}. `{path no projeto}`

**Motivo:** {por que foi removido — ex: "substituido por X", "absorvido por Y"}

**Acao:** Remover o arquivo. {Se tinha substituto, referenciar o arquivo novo.}

---

## Framework-tags

Apos aplicar as mudancas, atualize os framework-tags nos arquivos tocados:

```bash
# Atualizar todos os framework-tags de v{FROM} para v{TO}
grep -rl "framework-tag: v{FROM}" --include="*.md" . | xargs sed -i 's/framework-tag: v{FROM}/framework-tag: v{TO}/g'
```

## Verificacao

Apos aplicar, verifique:

- [ ] Arquivos overwrite substituidos
- [ ] Secoes novas adicionadas nos arquivos structural
- [ ] Content patches aplicados (ou revisados e decididos)
- [ ] Arquivos manual revisados
- [ ] Arquivos novos instalados (os relevantes)
- [ ] Framework-tags atualizados para v{TO}
- [ ] `scripts/verify.sh` passa sem erros (se aplicavel)
