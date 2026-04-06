---
name: bug-investigation
description: Guia investigacao estruturada de bugs para times N2/N3 antes de escalar para engenharia, com analise de causa raiz e evidencias completas
user_invocable: true
---
<!-- framework-tag: v2.13.1 framework-file: skills/bug-investigation/SKILL.md -->

# /bug-report — Investigacao estruturada de bugs

Guia times de suporte (N2/N3) numa investigacao profunda de bugs antes de escalar para engenharia. O objetivo e que o time de engenharia receba um pacote completo com: problema validado, causa raiz identificada, evidencias concretas, referencias da funcionalidade, comportamento esperado vs real, e passos de reproducao.

## Uso

```
/bug-report {ID} {Titulo}
```

Exemplos:
- `/bug-report BUG-042 Pagamento duplicado no checkout mobile`
- `/bug-report BUG-105 Timeout intermitente na API de relatorios`
- `/bug-report BUG-200 Filtro de busca ignora acentos --from PROJ-789` (preenche a partir de ticket)
- `/bug-report BUG-300 Login falha apos reset de senha --export` (gera relatorio para copiar)

## Instrucoes

### Passo 0 — Detectar modo

Verificar no `CLAUDE.md` do projeto:

1. **Flag `--export` presente?**
   - **Se sim:** modo export — gerar relatorio na conversa para copy-paste. Nao criar arquivo.
2. **Secao `## Integracao Notion (bugs)` ou database de bugs configurada?**
   - **Se sim:** modo Notion — criar pagina no Notion
3. **Nenhum dos anteriores:**
   - Modo repo — criar arquivo local

### Passo 0b — Resolver fonte externa (se `--from` fornecido)

Se o usuario passou `--from {referencia}`, resolver ANTES de iniciar:

1. **Identificar tipo de fonte:**
   - Issue key (PROJ-123): buscar no Jira via `getJiraIssue`
   - URL do Jira: extrair key, buscar via `getJiraIssue`
   - URL do Notion: buscar via `notion-fetch`
   - URL do Confluence: buscar via `getConfluencePage`

2. **Extrair informacoes:**
   - Titulo, descricao, ambiente, prioridade, reporter
   - Comentarios com relatos de usuarios (resumir)
   - Anexos/screenshots mencionados

3. **Usar como base** para pre-preencher o relatorio.

4. **Registrar referencia:** `> Fonte: [{tipo}]({url})`

---

### Modo Repo (relatorios locais)

1. **Validar ID:** verificar se ja existe relatorio com esse ID.

2. **Classificar severidade:**
   - **Critico** — dados corrompidos, perda financeira, sistema inacessivel, seguranca comprometida
   - **Alto** — funcionalidade core quebrada sem workaround, afeta muitos usuarios
   - **Medio** — funcionalidade quebrada com workaround, afeta parte dos usuarios
   - **Baixo** — inconveniencia, comportamento inesperado com impacto minimo

3. **Criar arquivo:** `.claude/bugs/{id-em-kebab-case}.md`

