<!-- framework-tag: v2.48.1 framework-file: skills/execution-plan/README.md -->

# Execution Plan — Plano de execução obrigatório

Skill obrigatória para itens de complexidade média ou superior (3+ arquivos, 1h+). Plano escrito ANTES de sub-agents — plano mental não conta.

## Quando usar

- Item do backlog classificado como **Médio** (3-5 arquivos, 1-3h)
- Item classificado como **Grande** (6+ arquivos, >3h)
- Item classificado como **Complexo** (domínio novo, >20 tasks)
- **Batch de 2+ itens** que no total afetam 6+ arquivos ou 3+ domínios

## Quando NÃO usar

- Item **Pequeno** (≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova) — implementar direto
- Correção trivial de bug com causa óbvia e fix de 1-2 linhas

## Formato do plano

### 1. Escopo e contexto (2-3 frases)

O que vai ser feito, por que, e qual spec/item do backlog.

> Se existe `{id}-research.md` da fase research, referenciar os achados relevantes — especialmente patterns de reuso, riscos e decisões sugeridas. O research alimenta o escopo e as decisões do plan.

### 2. Mapa de arquivos

Listar **todos** os arquivos que serão lidos ou modificados, e a qual parte pertencem:

| Arquivo | Ação | Parte |
|---------|------|-------|
| `src/routes/auth.js` | Modificar | Parte 1 |
| `src/services/session.js` | Modificar | Parte 1 |
| `tests/auth.test.js` | Criar | Parte 1 |
| `src/components/LoginForm.jsx` | Modificar | Parte 2 |
| `tests/LoginForm.test.jsx` | Criar | Parte 2 |

### 3. Decomposição em partes

> Se a spec tem seção **"Grafo de dependências"**, usar como base para a decomposição. O grafo define dependências entre tasks — o execution-plan agrupa-as em **waves** respeitando essas dependências. O termo "wave" é usado tanto aqui quanto na skill context-fresh (despacho para sub-agents).

Para cada parte:

- **Escopo:** o que essa parte faz
- **Arquivos:** quais arquivos afeta (do mapa acima)
- **Funções/componentes:** o que criar/modificar
- **Não tocar:** o que NÃO modificar (previne overlap)
- **Sub-agent?** Sim/Não (se o projeto usa sub-agents) — se sim, o formato do briefing segue a skill context-fresh (`.claude/skills/context-fresh/README.md`)
- **Testes:** quais testes escrever (TDD se o projeto adota, senão testes junto com a implementação)
- **Dependências:** depende de outra parte? Qual? (usar coluna "Depende de" do grafo da spec se disponível)
- **Critério de "pronto":** como saber que esta parte está completa
- **Contratos:** se outra parte consome o output, definir interface/formato

### 4. Waves de execução

Derivar waves a partir do grafo de dependências da spec (ou da decomposição em partes):

- **Wave 1:** partes sem dependências
- **Wave 2:** partes cujas dependências estão todas na Wave 1
- **Wave N:** partes cujas dependências estão em waves anteriores
- Dentro de cada wave: partes sem overlap de arquivos podem rodar em **paralelo** (`[P]`)

```
Wave 1 (sequencial): Parte 1 — backend auth
Wave 2 (paralelo):   Parte 2 [P] + Parte 3 [P] — frontend + testes E2E (sem overlap)
Wave 3 (integração):  Verificar que partes se encaixam
```

Justificar paralelismo: "Parte 2 e 3 não compartilham arquivos" ou "Parte 2 depende de Parte 1".

> Se o projeto usa sub-agents, as waves do plan mapeiam diretamente para as waves de despacho da skill context-fresh.

### 5. Análise de overlap

> Se a spec tem grafo de dependências com coluna "Paralelizável?", usar como ponto de partida. Confirmar com a análise abaixo.

Para cada par de partes que rodam em paralelo, confirmar:

| Parte A | Parte B | Arquivos em comum? | Overlap? |
|---------|---------|-------------------|----------|
| Parte 2 | Parte 3 | Nenhum | ✅ Seguro |

**Regra:** se há overlap de arquivos entre partes paralelas → tornar sequencial ou redesenhar a decomposição.

### 6. Riscos e decisões

> Se a fase research foi executada, importar riscos de `{id}-research.md` e expandir/confirmar. Decisões sugeridas no research devem ser resolvidas aqui.

- Risco 1: {descrição} → Mitigação: {ação}
- Decisão 1: {escolha feita} → Motivo: {por quê}

### 7. Checklist pós-execução

- [ ] Todas as partes concluídas
- [ ] Testes passando (`{comando testes}`)
- [ ] Coverage atingido (`{comando coverage}`)
- [ ] verify.sh passando
- [ ] Spec verificada critério por critério
- [ ] STATE.md atualizado (se decisão arquitetural ou blocker surgiu)

## Regras

1. **Plano salvo em `.claude/specs/{id}-plan.md`** — obrigatório. O arquivo é o artefato que valida o gate `plan → execute`. Sem arquivo no disco, a fase plan não está concluída. O plan é descartável — deletado na fase done (após verificação contra a implementação).
2. **Máximo paralelismo com zero sobreposição.** Nunca duas partes editam o mesmo arquivo ao mesmo tempo.
3. **Plano pronto = implementar.** Seguir a ordem do plano, uma parte por vez. Se o projeto usa sub-agents: seguir protocolo de despacho da skill context-fresh (`.claude/skills/context-fresh/README.md`).
4. **Revisitar o plano se surgirem surpresas.** Se durante a implementação o escopo muda (arquivo extra, dependência não prevista) → atualizar o plano antes de continuar.

## Formato do arquivo

Salvar em `.claude/specs/{id}-plan.md`:

```markdown
# Execution Plan — {ID}

> Spec: {link ou path da spec}
> Data: YYYY-MM-DD
> Descartável: sim — deletado na fase done após verificação

## 1. Escopo e contexto
{conteúdo}

## 2. Mapa de arquivos
{tabela}

## 3. Decomposição em partes
{partes com critérios}

## 4. Waves de execução
{waves derivadas do grafo}

## 5. Análise de overlap
{tabela de overlap}

## 6. Riscos e decisões
{riscos e decisões}

## 7. Checklist pós-execução
{checklist}
```

## Checklist

- [ ] Escopo e contexto definidos
- [ ] Mapa de arquivos completo (todos os read + modify)
- [ ] Decomposição em partes com critérios de pronto
- [ ] Waves de execução derivadas do grafo de dependências
- [ ] Justificativa de paralelismo para waves com múltiplas partes
- [ ] Análise de overlap para partes paralelas
- [ ] Riscos identificados
- [ ] Checklist pós-execução definido
- [ ] **Plan salvo em `.claude/specs/{id}-plan.md`**
