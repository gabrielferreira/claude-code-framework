# Auditorias do framework — padrões de falso positivo

> Carregar ao iniciar auditoria de "problemas não mapeados" no framework.
> Propósito: evitar que agents (ou eu mesmo) repitam achados que já foram investigados e descartados.

## Padrão geral

Agents de exploração especulam sem ler o **arquivo adjacente que explicaria o design intencional**. O achado parece sólido isoladamente e desmorona ao ler um segundo arquivo.

**Teste obrigatório antes de reportar qualquer achado:**

> "Existe **um segundo arquivo ou seção** onde esse comportamento poderia estar justificado ou referenciado? Se sim, li antes de afirmar que é bug?"

Se a resposta é "não li", o achado **não sai desta linha** até ler. Exemplos abaixo mostram os arquivos que invalidaram cada falso positivo.

## Falsos positivos já descartados (2026-04-16, auditoria Opus 4.7)

Não reabrir sem evidência nova e sem passar no teste do segundo arquivo.

| Achado | Por que não é bug | Segundo arquivo que invalidou |
|---|---|---|
| `scripts/verify.sh` não usa `set -e` (só `set -uo pipefail`) | Design intencional: script é **fail-aggregate**. Roda N checks via `pass()`/`fail()` e agrega num contador; `set -e` abortaria no primeiro `grep` sem match. Comparar com scripts fail-fast (`check-sync.sh`, `validate-tags.sh`, `validate-structure.sh`) não faz sentido — propósitos diferentes. | Próprio corpo de `scripts/verify.sh` (linhas 29-32, 60-75, 319-324) — as funções `pass`/`fail`/`warn` e uso com `grep ... \|\| echo "0"` mostram fail-soft intencional. |
| `check-sync.sh` não compara **conteúdo** de `templates-light/` com o full | Divergência entre light e full é **intencional por design** (skills reduzidas). `diff` mecânico sempre falharia. O bloco D valida o que faz sentido: versão da tag + marker `framework-mode: light`. Unificação é o caminho, não diff forçado — e já está endereçado por OP3. | `BACKLOG.md` (OP3 pendente); `scripts/check-sync.sh:208-246` (bloco D explícito sobre o que é validado e o que não é). |
| `docs/SKILLS_MAP.md` "esqueceu" tabela de agents | Escopo do doc é skills ([linha 2](../docs/SKILLS_MAP.md:2)). Agents vivem em `docs/WORKFLOW_DIAGRAM.md`. Menções incidentais (`debugger (agent)`, `component-audit (agent)`) são pontos onde skill complementa agent, não promessa de catálogo. | `docs/WORKFLOW_DIAGRAM.md` — tem a tabela de agents. Se um doc cobre, o outro não precisa cobrir. |
| STATE.md light quebra `/resume` | `/resume` tolera ausência de campos explicitamente (regra 1: "Nunca inventar estado — declarar lacuna e perguntar"). STATE.md full também não tem todos os campos que a skill menciona (ex.: "Log de transições", "Último checkpoint" só aparecem no texto da skill). Light cobre o essencial e a skill se adapta. | `skills/resume/SKILL.md` (regra 1 explícita + exemplo de resumo com "Incertezas: nenhuma"); `skills/setup-framework/templates/specs/STATE.md` (prova que "Log de transições" não está nem no full). |
| SPECS_INDEX.md ausente em light | Setup tem fallback explícito: se light não tem template para um path, **usa o full**. Seção 3.4 cria SPECS_INDEX.md em ambos os modos via esse fallback. | [skills/setup-framework/SKILL.md:104-105](../skills/setup-framework/SKILL.md:104) — fallback declarado na "Resolução de templates por modo". |
| `docs/VERIFY_HOOK.md` e `docs/PROTECT_BACKLOG_HOOK.md` órfãos | Ambos são referenciados em [docs/README.md](../docs/README.md) em duas tabelas. `VERIFY_HOOK.md` também aparece no README.md raiz. | `docs/README.md` — índice de docs com os hooks linkados. |

## Padrões recorrentes do falso positivo

Ao revisar futuras auditorias, desconfiar em especial quando o achado:

1. **Compara dois scripts como se devessem ser iguais** sem considerar que podem ter propósitos opostos (fail-fast vs fail-aggregate).
2. **Afirma que algo "falta" em um doc** sem checar doc adjacente que cobre o escopo.
3. **Assume que um template light deveria espelhar o full** quando a razão de existir do light é justamente divergir.
4. **Aponta "arquivo não referenciado"** sem rodar grep em `README.md` / `docs/README.md` / MANIFEST.
5. **Lê só o arquivo afetado** sem consultar o fluxo que o cria/consome (setup, update, skill chamadora).

## Como usar este doc

Ao rodar auditoria de "problemas não mapeados":

1. **Ler esta lista primeiro** — qualquer achado que bater com um dos descartes exige evidência **nova** (diferente da anterior) pra ser reportado.
2. **Aplicar o teste do segundo arquivo** antes de listar qualquer achado novo.
3. **Se o achado for novo e válido**, **ainda assim** registrar aqui o "segundo arquivo" que confirmou — pra que o próximo auditor saiba como validar.
4. Quando uma classe nova de falso positivo aparecer, adicionar à seção "Padrões recorrentes" acima.