4. **Guiar investigacao (10 passos):**

   **REGRA CRITICA — Extrair antes de perguntar:**
   Antes de fazer qualquer pergunta, analisar TODA a informacao que o investigador ja forneceu (no comando, na mensagem inicial, ou via `--from`). Extrair e pre-preencher tudo que for possivel:
   - Sintoma, ambiente, passos de reproducao, evidencias, contexto, comportamento esperado/real
   - Se a mensagem inicial ja contem a resposta para um passo, **nao perguntar de novo** — confirmar o que foi extraido e avancar para o proximo passo que ainda tem lacuna
   - Apresentar um resumo do que foi extraido: "Extraí da sua mensagem: [sintoma], [ambiente], [evidencias]. Vou confirmar e aprofundar o que falta."

   Conduzir a investigacao fazendo **uma pergunta de cada vez** apenas para os passos que ainda tem lacuna. Esperar a resposta antes de avancar.

   ---

   #### Passo 1 — Sintoma reportado

   **Se ja fornecido na mensagem inicial:** confirmar o que foi extraido — "Entendi que o sintoma reportado e: '{sintoma extraido}'. Esta correto? Tem algo a mais?"

   **Se nao fornecido:** Pergunte: "Qual o bug reportado? O que o usuario/cliente disse que esta acontecendo?"

   Objetivo: capturar exatamente o que foi relatado, sem interpretar. Registrar as palavras do usuario/cliente.

   ---

   #### Passo 2 — Validacao do sintoma (CRITICO)

   **Nao aceitar o sintoma como o bug real.** O que o usuario reporta e frequentemente consequencia de algo mais profundo.

   **Aplicar teste de nivel:**
   Pergunte: "Esse sintoma ('{sintoma}') e o que o usuario ve. Mas o que esta causando isso? E possivel que o bug real esteja em outra camada?"

   Explorar:
   - O que o usuario ve → e consequencia de que?
   - Se corrigir apenas o sintoma, o problema pode reaparecer de outra forma?
   - Existe um padrao — outros bugs similares ja foram reportados? Pode ser o mesmo bug raiz?

   **Registrar:**
   - Sintoma original (relato do usuario)
   - Bug real identificado (se diferente do sintoma)
   - Relacao: `sintoma visivel` | `bug intermediario` | `bug raiz`

   ---

   #### Passo 3 — Comportamento esperado vs real

   **Se ja fornecido:** confirmar — "Entendi que o esperado era '{X}' e o que acontece e '{Y}'. Correto?"

   **Se nao fornecido ou incompleto:** Pergunte: "Qual o comportamento esperado (o que deveria acontecer)? E qual o comportamento real (o que acontece de fato)?"

   Objetivo: documentar a discrepancia de forma clara e testavel.

   **Complementar com:**
   - "Onde esta documentado o comportamento esperado? Spec, PRD, documentacao, ou expectativa implicita?"
   - Se nao ha documentacao → registrar como "comportamento esperado implicito (sem spec)"

   ---

   #### Passo 4 — Contexto da funcionalidade

   **Se ja fornecido:** confirmar — "O bug esta em '{modulo/tela}', no fluxo de '{fluxo}'. Correto? Tem dependencias que devo saber?"

   **Se nao fornecido:** Pergunte: "Qual funcionalidade/modulo/tela e afetada? Que fluxo do usuario leva ate esse ponto?"

   Objetivo: mapear exatamente ONDE o bug acontece no produto.

   **Coletar:**
   - Funcionalidade/modulo afetado
   - Fluxo do usuario (passo a passo ate chegar no bug)
   - Dependencias conhecidas (APIs, servicos, integrações)
   - Referencias: links para spec, PRD, documentacao tecnica, repositorio

   ---

   #### Passo 5 — Reproducao

   **Se passos ja fornecidos:** confirmar e complementar — "Voce mencionou os passos: {passos extraidos}. Falta algum detalhe? Pre-condicoes? Ambiente?"

   **Se nao fornecidos:** Pergunte: "Como reproduzir o bug? Quais passos exatos? Em que ambiente?"

   Objetivo: documentar passos de reproducao que engenharia pode seguir sem ambiguidade.

   **Estrutura obrigatoria:**
   1. Pre-condicoes (estado inicial, dados necessarios, permissoes)
   2. Passos numerados (1. Ir para X, 2. Clicar em Y, 3. Preencher Z com...)
   3. Resultado esperado
   4. Resultado real
   5. Frequencia: `sempre` | `intermitente (~X%)` | `uma vez`
   6. Ambiente: producao, staging, local? Browser/OS/versao?

   **Se nao conseguir reproduzir:**
   - Registrar tentativas feitas
   - Registrar ambiente onde tentou
   - Marcar como "Nao reproduzido — investigar com logs"

   ---

   #### Passo 6 — Evidencias

   **Se evidencias ja fornecidas (logs, screenshots, metricas na mensagem):** confirmar — "Voce ja trouxe estas evidencias: {lista}. Tem mais alguma? Logs com timestamp, metricas de monitoramento, relatos de outros usuarios?"

   **Se nao fornecidas:** Pergunte: "Que evidencias existem? Logs, screenshots, gravacoes, metricas, relatos de outros usuarios?"

   Objetivo: compilar todas as evidencias disponiveis.

   **Tipos de evidencia:**
   - Logs (com timestamp e request ID se possivel)
   - Screenshots/gravacoes de tela
   - Metricas (aumento de erros, queda de conversao, etc.)
   - Relatos de outros usuarios (quantos afetados, desde quando)
   - Dados de monitoramento (Grafana, Datadog, Sentry, etc.)

   ---

   #### Passo 7 — Porques encadeados (causa raiz do bug)

   **Para cada possivel causa**, conduzir cadeia de "por que?" com **minimo 3 niveis**:

   Pergunte: "Por que voce acha que esse bug acontece? Qual a causa mais provavel?"
   - Ao receber resposta: "E por que '{resposta}' acontece?"
   - Repetir ate chegar na causa raiz tecnica ou de processo

   **Apos encadear:**
   - Cruzar se a mesma causa raiz aparece em bugs anteriores
   - Identificar se e bug de codigo, de dados, de infra, de configuracao, ou de processo

   **Registrar cada cadeia:**
   ```
   ### Hipotese 1 — {titulo}
   1. Por que? → {resposta}
   2. Por que? → {resposta}
   3. Por que? → {resposta}
   **Causa raiz provavel:** {resumo}
   **Tipo:** codigo | dados | infra | config | processo
   ```

   ---

   #### Passo 8 — Mapa de impacto

   Sintetizar o impacto do bug:

   - **Usuarios afetados:** quantos? Que segmento? Todos ou condicao especifica?
   - **Impacto no negocio:** receita, reputacao, SLA, compliance?
   - **Blast radius:** afeta so essa funcionalidade ou tem efeito cascata?
   - **Workaround existe?** Se sim, qual? E aceitavel pro usuario?
   - **Desde quando?** Data/deploy/release que introduziu o bug (se identificavel)

   ---

   #### Passo 9 — Recomendacao para engenharia

   **Baseado na investigacao, recomendar:**

   Pergunte: "Com base no que investigamos, o que voce recomenda como solucao? Qual area do codigo/sistema provavelmente precisa de mudanca?"

   **Estrutura:**
   - Causa raiz mais provavel (resumo da analise)
   - Area do sistema afetada (modulo, servico, tabela, API)
   - Sugestao de correcao (o que mudar — nivel de produto, nao implementacao)
   - Riscos da correcao (o que pode quebrar, efeitos colaterais)
   - Sugestao de testes (como validar que o fix resolveu)

   ---

   #### Passo 10 — Calibracao de completude

   **Validar que o relatorio esta completo para engenharia:**

   | Criterio | Status |
   |----------|--------|
   | Engenharia consegue reproduzir so com este relatorio? | sim/nao |
   | Causa raiz tem evidencia (nao e so suposicao)? | sim/nao |
   | Comportamento esperado tem referencia (spec/doc)? | sim/nao |
   | Impacto esta quantificado (usuarios, negocio)? | sim/nao |
   | Recomendacao aponta area especifica do sistema? | sim/nao |

   **Se algum "nao":** voltar ao passo correspondente e completar.

   **Se o investigador nao tem a informacao:**
   - Marcar como `{PENDENTE — precisa de acesso a logs/metricas/codigo}`
   - Indicar quem pode fornecer

   ---

