# SW9 — SPECS_INDEX ativo

**Contexto:** SPECS_INDEX.md cresce linearmente com o número de specs do projeto. Skills como `spec-creator` e `spec-validator` leem o índice para encontrar specs existentes — em projetos com 30+ specs, isso consome contexto desnecessário a cada invocação, mesmo quando só 2-3 specs são relevantes. O problema se agrava com o tempo: quanto mais o projeto evolui, mais lento e caro fica o workflow de specs.

**Abordagem:** separar o índice em dois arquivos:

- **`SPECS_INDEX.md`** — apenas specs ativas: `rascunho`, `aprovada`, `em andamento`. Skills leem este arquivo normalmente.
- **`SPECS_INDEX_ARCHIVE.md`** — specs concluídas e canceladas. Skills só consultam quando precisam de histórico (ex: verificar se uma feature já foi implementada antes).

Quando uma spec transita para `concluída` (via spec-driven) ou `cancelada`, seu entry é movido de `SPECS_INDEX.md` para `SPECS_INDEX_ARCHIVE.md` — nunca deletado.

Ambos os arquivos mantêm o mesmo formato de tabela atual para consistência.

**Impacto no framework:**

| Arquivo | Mudança | Estratégia |
|---------|---------|-----------|
| `SPECS_INDEX.template.md` | Adicionar instrução: "este arquivo contém só specs ativas; concluídas ficam em SPECS_INDEX_ARCHIVE.md" | `⚠️ Migrável` |
| `SPECS_INDEX_ARCHIVE.template.md` | **Novo arquivo** — template para o arquivo de histórico (tabela vazia + instrução de não editar manualmente) | novo |
| `skills/spec-creator/SKILL.md` | Ao verificar duplicatas: checar SPECS_INDEX.md primeiro, SPECS_INDEX_ARCHIVE.md se necessário (ex: "essa feature já foi feita antes?") | `⚠️ Migrável` |
| `skills/spec-driven/README.md` | Ao marcar spec como concluída: mover entry de SPECS_INDEX.md → SPECS_INDEX_ARCHIVE.md | `⚠️ Migrável` |
| `skills/setup-framework/SKILL.md` | Criar SPECS_INDEX_ARCHIVE.md vazio no setup | `⚠️ Migrável` |
| `skills/update-framework/SKILL.md` | Checar presença de SPECS_INDEX_ARCHIVE.md; se ausente, informar para criar | `⚠️ Migrável` |
| `MANIFEST.md` | Adicionar `SPECS_INDEX_ARCHIVE.md` com estratégia `skip` | obrigatório |
| `skills/setup-framework/templates/*` | Espelhar todos os arquivos acima | sync obrigatório |

**Impacto em projetos downstream:**
- Projetos existentes têm SPECS_INDEX.md com specs concluídas — migração manual: criar SPECS_INDEX_ARCHIVE.md e mover as linhas concluídas
- Projetos que não migrarem continuam funcionando; só não ganham a otimização de contexto
- Notion mode não é afetado — specs são filtradas por status nativamente

**Critérios de aceitação:**
- [ ] `SPECS_INDEX.md` contém apenas specs com status `rascunho`, `aprovada` ou `em andamento`
- [ ] `SPECS_INDEX_ARCHIVE.md` existe e recebe specs ao serem concluídas
- [ ] spec-creator verifica duplicatas em ambos os arquivos (ativo primeiro, archive se necessário)
- [ ] spec-driven move o entry para o arquivo correto ao concluir ou cancelar uma spec
- [ ] setup-framework cria ambos os arquivos (SPECS_INDEX vazio + SPECS_INDEX_ARCHIVE vazio)
- [ ] update-framework detecta ausência de SPECS_INDEX_ARCHIVE.md e informa
- [ ] MANIFEST.md atualizado com SPECS_INDEX_ARCHIVE.md
- [ ] sources e templates em sincronia

**Restrições:**
- Nunca deletar entries — apenas mover entre os dois arquivos
- Notion mode: não alterar nada — o problema não existe lá
- Não fragmentar em mais de dois arquivos (ativo + archive) — complexidade não justifica