5. **Registrar** (se modo repo):
   - Criar arquivo em `.claude/bugs/{id}.md`
   - Se existe index de bugs, adicionar entrada

6. **Verificacao pos-criacao** (OBRIGATORIO):

   | Secao | Obrigatorio |
   |---|---|
   | Sintoma reportado | sim |
   | Validacao do sintoma | sim |
   | Comportamento esperado vs real | sim |
   | Contexto da funcionalidade | sim |
   | Reproducao (passos) | sim |
   | Evidencias | sim (>=1 evidencia concreta) |
   | Porques encadeados | sim (>=3 niveis, >=1 hipotese) |
   | Mapa de impacto | sim |
   | Recomendacao para engenharia | sim |
   | Calibracao de completude | sim (todos "sim" ou justificativa) |

7. **Informar o investigador:**
   - Path do relatorio
   - Severidade classificada
   - Causa raiz mais provavel
   - Resultado da calibracao: ✅ completo para engenharia | ⚠️ N itens pendentes
   - Proximo passo: "Envie este relatorio para o time de engenharia. Se houver spec/PRD relacionado, vincule."

---

### Modo Notion (bugs via MCP)

Mesma logica do modo repo, mas criar pagina no Notion:

1. **Ler configuracao** do CLAUDE.md (database de bugs)
2. **Conduzir investigacao** (mesmos 10 passos)
3. **Criar pagina** via `notion-create-pages` com conteudo completo
4. **Verificacao pos-criacao** via `notion-fetch`

---

### Modo Export (relatorio para copiar)

1. **Conduzir investigacao** (mesmos 10 passos)
2. **Gerar relatorio formatado** na conversa
3. **Informar:** "Relatorio gerado para copy-paste. Copie para o Jira, Slack, ou ferramenta do time."

---

## Regras

- **Nunca aceitar o sintoma como o bug real.** Sempre validar se o que foi reportado e sintoma, bug intermediario, ou bug raiz (passo 2)
- **Reproducao e obrigatoria.** Se nao conseguir reproduzir, registrar tentativas e marcar como "nao reproduzido"
- **Porques devem ter minimo 3 niveis.** "Porque o codigo esta errado" nao e causa raiz — aprofundar
- **Cada hipotese de causa deve ser tipificada:** codigo, dados, infra, config, ou processo
- **Comportamento esperado deve ter referencia.** Se nao tem spec/doc, registrar como "expectativa implicita"
- **O relatorio deve ser auto-suficiente.** Engenharia nao deveria precisar perguntar nada alem do que esta no relatorio
- **Nao misturar investigacao com solucao.** A recomendacao e de PRODUTO (o que resolver), nao de implementacao (como codificar)
- **Bugs recorrentes devem referenciar ocorrencias anteriores.** Se o mesmo bug ja foi reportado, linkar
- **Severidade deve ser justificada** com impacto concreto (usuarios afetados, receita, SLA)
- **Evidencias sem timestamp sao frageis.** Sempre registrar quando a evidencia foi coletada
