<!-- framework-tag: v2.46.0 framework-file: docs/SPEC_DRIVEN_GUIDE.md -->
# Spec-Driven Development com AI: a prática do SPECS_INDEX

> **Contexto no harness:** spec-driven e a camada de *conhecimento* do harness engineering framework. Define *o que* o Claude Code vai implementar e *por que*. As outras camadas — skills (expertise), agents (automacao), orquestracao, verificacao e continuidade — governam *como* ele opera. Este guia foca na camada de conhecimento.

## O problema

Ferramentas de AI coding (Claude Code, Cursor, Copilot) operam sobre o contexto disponível no filesystem local. Quando um repositório cresce, a base de especificações cresce junto — e o modelo enfrenta um dilema: ou lê tudo (estourando context window e consumindo tokens), ou não lê nada (e implementa sem entender os requisitos).

Na prática, o comportamento padrão do modelo é ambicioso: ele tenta ler todos os arquivos que parecem relevantes. Em um repo com 40 specs, isso significa carregar milhares de linhas de requisitos no contexto antes de escrever a primeira linha de código. O resultado é consumo desnecessário de tokens, respostas mais lentas e, paradoxalmente, menor precisão — porque o modelo se perde em informação que não é relevante para a tarefa.

## A solução: índice leve + busca sob demanda

O `SPECS_INDEX.md` é um arquivo único na raiz do repositório que funciona como catálogo das especificações. Ele contém apenas metadados e resumos curtos — nunca o conteúdo completo das specs. O modelo lê o índice (dezenas de linhas), identifica qual spec é relevante, e só então abre o arquivo completo.

O padrão tem três componentes:

```
SPECS_INDEX.md    →  catálogo leve (~50-100 linhas), vive na raiz do repo
specs/            →  specs completas (locais, submodule, ou fonte externa)
CLAUDE.md         →  instrução para o modelo consultar o índice primeiro
```

Os templates prontos para copiar estão organizados por tipo de setup. Use A se as specs ficam no repo (ou submodule), ou B se ficam no Notion:

- **Apêndice A — Setup com specs locais no repo (template do índice + trecho do CLAUDE.md)**

    Este apêndice contém os dois artefatos necessários para configurar o padrão SPECS_INDEX quando as specs são arquivos Markdown no próprio repositório (ou via submodule). Copie cada seção para o arquivo correspondente no seu projeto.

    **1. Template do SPECS_INDEX.md**

    Copie para a raiz do repositório como `SPECS_INDEX.md`.

    ```markdown
    # SPECS_INDEX

    > Índice de especificações do projeto. Consulte este arquivo PRIMEIRO para localizar a spec relevante antes de implementar qualquer feature.
    >
    > **Regra:** Não leia specs inteiras sem necessidade. Use este índice para identificar o arquivo correto, depois abra apenas a seção necessária.

    ---

    ## Como usar este índice

    | Campo        | Descrição                                                        |
    |--------------|------------------------------------------------------------------|
    | **Domínio**  | Área funcional do sistema                                        |
    | **ID**       | Identificador único da spec (pode ser o ID do tracker: AUTH-100, BILL-210, etc.) |
    | **Spec**     | Caminho relativo ao arquivo de especificação                     |
    | **Status**   | `rascunho` · `aprovada` · `em andamento` · `concluída` · `descontinuada`   |
    | **Owner**    | Responsável pela spec — opcional (PM ou tech lead)               |
    | **Resumo**   | 1-2 frases sobre o que a spec cobre (suficiente para decidir se precisa abrir o arquivo) |

    ---

    ## Autenticação & Autorização

    | ID | Spec | Status | Owner | Resumo |
    |-----|------|--------|-------|--------|
    | AUTH-100 | `specs/auth/login-flow.md` | aprovada | @ana | Fluxo de login com email/senha e OAuth (Google, GitHub). Inclui refresh token rotation e session management. |
    | AUTH-120 | `specs/auth/rbac.md` | em andamento | @ana | Modelo de permissões role-based. Define roles (admin, editor, viewer), hierarquia e regras de herança. |
    | AUTH-140 | `specs/auth/mfa.md` | rascunho | @carlos | MFA via TOTP e SMS. Recovery codes e fluxo de fallback. |

    ## Billing & Pagamentos

    | ID | Spec | Status | Owner | Resumo |
    |-----|------|--------|-------|--------|
    | BILL-200 | `specs/billing/subscription-plans.md` | aprovada | @maria | Definição dos planos (free, pro, enterprise). Limites, features por tier, trial period. |
    | BILL-210 | `specs/billing/checkout-flow.md` | aprovada | @maria | Fluxo de checkout com Stripe. Inclui cupons, prorating em upgrade/downgrade, e tratamento de falha de pagamento. |
    | BILL-220 | `specs/billing/invoicing.md` | rascunho | @maria | Geração de invoices, nota fiscal, e integração com ERP. |

    <!-- Adicione mais domínios conforme necessário -->

    ---

    ## Dependências entre specs

    | Spec | Depende de | Motivo (1 frase) |
    |------|-----------|------------------|
    | Checkout Flow | Subscription Plans | Precisa dos planos e limites por tier para calcular valor |
    | Checkout Flow | Login Flow | Sessão autenticada obrigatória para iniciar checkout |

    ---

    ## Convenções das specs

    Cada arquivo de spec segue esta estrutura:

    # [Nome da Feature]

    ## Contexto
    Por que essa feature existe e qual problema resolve.

    ## Dependências
    Quais specs esta spec depende, o que usa de cada uma, e qual seção consultar.

    ## Escopo
    O que está dentro desta spec.

    ## Não fazer
    O que está explicitamente fora do escopo. Listar com referência à spec futura quando aplicável.

    ## Requisitos Funcionais
    Lista numerada (RF-001, RF-002...) dos requisitos.

    ## Requisitos Não-Funcionais
    Performance, segurança, escalabilidade.

    ## Data Model
    Entidades, campos, relações. Pode incluir diagrama Mermaid.

    ## API Contract
    Endpoints, request/response examples, error codes.

    ## Edge Cases
    Cenários de borda documentados explicitamente.

    ## Critérios de aceitação
    Condições verificáveis para considerar a spec implementada. Cada critério deve ser mapeável para um teste.

    ## Breakdown de tasks
    Obrigatório para features grandes ou complexas. Formato por task:
    - **O que:** 1 frase
    - **Onde:** path do arquivo
    - **Depende de:** task anterior ou —
    - **Reutiliza:** módulo/padrão existente ou —
    - **Pronto quando:** critério testável (referenciar RF-XXX)
    Tasks paralelizáveis marcadas com `[P]` podem rodar em sub-agents simultâneos.

    ## Decisões de Design
    ADRs (Architecture Decision Records) relevantes, com justificativa.

    ## Referências
    Links para docs externos, RFCs, ou specs relacionadas neste índice.

    ---

    ## Manutenção deste índice

    - **Ao criar nova spec:** adicione entrada aqui no domínio correto antes de mergear.
    - **Ao adicionar dependência:** atualize a tabela "Dependências entre specs" E a seção "Dependências" dentro da spec.
    - **Ao mudar status:** atualize a coluna Status (ex: `rascunho` → `aprovada`).
    - **Ao deprecar:** mude status para `descontinuada` e adicione nota sobre a spec substituta.
    - **Ao renomear/mover:** atualize o caminho na coluna Spec.
    ```

    **2. Trecho para o CLAUDE.md**

    Copie para o `CLAUDE.md` do repositório (ou adicione ao existente).

    ```markdown
    ## Specs e Requisitos

    Antes de implementar qualquer feature ou corrigir comportamento de negócio:

    1. Consulte `SPECS_INDEX.md` na raiz do projeto para localizar a spec relevante ao domínio.
    2. Abra APENAS a spec identificada no índice. Não leia todas as specs.
    3. Dentro da spec, leia a seção "Não fazer" ANTES de começar. Se algo que você planejava fazer está listado ali, NÃO faça.
    4. Foque na seção relevante (ex: se é um endpoint novo, leia "API Contract" e "Edge Cases").
    5. Classifique complexidade ANTES de começar (ver tabela de auto-sizing abaixo).
    6. Se a spec tem status `rascunho`, pergunte antes de implementar — pode estar incompleta.
    7. Se a spec tem status `descontinuada`, NÃO implemente. Verifique qual spec a substituiu.
    8. Ao criar spec nova: adicione entrada no SPECS_INDEX.md no domínio correto.
    9. Dependências entre specs: consulte a seção "Dependências entre specs" no final do SPECS_INDEX.md. Limite: máximo 2 specs dependentes por tarefa.
    10. Validação pré-implementação: após ler a spec e ANTES de escrever código, abra cada arquivo/função mencionados na spec. Confirme que existem e se comportam como a spec assume. Se algo mudou, PARE e reporte: "A spec assume X, mas o código atual mostra Y".

    ### Auto-sizing — classificar complexidade

    | Tamanho | Critério | O que criar | Fluxo |
    |---|---|---|---|
    | **Pequeno** | ≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova | Spec light (contexto + critério mínimo) | Backlog → spec → implementa → testa → commit |
    | **Médio** | <10 tasks, escopo claro, sem decisão arquitetural | Spec breve (contexto + requisitos + critérios) | Backlog → spec → execution-plan → implementa → commit |
    | **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) | Backlog → research (recomendado) → spec → design → execution-plan → implementa → commit |
    | **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com [P] + STATE.md | Fluxo RPI (skill research) → spec → design → execution-plan → implementa → commit |

    > Toda mudança tem spec. A complexidade determina o nível de detalhe, não se a spec existe. Se o projeto usa sub-agents, a implementação de Médio+ é delegada após o execution-plan.

    Na dúvida, classificar para cima (Médio vira Grande). Se ao listar tasks aparecem >5 steps ou dependências complexas, reclassificar como Grande.

    ### Context budget

    Manter sessões de implementação abaixo de ~60-70% do context window do modelo em uso.

    | Modelo | Context window | Budget seguro (~60-70%) |
    |---|---|---|
    | Opus 4.6 (1M) | 1M tokens | ~600-700k |
    | Opus 4.6 (200k) | 200k tokens | ~120-140k |
    | Sonnet 4.6 | 200k tokens | ~120-140k |
    | Haiku 4.5 | 200k tokens | ~120-140k |

    > Os context windows mudam entre versões dos modelos e um mesmo modelo pode ter variantes com janelas diferentes. Verificar a documentação do modelo e a variante contratada.

    - Pequeno/Médio: cabe numa sessão só
    - Grande: considerar 1 sessão por grupo de tasks
    - Complexo: 1 sessão por fase (research, plan, implement) + sub-sessões por wave de tasks [P]

    ### Caminho das specs
    - Specs locais: `./specs/` (submodule ou pasta sincronizada)
    - Estrutura: `specs/{domínio}/{feature}.md`

    ### Validação pré-implementação

    Após ler a spec e antes de escrever qualquer código:

    1. Abra cada arquivo, função ou tabela mencionados na spec.
    2. Confirme que existem e se comportam como a spec assume.
    3. Se algo mudou (renomeado, movido, removido, comportamento diferente), PARE e reporte: "A spec assume X, mas o código atual mostra Y".
    4. Aguarde decisão do SWE antes de prosseguir.

    ### Dependências entre specs

    Após identificar a spec primária no SPECS_INDEX:

    1. Consulte a seção "Dependências entre specs" no final do índice.
    2. Se a spec primária tem dependências listadas, avalie se são relevantes para a tarefa atual (use o motivo como filtro).
    3. Se relevante, abra a spec dependente e leia APENAS a seção indicada na coluna "Seção relevante" dentro da spec primária.
    4. Limite: máximo de 2 specs dependentes por tarefa. Se precisar de mais, pare e pergunte — pode ser sinal de escopo grande demais.
    5. Se detectar dependência circular, carregue apenas a seção relevante de cada spec, não a spec inteira.

    ### Rastreabilidade de requisitos

    Ao implementar código que atende diretamente um requisito funcional da spec:
    - Adicione comentário: `// Implements RF-XXX from SPEC-ID: descrição curta`
    - Em testes: `// Tests RF-XXX from SPEC-ID`
    - Use o mesmo formato consistentemente para permitir grep.

    ### Scope guardrail — não sair do escopo

    Antes de cada ação, verificar:
    - "Isso está na minha task/spec?" → Se não: não fazer.
    - "Encontrei um bug não relacionado" → Registrar no backlog, não corrigir agora.
    - "Tive uma ideia de melhoria" → Registrar em STATE.md (seção "Ideias adiadas"), não implementar agora.

    ### Recalibração durante sessões longas

    Em tarefas que envolvem múltiplas subtarefas ou mais de 3 arquivos:
    - Antes de cada subtarefa, releia a seção relevante da spec.
    - Antes de cada subtarefa, releia a seção "Não fazer" da spec.
    - Se não lembrar se uma decisão foi aprovada, pergunte em vez de assumir.

    ### Ao criar código novo
    - Referencie o ID do requisito funcional (RF-001, RF-002...) em comentários no código quando a lógica implementa diretamente um requisito da spec.
    - Respeite os edge cases documentados na spec — cada um deve ter cobertura de teste.
    ```

- **Apêndice B — Setup com specs no Notion (template do índice + trecho do CLAUDE.md)**

    Este apêndice contém os dois artefatos necessários para configurar o padrão SPECS_INDEX quando as specs vivem no Notion e o Claude Code acessa via MCP. Copie cada seção para o arquivo correspondente no seu projeto.

    **1. Template do SPECS_INDEX.md**

    Copie para a raiz do repositório como `SPECS_INDEX.md`.

    ```markdown
    # SPECS_INDEX

    > Índice de especificações do projeto. As specs completas estão no Notion.
    >
    > **Regra para o Claude Code:**
    > 1. Leia este índice para identificar a spec relevante.
    > 2. Use o Notion MCP para buscar APENAS a página identificada.
    > 3. Nunca faça search aberto no Notion workspace — use o Page ID ou título exato deste índice.

    ---

    ## Como usar este índice

    | Campo           | Descrição                                                        |
    |-----------------|------------------------------------------------------------------|
    | **Domínio**     | Área funcional do sistema                                        |
    | **Título Notion** | Nome exato da página no Notion (usar em buscas)               |
    | **Page ID**     | ID da página Notion (extraído da URL, após o último `-`)        |
    | **Status**      | `rascunho` · `aprovada` · `em andamento` · `concluída` · `descontinuada`   |
    | **Owner**       | Responsável pela spec — opcional (PM ou tech lead)               |
    | **Resumo**      | 1-2 frases sobre o escopo (suficiente para decidir se precisa buscar no Notion) |

    ---

    ## Autenticação & Autorização

    | Título Notion | Page ID | Status | Owner | Resumo |
    |---------------|---------|--------|-------|--------|
    | Spec: Login Flow | `a1b2c3d4e5f6` | aprovada | @ana | Fluxo de login com email/senha e OAuth (Google, GitHub). Refresh token rotation e session management. |
    | Spec: RBAC Model | `b2c3d4e5f6a7` | em andamento | @ana | Modelo de permissões role-based. Roles (admin, editor, viewer), hierarquia e regras de herança. |
    | Spec: MFA | `c3d4e5f6a7b8` | rascunho | @carlos | MFA via TOTP e SMS. Recovery codes e fluxo de fallback. |

    ## Billing & Pagamentos

    | Título Notion | Page ID | Status | Owner | Resumo |
    |---------------|---------|--------|-------|--------|
    | Spec: Subscription Plans | `d4e5f6a7b8c9` | aprovada | @maria | Planos (free, pro, enterprise). Limites, features por tier, trial period. |
    | Spec: Checkout Flow | `e5f6a7b8c9d0` | aprovada | @maria | Checkout com Stripe. Cupons, prorating em upgrade/downgrade, falha de pagamento. |
    | Spec: Invoicing | `f6a7b8c9d0e1` | rascunho | @maria | Geração de invoices, nota fiscal, integração com ERP. |

    <!-- Adicione mais domínios conforme necessário -->

    ---

    ## Dependências entre specs

    | Spec | Depende de | Motivo (1 frase) |
    |------|-----------|------------------|
    | Checkout Flow | Subscription Plans | Precisa dos planos e limites por tier para calcular valor |
    | Checkout Flow | Login Flow | Sessão autenticada obrigatória para iniciar checkout |

    ---

    ## Manutenção deste índice

    - **Ao criar nova spec no Notion:** adicione entrada aqui com título exato e Page ID antes de mergear.
    - **Para extrair o Page ID:** abra a página no Notion → copie a URL → o ID é a parte após o último `-` (ex: `https://notion.so/workspace/Spec-Login-Flow-a1b2c3d4e5f6` → `a1b2c3d4e5f6`).
    - **Ao adicionar dependência:** atualize a tabela "Dependências entre specs" E a seção "Dependências" dentro da spec no Notion.
    - **Ao mudar status:** atualize a coluna Status aqui E o property de status no Notion.
    - **Ao deprecar:** mude status para `descontinuada` e adicione nota sobre qual spec substitui.
    - **Ao mover/renomear no Notion:** atualize o título aqui. O Page ID não muda com rename.
    ```

    **2. Trecho para o CLAUDE.md**

    Copie para o `CLAUDE.md` do repositório (ou adicione ao existente). Mesma base do Apêndice A, com as seguintes diferenças:

    ```markdown
    ## Specs e Requisitos

    As especificações de produto estão no Notion. Este repositório contém apenas o índice (`SPECS_INDEX.md`).

    ### Fluxo obrigatório antes de implementar

    1. Leia `SPECS_INDEX.md` na raiz do projeto.
    2. Localize a spec pelo domínio e resumo. Se nenhuma spec cobre o que vai implementar, PARE e pergunte.
    3. Verifique o status:
       - `aprovada` ou `em andamento` → prossiga para o passo 4.
       - `rascunho` → PARE. Avise que a spec ainda não foi aprovada e pergunte se deve prosseguir.
       - `descontinuada` → NÃO implemente. Pergunte qual spec substituiu.
    4. Busque a spec no Notion usando o Page ID do índice. Use a tool `notion:retrieve_page` ou `notion:search` com o título exato.
    5. Leia a seção "Não fazer" ANTES de começar. Se algo que você planejava fazer está listado ali, NÃO faça.
    6. Leia apenas as seções relevantes para a tarefa (ex: "API Contract" para um endpoint, "Edge Cases" para testes).
    7. Classifique a complexidade (ver tabela de auto-sizing) ANTES de começar.

    ### Regras de acesso ao Notion

    - **Nunca** faça search aberto no workspace do Notion sem um termo específico do índice.
    - **Nunca** liste ou navegue por databases inteiras — busque apenas a página identificada.
    - Se a chamada ao Notion falhar (timeout, permissão, fora do ar), avise e continue com o que já sabe. Não invente requisitos.
    - O conteúdo do Notion é a fonte de verdade. Se houver conflito entre código existente e spec, siga a spec e sinalize o conflito.

    (As demais seções — auto-sizing, context budget, validação pré-implementação, dependências, rastreabilidade, scope guardrail, recalibração — são idênticas ao Apêndice A.)
    ```

---

## Como funciona na prática

O fluxo é lazy fetch. O modelo só busca o que precisa, quando precisa:

1. O dev pede: "implementa o endpoint de retry de webhook".
2. O Claude Code lê o `SPECS_INDEX.md` (barato — dezenas de linhas).
3. Pelo resumo, identifica que a spec relevante é `Spec: Webhooks`.
4. Consulta o mapa de dependências no índice — verifica se há specs relacionadas relevantes para a tarefa.
5. **Classifica complexidade:** avalia se é Pequeno/Médio/Grande/Complexo e ajusta o fluxo (ver tabela de auto-sizing).
6. Abre apenas a spec primária e, se necessário, a seção específica da spec dependente (arquivo local ou chamada MCP ao Notion).
7. Lê a seção "Não fazer" para saber os boundaries.
8. **Validação pré-implementação:** abre os arquivos mencionados na spec e confirma que existem e se comportam como esperado.
9. Escreve testes baseados nos Critérios de aceitação (red).
10. Implementa o mínimo para os testes passarem (green), referenciando RF-XXX no código.
11. Refatora, documenta, e relê a spec antes de cada subtarefa para evitar context drift.

Sem o índice, o passo 3 não existe — o modelo precisaria abrir cada spec para descobrir se é relevante.

## Estrutura do índice

Cada entrada contém os campos mínimos para o modelo decidir se precisa abrir a spec:

| Campo | Propósito |
| --- | --- |
| Domínio | Agrupamento funcional (auth, billing, notifications). Permite ao modelo filtrar por área antes de ler as entradas. |
| ID | Identificador único da spec. Pode ser o ID do tracker (AUTH-100, BILL-210). Permite rastreabilidade bidirecional entre código e spec. |
| Spec (caminho ou referência) | Onde encontrar a spec completa. Pode ser um path local, um Page ID do Notion, ou uma URL de Confluence. |
| Status | `rascunho` · `aprovada` · `em andamento` · `concluída` · `descontinuada`. O modelo usa isso para decidir se deve implementar ou parar e perguntar. |
| Owner | Quem é responsável pela spec. Opcional — útil em times onde specs têm responsáveis diferentes. |
| Resumo | 1-2 frases descrevendo o escopo. Este é o campo mais importante. |

## Por que o resumo é o campo mais importante

O resumo de 1-2 frases é o que transforma o índice de uma tabela burocrática em uma ferramenta funcional para o modelo. Considere dois cenários:

**Sem resumo:** o modelo recebe a tarefa "implementar retry de webhook". Ele lê o índice, vê `specs/api/webhooks.md`, e abre o arquivo. Mas também vê `specs/api/v2-endpoints.md` e `specs/notifications/push-notifications.md` — sem resumo, não consegue descartar esses arquivos sem abri-los. Resultado: 3 arquivos abertos, 2 desnecessários.

**Com resumo:** o modelo lê "Webhooks: eventos, payload format, retry policy, assinatura HMAC" e imediatamente identifica que essa é a spec certa. Os resumos das outras specs deixam claro que não são relevantes. Resultado: 1 arquivo aberto, 0 desperdício.

A regra para escrever bons resumos: inclua os termos técnicos que um desenvolvedor usaria ao descrever a tarefa. Se alguém diria "retry de webhook", o resumo da spec de webhooks precisa conter "retry". Se alguém diria "permissões de admin", o resumo da spec de RBAC precisa conter "admin" e "permissões".

## O papel do CLAUDE.md

O índice sozinho não resolve. O modelo precisa de uma instrução explícita no `CLAUDE.md` para seguir o fluxo correto. Sem isso, ele ignora o índice e vai direto aos arquivos.

A instrução deve cobrir estes pontos:

1. **Consultar o índice primeiro.** O modelo deve ler `SPECS_INDEX.md` antes de implementar qualquer feature ou correção de comportamento de negócio.
2. **Abrir apenas a spec relevante.** Após identificar a entrada no índice, o modelo abre somente aquele arquivo — não as specs vizinhas, não o domínio inteiro.
3. **Respeitar o status.** Specs em `rascunho` não devem ser implementadas sem confirmação. Specs `descontinuada` não devem ser implementadas de forma alguma.
4. **Focar na seção relevante.** Dentro da spec, o modelo lê a seção que importa para a tarefa (API Contract para endpoints, Edge Cases para testes, Data Model para migrations).
5. **Classificar complexidade.** Antes de começar, avaliar se é Pequeno/Médio/Grande/Complexo e ajustar o fluxo (ver auto-sizing).
6. **Referenciar requisitos no código.** IDs de requisitos funcionais (RF-001, RF-002) devem aparecer como comentários no código, criando rastreabilidade entre implementação e especificação.
7. **Validar a spec contra o código atual.** Antes de implementar, confirmar que os arquivos e funções mencionados na spec ainda existem e se comportam como esperado.
8. **Respeitar o scope guardrail.** Não implementar nada fora do escopo da task/spec. Ideias e bugs não relacionados vão para o backlog ou STATE.md.

Os templates completos estão nos Apêndices A e B.

## Auto-sizing — classificar complexidade antes de implementar

Este conceito é central para escalar o fluxo spec-driven sem gerar overhead desnecessário. Nem toda tarefa precisa do mesmo nível de cerimônia.

### Os 4 tamanhos

| Tamanho | Critério | O que criar | Fluxo |
|---|---|---|---|
| **Pequeno** | ≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova | Só entrada no backlog | Backlog → implementa → testa → commit |
| **Médio** | <10 tasks, escopo claro, sem decisão arquitetural | Spec breve (contexto + requisitos + critérios) | Backlog → spec → TDD → commit |
| **Grande** | Multi-componente, >10 tasks | Spec completa + breakdown de tasks + design doc (opcional) | Backlog → research (recomendado) → spec → design → tasks → TDD → commit |
| **Complexo** | Ambiguidade, domínio novo, >20 tasks | Spec + design + tasks com `[P]` + STATE.md | Fluxo RPI (skill research) → spec → design → tasks → sub-agents → commit |

Na dúvida, classificar para cima (Médio vira Grande). **Safety valve:** se ao listar tasks inline aparecem >5 steps ou dependências complexas, reclassificar como Grande.

### Por que isso importa

Sem auto-sizing, acontece uma de duas coisas: o time especifica demais (10 minutos de spec pra 5 minutos de fix) ou de menos (feature complexa implementada "de cabeça" e depois difícil de verificar). O threshold objetivo elimina o julgamento subjetivo.

Para AI coding isso é especialmente crítico: o modelo não tem julgamento sobre "isso é simples o suficiente pra dispensar spec". Se não há threshold claro, o modelo ou cria spec pra tudo (overhead) ou pra nada (caos).

### Fluxo RPI — Research, Plan, Implement (Grande/Complexo)

O padrão RPI surgiu na comunidade de AI coding, popularizado pela [HumanLayer](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop) e adotado pelo time do [Goose (Block/Square)](https://block.github.io/goose/docs/tutorials/rpi/). O problema que resolve: em codebases existentes (brownfield), pedir ao agente que pesquise, decida e implemente tudo de uma vez resulta em decisões arquiteturais inventadas e padrões existentes ignorados. O RPI força o agente a **alinhar nas decisões antes de escrever código**, com cada fase rodando em sessão separada.

Para tarefas grandes ou complexas, dividir em sessões separadas:

1. **Research:** seguir protocolo da skill research (`.claude/skills/research/README.md`). Investigar código existente, patterns de reuso, dependências, riscos. Output: `.claude/specs/{id}-research.md` com achados estruturados por 6 eixos.
2. **Discuss (se gray areas):** usar `/discuss` para resolver ambiguidades, decisões técnicas e dependências não resolvidas. Faz scout no codebase, guia deep-dive em cada gray area e gera a spec ao final com decisões incorporadas. Se não há gray areas, pular para Plan com `/spec` direto.
3. **Plan:** escrever spec (se não gerada pelo `/discuss`), design doc, breakdown de tasks a partir dos achados do research. Output: spec aprovada + tasks priorizadas.
4. **Implement:** executar tasks em waves (sequenciais → paralelas → integração). Output: código + testes.

Cada fase roda numa sessão separada com context limpo. A fundamentação: pesquisa sobre *task interference* (EMNLP 2024) mostrou que **trocar de tipo de tarefa na mesma sessão degrada performance significativamente**, mesmo em modelos frontier. Research acumula muitos file reads (alta densidade de distratores), Plan toma decisões arquiteturais, e Implement precisa de foco em código. Misturar as três numa mesma sessão força o modelo a navegar entre contextos conflitantes.

### RPI vs Sub-agents — quando usar cada um

Sub-agents rodam em **context windows isolados** com seus próprios tokens. Isso significa que o problema de context mixing é resolvido de duas formas:

| Abordagem | Como funciona | Trade-off |
|---|---|---|
| **`/clear` (mais rápido)** | Limpa o contexto da sessão atual. Mantém o mesmo terminal/processo. | Context limpo instantaneamente. Histórico de arquivos editados preservado. Não precisa de STATE.md para continuidade simples. |
| **Sessões separadas (RPI clássico)** | Cada fase em sessão nova. STATE.md preserva continuidade. | Context 100% limpo, mas perde continuidade. Precisa de STATE.md. |
| **Sub-agents na mesma sessão** | Research e tasks `[P]` delegados a sub-agents. Sessão principal mantém contexto. | Continuidade mantida, mas [usa 4-7x mais tokens](https://dev.to/onlineeric/claude-code-sub-agents-burn-out-your-tokens-4cd8). Sessão principal ainda acumula os summaries. |

**Quando usar sessões separadas (RPI):**
- Feature Complexa (>20 tasks, domínio novo, ambiguidade)
- Research pesada que vai ler dezenas de arquivos
- Sessão principal já está em >50% do context window
- Orçamento de tokens é uma preocupação

**Quando usar sub-agents (mesma sessão):**
- Feature Grande mas com escopo claro (tasks bem definidas)
- Tasks `[P]` independentes que podem rodar em paralelo
- Continuidade entre research e implementação é importante
- Context window do modelo é grande (1M) e orçamento de tokens não é limitante

**Na prática:** muitos projetos usam uma abordagem híbrida — Research em sub-agent (evita poluir a sessão principal com dezenas de file reads), Plan na sessão principal (decisões ficam no contexto), Implement com tasks `[P]` em sub-agents paralelos.

### Lifecycle com artefatos persistidos (Grande/Complexo)

O fluxo completo para itens Grande/Complexo com artefatos que persistem entre sessões:

```
1. Usuário: "implementa spec X"
2. Claude lê spec-driven → classifica como Grande/Complexo
3. Fase research: skill research → salva .claude/specs/{id}-research.md
4. Fase plan: skill execution-plan → salva .claude/specs/{id}-plan.md
5. STATE.md atualizado: fase plan → exit criteria satisfeito
   ── pausa natural: artefatos existem como arquivos ──
   O usuário pode:
   a) Revisar e continuar na mesma sessão
   b) Fechar, revisar depois, abrir sessão nova
   c) Pedir para outro agente validar o plano
6. Fase execute: sessão nova ou /clear
   → carrega {id}-plan.md + spec + {id}-research.md + STATE.md
   → implementa seguindo waves do plan
7. Fase verify: definition-of-done compara implementação contra o plan
8. Fase done: spec → done/ (ou status concluída no Notion)
   → deleta {id}-research.md e {id}-plan.md (já verificados)
```

**Artefatos e seu ciclo de vida:**

| Artefato | Criado na fase | Consumido na fase | Destino no done |
|----------|---------------|-------------------|-----------------|
| Spec | plan | execute, verify | `done/` (repo) ou status concluída (Notion) |
| Design doc | plan | execute | `done/` (repo) ou status concluída (Notion) |
| `{id}-research.md` | research | plan | Deletado (absorvido pela spec) |
| `{id}-plan.md` | plan | execute, verify | Deletado (verificado contra implementação) |

**Por que persistir em arquivo:**
- Gate `plan → execute` é verificável: arquivo existe no disco, não depende de instrução
- Sessão nova carrega o plan sem depender do contexto anterior
- `verify.sh` pode checar: spec Médio+ sem `{id}-plan.md` = erro
- Definition-of-done compara implementação contra o plan salvo

**Por que deletar no done:**
- Research e plan são artefatos de trabalho, não permanentes
- Achados do research já foram absorvidos pela spec
- Plan já foi verificado contra a implementação
- `git log` e a spec (permanente) preservam o contexto histórico

## Context budget — evitar alucinação por excesso de contexto

Em sessões longas, o modelo acumula contexto e começa a perder precisão. O trade-off é: quanto mais contexto consumido na janela, menos espaço para raciocínio de qualidade.

A regra é manter sessões de implementação abaixo de **~60-70% do context window** do modelo em uso:

| Modelo | Context window | Budget seguro (~60-70%) |
|---|---|---|
| Opus 4.6 (1M) | 1M tokens | ~600-700k |
| Opus 4.6 (200k) | 200k tokens | ~120-140k |
| Sonnet 4.6 | 200k tokens | ~120-140k |
| Haiku 4.5 | 200k tokens | ~120-140k |

> **Atenção:** Os context windows mudam entre versões dos modelos e um mesmo modelo pode ter variantes com janelas diferentes. O budget deve ser recalculado como ~60-70% do context window atual do modelo em uso. Verificar a documentação do modelo e a variante contratada antes de confiar nos valores desta tabela.

### Por que ~60-70% e não 100%?

O limit de 60-70% não é um achado de um paper específico — é uma heurística prática derivada de três problemas bem documentados:

1. **"Lost in the Middle"** — pesquisa de Stanford mostrou que LLMs têm performance em curva U: lembram bem do início e do fim do contexto, mas perdem até **30% de precisão** em informações no meio. Em sessões longas de coding, as decisões tomadas no início ficam "enterradas" sob camadas de código, diffs, e tool outputs.

2. **Context rot** — pesquisa da Chroma testou 18 modelos frontier e **todos** degradam conforme o input cresce. Não é questão de "se", é "quanto". Mais contexto = mais ruído = mais chances de o modelo seguir um caminho errado.

3. **Mistura de assuntos** — o problema prático mais comum. Uma sessão que começa com pesquisa de codebase, passa por decisões arquiteturais, implementa feature A, corrige bug B, e refatora módulo C acumula contextos conflitantes. O modelo precisa navegar entre todos eles para cada resposta, e a qualidade cai progressivamente.

O auto-compaction do Claude Code (~95% do window) evita crash, mas não evita degradação. Quando compacta, perde nuances. O budget de 60-70% é o ponto onde **ainda há espaço para raciocínio de qualidade** sem depender de compactação.

A combinação de **sessões focadas** (1 assunto por sessão), **fluxo RPI** (research → plan → implement separados), e **STATE.md** (memória entre sessões) é mais eficaz do que simplesmente ter um context window maior.

### Referências e leitura recomendada

| Tema | Referência |
|---|---|
| Degradação no meio do contexto | [Lost in the Middle: How Language Models Use Long Contexts (Stanford, 2023)](https://arxiv.org/abs/2307.03172) |
| Degradação por tamanho de input | [Context Rot: Why LLMs Degrade as Context Grows (Morph)](https://www.morphllm.com/context-rot) |
| Tamanho de contexto prejudica mesmo com recuperação perfeita | [Context Length Alone Hurts LLM Performance (2025)](https://arxiv.org/html/2510.05381v1) |
| Degradação por troca de tarefa na mesma sessão | [LLM Task Interference: Impact of Task-Switch in Conversational History (EMNLP 2024)](https://arxiv.org/html/2402.18216v2) |
| RPI — origem e metodologia | [Ralph Loops: RPI Methodology (HumanLayer/LinearB)](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop) |
| RPI — tutorial e implementação | [Research → Plan → Implement Pattern (Goose/Block)](https://block.github.io/goose/docs/tutorials/rpi/) |
| RPI — documentação e estratégia | [Introducing the RPI Strategy (Patrick Robinson)](https://patrickarobinson.com/blog/introducing-rpi-strategy/) |
| RPI — evolução do padrão em 2026 | [The Necessary Evolution of RPI (BetterQuestions)](https://betterquestions.ai/the-necessary-evolution-of-research-plan-implement-as-an-agentic-practice-in-2026/) |
| Práticas de gestão de contexto para coding agents | [Best Practices for Context Management (DigitalOcean)](https://docs.digitalocean.com/products/gradient-ai-platform/concepts/context-management/) |
| Práticas de uso do Claude Code | [Best Practices for Claude Code (Anthropic)](https://code.claude.com/docs/en/best-practices) |
| Context window 1M — o que muda | [Claude Code 1M Context Window Guide (2026)](https://claudefa.st/blog/guide/mechanics/1m-context-ga) |
| Buffer interno e compactação | [Claude Code Context Buffer Management](https://claudefa.st/blog/guide/mechanics/context-buffer-management) |
| Sub-agents e isolamento de contexto | [Subagents & Context Isolation (ClaudeWorld)](https://claude-world.com/tutorials/s04-subagents-and-context-isolation/) |
| Sub-agents — custo de tokens (4-7x) | [Claude Code Sub Agents: Burn Out Your Tokens (DEV Community)](https://dev.to/onlineeric/claude-code-sub-agents-burn-out-your-tokens-4cd8) |
| Sub-agents — documentação oficial | [Create custom subagents (Anthropic)](https://code.claude.com/docs/en/sub-agents) |

Na prática:
- **Pequeno/Médio:** cabe numa sessão só
- **Grande:** considerar 1 sessão por grupo de tasks
- **Complexo:** 1 sessão por fase (research, plan, implement) + sub-sessões por wave de tasks `[P]`
- Ao perceber que a sessão está ficando longa: parar, registrar estado no `STATE.md`, e limpar contexto com `/clear` (ou abrir nova sessão)

### STATE.md — memória persistente entre sessões

Quando uma tarefa requer múltiplas sessões (Grande/Complexo), é necessário um mecanismo de continuidade. O `STATE.md` funciona como memória entre sessões:

- **Decisões arquiteturais** (AD-NNN): decisões tomadas, com justificativa
- **Blockers ativos** (B-NNN): impedimentos conhecidos
- **Lições aprendidas** (L-NNN): insights que previnem erros futuros
- **Ideias adiadas:** melhorias identificadas durante a implementação mas fora do escopo (scope guardrail)
- **TODOs entre sessões:** estado exato de onde parou e por onde continuar

O modelo lê o STATE.md no início de cada sessão para recuperar o contexto sem reprocessar tudo.

## Dependências entre specs

Specs raramente existem isoladas. O "Checkout Flow" depende de "Subscription Plans" (precisa saber os planos), que depende de "Auth" (sessão autenticada). Se o modelo lê só a spec do checkout sem saber que existe uma dependência, ele implementa com premissas erradas.

A solução tem três camadas: mapa no índice, seção na spec, e instrução no CLAUDE.md.

### No SPECS_INDEX: mapa de dependências

Uma seção no final do índice que o modelo consulta depois de identificar a spec primária:

```markdown
## Dependências entre specs

| Spec | Depende de | Motivo (1 frase) |
|------|-----------|------------------|
| Checkout Flow | Subscription Plans | Precisa dos planos e limites por tier para calcular valor |
| Checkout Flow | Login Flow | Sessão autenticada obrigatória para iniciar checkout |
| Webhooks | API v2 Endpoints | Segue mesmas convenções de payload, auth e rate limiting |
| Push Notifications | Login Flow | Usa session tokens para identificar device do usuário |
| RBAC Model | Login Flow | Permissões são atribuídas após autenticação |
```

O modelo lê: "vou implementar Checkout Flow → depende de Subscription Plans e Login Flow → busco essas duas também". O motivo de uma frase evita que ele abra a dependência sem necessidade — se a tarefa é só "adicionar cupom no checkout", ele lê o motivo e percebe que a dependência de Login Flow não é relevante para essa tarefa específica.

### Na spec: seção de dependências no topo

Dentro de cada spec, logo depois do Contexto:

```markdown
## Dependências

| Spec | O que esta spec usa | Seção relevante |
|------|---------------------|-----------------|
| Subscription Plans | Definição dos tiers e limites | Data Model, RF-003 a RF-007 |
| Login Flow | Token de sessão e refresh token | API Contract (endpoints de auth) |

> Se qualquer dependência listada acima estiver em status `rascunho`,
> valide com o Owner antes de implementar.
```

A coluna "Seção relevante" é o diferencial: o modelo não precisa ler a spec inteira da dependência, só a seção que importa. Em vez de carregar 500 linhas de "Subscription Plans", ele lê só o Data Model e os requisitos RF-003 a RF-007.

### No CLAUDE.md: instrução de resolução

```markdown
### Dependências entre specs

Após identificar a spec primária no SPECS_INDEX:

1. Consulte a seção "Dependências entre specs" no final do índice.
2. Se a spec primária tem dependências listadas, avalie se são
   relevantes para a tarefa atual (use o motivo como filtro).
3. Se relevante, abra a spec dependente e leia APENAS a seção
   indicada na coluna "Seção relevante" dentro da spec primária.
4. Limite: máximo de 2 specs dependentes por tarefa. Se precisar
   de mais, pare e pergunte — pode ser sinal de escopo grande demais.
```

O limite de 2 é pragmático: se uma tarefa puxa 4+ specs, ou o escopo está grande demais, ou as specs estão granulares demais. Em ambos os casos, o modelo parar e perguntar é melhor do que carregar o contexto inteiro.

### Dependências circulares

Inevitavelmente vai aparecer: Auth depende de Notifications (enviar email de verificação), Notifications depende de Auth (saber quem notificar). No mapa do índice isso fica visível e o modelo precisa de uma instrução simples no CLAUDE.md: "Se detectar dependência circular, carregue apenas a seção relevante de cada spec, não a spec inteira."

---

## Antes da spec: do backlog à especificação

### Quando spec é (e não é) necessária

O auto-sizing resolve essa questão. A tabela de complexidade define o threshold:

- **Pequeno** (≤3 arquivos, sem nova abstração, sem mudança de schema, sem regra de negócio nova): só backlog, sem spec
- **Médio** (escopo claro, <10 tasks): spec breve
- **Grande/Complexo**: spec completa

Sinais adicionais de que spec é obrigatória:
- Muda regra de negócio
- Toca em segurança (auth, permissões, criptografia, PII)
- Resultado visível ao usuário final
- Mudança significativa num mesmo arquivo (não trivial)

### Níveis de spec

Nem toda spec precisa estar completa desde o primeiro dia:

**Completa** — Pronta para implementar. Todos os campos preenchidos, critérios de aceitação definidos, edge cases documentados. Status no índice: `aprovada`.

**Light** — Contexto e escopo resumido. Suficiente para entender o que é e estimar esforço, mas sem detalhamento de API, data model ou edge cases. Detalhamento acontece quando o item for priorizado. Status no índice: `rascunho`.

**Sem spec** — Existe como item no backlog (1 frase). Spec será criada quando o item entrar em pipeline. Não aparece no SPECS_INDEX até ter pelo menos uma spec light.

### Da demanda à spec — PRD e processo colaborativo

Specs não nascem do nada. Antes de abrir o editor e rodar `/spec`, existe um processo de descoberta que envolve o time. O framework oferece o **PRD (Product Requirements Document)** como artefato formal para estruturar essa descoberta.

```
Problema identificado
     │
     ├─ Causas mapeadas (o que está gerando o problema)
     │    └─ Evidências (dados, reclamações, métricas, incidentes)
     │
     ├─ Porquês (por que as causas existem — análise de raiz)
     │
     └─ Como resolver (ações concretas)                              ← PRD captura tudo até aqui
          └─ Cada ação vira item no backlog → spec quando priorizada ← Specs capturam daqui pra frente
```

**O PRD é o artefato de produto** — captura o "o que, por que, para quem". **A spec é o artefato de engenharia** — captura o "como implementar". Um PRD pode gerar multiplas specs.

> **PRD é opt-in.** Projetos que não usam análise de causa raiz formal podem ir direto para specs. Configurado no `/setup-framework`.

Para criar um PRD: `/prd {ID} {Título}`. O skill guia a análise de causa raiz perguntando Problema, Causas, Evidências, Porquês e Como resolver.

**Quando usar PRD:**

| Complexidade | PRD | Por quê |
|---|---|---|
| Pequeno | Não | Vai direto pro backlog/spec |
| Médio | Opcional | Se o time quiser alinhar antes |
| Grande | Recomendado | Múltiplas specs derivadas de um problema |
| Complexo | Recomendado | Alinhamento é crítico antes de investir em specs |

**Exemplo hipotético:**

```
Problema: Tempo de resposta do suporte está alto

Causas:
  - Falta de documentação interna
  - Fluxo de troubleshooting não padronizado
  - Informações espalhadas em vários sistemas

Evidências:
  - Ticket médio leva 3 dias pra resolver
  - 60% dos tickets são re-abertos por falta de contexto

Porquês:
  - Base de conhecimento nunca foi priorizada
  - Cada dev resolve de um jeito diferente

Como resolver:
  1. Criar base de conhecimento interna        → spec FEAT-10
     ├─ Definir estrutura de categorias
     ├─ Migrar FAQs existentes do Slack
     └─ Criar template de artigo padrão
  2. Padronizar fluxo de troubleshooting        → spec FEAT-11
     ├─ Mapear os 10 tipos de ticket mais comuns
     ├─ Criar fluxograma de decisão por tipo
     └─ Treinar time no novo fluxo
  3. Centralizar informações em um lugar        → spec FEAT-12
     ├─ Escolher ferramenta (wiki, notion, repo)
     └─ Integrar com sistema de tickets
```

Cada "Como" vira uma spec derivada do PRD. As **sub-ações** viram detalhes dentro da spec:

| Nível do exercício | Com PRD | Sem PRD (direto na spec) |
|---|---|---|
| Problema + causas + evidências + porquês | **PRD** (artefato próprio) | **Contexto** da spec |
| Ação ("Como") | **Spec vinculada** ao PRD | **Item no backlog** → spec |
| Sub-ações | **RF/Escopo** na spec | **RF/Escopo** na spec |
| Sub-ações com dependências | **Breakdown de tasks** | **Breakdown de tasks** |
| Métricas de sucesso | **Métricas** no PRD | **Critérios de aceitação** na spec |
| O que ficou de fora | **Excluído** no PRD | **Não fazer** na spec |

**Validação:** o agent `product-review` verifica se todas as causas/ações do PRD têm specs vinculadas e se as specs cobrem o que foi definido.

Times que fazem análise de causa raiz, design sprints, ou qualquer exercício colaborativo antes de codar alimentam specs melhores — com ou sem PRD formal.

### De onde vem a spec — backlog como pipeline

O fluxo completo de uma spec, do nascimento ao código:

```
ideia → [PRD (opcional)] → backlog (1 frase) → spec light (contexto + escopo) → spec completa (quando priorizada) → implementação → done
```

O backlog no framework segue um formato estruturado com 4 seções fixas:
1. **Pendentes** — tabela com ID, Fase, Item, Severidade, Impacto, Tipo, Complexidade, Estimativa, Dependências
2. **Concluídos** — tabela compacta com data de conclusão
3. **Decisões futuras** — parking lot estratégico para decisões que dependem de gatilhos
4. **Notas** — contexto relevante

### Granularidade da spec — qual o tamanho certo

O sweet spot: uma spec cobre uma unidade de entrega que pode ser implementada, testada e verificada em 1-3 sessões de trabalho.

Sinais de que a spec está grande demais:
- Mais de ~5 arquivos afetados
- Mais de ~8 checkboxes no escopo
- O resumo no SPECS_INDEX não cabe em 2 frases
- A seção de dependências tem mais de 3 specs

Quando isso acontece, quebre em specs menores.

Sinais de que a spec está pequena demais:
- Cabe em 1 parágrafo
- Altera 1 arquivo com mudança trivial
- O tempo de escrever a spec é maior que o tempo de implementar

Nesse caso, não precisa de spec — cai na categoria "Pequeno" do auto-sizing.

### Nível de prescrição — o que a spec deve (e não deve) definir

Uma crítica comum a specs detalhadas é que elas **tiram a liberdade do agente** de se adaptar ao que encontra no código. Se a spec diz "criar função `validateToken()` no arquivo `auth.js` na linha 42", o agente segue cegamente mesmo que o código tenha evoluído e exista uma forma melhor.

O princípio é: **specs definem O QUE e POR QUÊ, não COMO.**

| A spec deve definir | A spec NÃO deve definir |
|---|---|
| O que o sistema deve fazer (RF-001, RF-002) | Qual função criar, em qual linha |
| Critérios de aceitação testáveis | Detalhes de implementação |
| O que está fora do escopo ("Não fazer") | Qual padrão de código usar (o agente vê no código) |
| Restrições de segurança/negócio | Nomes de variáveis ou estrutura interna |
| Arquivos afetados (quais, não como) | Step-by-step de como modificar cada arquivo |

**A seção "Arquivos afetados" lista onde vai mudar, não como.** Dizer "Modificar `auth.js`" é útil (escopo). Dizer "Na linha 42 do `auth.js`, adicionar `if (token.expired)`" é over-prescritivo — o agente vai encontrar que a linha 42 agora é outra coisa.

**Critérios de aceitação são o contrato.** Se o critério diz "token expirado retorna 401", o agente tem liberdade para implementar da forma que fizer mais sentido no código atual — pode ser middleware, pode ser decorator, pode ser check inline. O critério valida o resultado, não o caminho.

**O breakdown de tasks (Grande/Complexo) é exceção parcial.** Tasks precisam de mais detalhe porque coordenam trabalho paralelo. Mesmo assim, cada task define "O que" + "Pronto quando" — não "Como implementar".

**Quando o agente encontra algo melhor:** se durante a implementação o agente descobre que o código já tem um padrão que resolve o requisito de forma diferente da esperada, ele deve:
1. Implementar usando o padrão existente (não inventar um novo)
2. Registrar a divergência: "A spec assume X, mas o código já tem Y que resolve melhor"
3. O critério de aceitação continua valendo — só o caminho muda

Isso equilibra **disciplina** (specs garantem que nada é esquecido) com **autonomia** (o agente se adapta ao código real).

### Automação da criação de specs

A fricção de "criar arquivo, copiar template, preencher header, adicionar no índice" mata adoção. Se o custo de criar uma spec é 5 minutos de setup burocrático, o dev não cria. Se é 5 segundos, cria até para itens menores.

No framework, a skill `/spec` (slash command do Claude Code) automatiza isso:

1. Classifica a complexidade (Pequeno/Médio/Grande/Complexo)
2. Se Pequeno: cria apenas entrada no backlog
3. Se Médio: cria spec breve a partir do template
4. Se Grande: cria spec completa + oferece criar design doc
5. Se Complexo: cria spec completa + design doc + sugere fluxo RPI
6. Adiciona automaticamente a entrada no `SPECS_INDEX.md`

A implementação pode ser também um script bash, Make target, ou GitHub Action — o que importa é a barreira de entrada próxima de zero.

### Specs em monorepos

A seção `## Monorepo` no CLAUDE.md L0 é a fonte de verdade sobre sub-projetos, paths, stacks e distribuição de framework. Skills que operam com specs consultam essa seção para saber o contexto do monorepo.

Em monorepos, a decisão principal é: **specs centralizadas na raiz ou distribuídas por sub-projeto?**

| Modelo | Quando usar | Como funciona |
|---|---|---|
| **Centralizado** (recomendado para começar) | Sub-projetos compartilham domínio, time único, <20 specs ativas | `.claude/specs/` e `SPECS_INDEX.md` na raiz. Specs de todos os módulos num lugar só. |
| **Distribuído** | Sub-projetos independentes, times diferentes, >20 specs ativas | Cada sub-projeto tem seu `.claude/specs/` e `SPECS_INDEX.md`. Raiz tem backlog unificado. |
| **Híbrido** | Specs cross-module na raiz, specs internas por módulo | Raiz: specs que afetam >1 módulo. Sub-projeto: specs internas. |

**Na prática:**

- `backlog.md` — geralmente centralizado na raiz (visão única do que falta fazer)
- `STATE.md` — pode ser na raiz (decisões transversais) ou por módulo (estado local). Se distribuído, o L0 tem um STATE.md com decisões arquiteturais do monorepo
- `SPECS_INDEX.md` — segue o modelo escolhido. Se centralizado, domínios do índice incluem o nome do módulo (ex: "api/Auth", "web/UX"). Se distribuído, cada módulo tem seu próprio índice
- `DESIGN_TEMPLATE.md` e `TEMPLATE.md` — sempre centralizados (são templates, não specs)

**Referência cruzada entre módulos:** se uma spec de `apps/api` afeta `packages/shared`, a seção "Dependências" da spec deve referenciar o módulo: `packages/shared — RF-003 de SHARED-AUTH`. O `SPECS_INDEX.md` centralizado torna isso natural; o distribuído requer disciplina de cross-reference.

O `/setup-framework` detecta indicadores de monorepo, confirma com o usuário (nunca assume), pergunta quais sub-diretórios são projetos, apresenta mapa para aprovação, e só então pergunta qual modelo de specs usar e configura a estrutura. Ver cenários em [`SETUP_GUIDE.md`](SETUP_GUIDE.md).

---

## Durante a implementação: da spec ao código

### Escopo negativo — a seção "Não fazer"

Isso é crítico especificamente para AI coding. O modelo tende a over-implement: se a spec diz "adicionar botão de delete", ele pode adicionar confirmação modal, soft delete, undo, logging, e tudo mais que "faz sentido" no contexto. Cada adição consome tokens, tempo, e gera código que depois precisa ser revertido ou conflita com specs futuras.

A seção "Não fazer" na spec é um boundary explícito:

```markdown
## Não fazer

- NÃO implementar soft delete nesta spec (será spec separada: CHECKOUT-15)
- NÃO adicionar bulk delete
- NÃO alterar o schema da tabela `orders` — usar apenas campos existentes
- NÃO adicionar testes de integração com Stripe (coberto em CHECKOUT-12)
```

Sem esta seção, a única defesa é a instrução genérica de "não sair do escopo" no CLAUDE.md. Com ela, o modelo tem boundaries concretos e verificáveis.

### Scope guardrail — 3 regras para não sair do escopo

Em desenvolvimento humano, scope creep é um problema de gestão — o dev resolve mais do que foi pedido e atrasa a entrega. Em AI coding, scope creep é um problema **técnico**: cada desvio de escopo degrada a qualidade de tudo que vem depois na mesma sessão.

A razão é mecânica. Quando o agente encontra um bug não relacionado e decide corrigir, ele precisa: ler arquivos adicionais, entender o contexto do bug, gerar diffs, rodar testes. Todo esse output (file reads, análises, diffs) **permanece na janela de contexto** pelo resto da sessão, competindo com a task original. Pesquisa sobre [context rot](https://www.morphllm.com/context-rot) mostra que coding agents são particularmente vulneráveis a isso porque cada tool output é acumulativo e irreversível (não dá pra "esquecer" um file read). E pesquisa sobre [task interference (EMNLP 2024)](https://arxiv.org/html/2402.18216v2) confirma que trocar de tarefa na mesma sessão degrada performance — o agente precisa navegar entre o contexto da task original e o contexto do desvio, perdendo precisão nos dois.

Complementando o "Não fazer" da spec, o CLAUDE.md contém 3 regras de scope guardrail:

1. **"Isso está na minha task/spec?"** → Se não: não fazer.
2. **"Encontrei um bug não relacionado"** → Registrar no backlog, não corrigir agora.
3. **"Tive uma ideia de melhoria"** → Registrar em STATE.md (seção "Ideias adiadas"), não implementar agora.

As regras parecem óbvias, mas sem elas a tendência natural do agente é "ser prestativo" e resolver tudo que encontra. O guardrail transforma uma diretriz vaga ("não saia do escopo") em decisões concretas com destinos claros (backlog para bugs, STATE.md para ideias).

### TDD integrado ao fluxo de specs

O fluxo completo não é "spec → implementação". É:

```
spec → critérios de aceitação → testes (red) → implementação (green) → refactor → docs → verificação
```

Na prática com AI coding, isso se traduz em fases do workflow:

1. Modelo lê a spec (seções: Requisitos Funcionais, Edge Cases, Critérios de aceitação)
2. Modelo escreve testes que validam cada critério — sem código funcional ainda
3. SWE revisa os testes: cobrem os critérios? Os edge cases estão presentes?
4. Modelo implementa o mínimo para os testes passarem
5. Modelo refatora sem quebrar testes

**Exceção para Pequeno:** fix de typo ou mudança trivial pode pular TDD. Mas qualquer coisa Médio ou acima segue o fluxo obrigatoriamente.

### Validação da spec contra código atual

Specs ficam stale. Entre a escrita da spec e o momento que alguém pega para implementar, o código evolui — funções renomeadas, arquivos extraídos, dependências que mudaram.

Regra: antes de tocar em código, abrir os arquivos que a spec menciona e confirmar que as premissas ainda são verdadeiras.

```
1. Ler spec
2. Abrir cada arquivo/função/tabela mencionados na spec
3. Confirmar que existem, têm os nomes corretos, e se comportam como a spec assume
4. Se algo mudou → PARAR e reportar: "A spec assume X, mas o código atual mostra Y"
5. Aguardar decisão do SWE antes de prosseguir
6. Só então escrever testes e implementar
```

### Rastreabilidade bidirecional spec ↔ código (RF-XXX)

Quando o dev comenta `// Implements RF-003 from CHECKOUT-1` no código, o loop se fecha: da spec para o código e do código de volta para a spec.

**Da spec para o código:**

```bash
$ grep -rn "RF-003" src/
src/checkout/shipping.ts:42:  // Implements RF-003 from CHECKOUT-1: cálculo de frete por CEP
src/checkout/shipping.test.ts:15:  // Tests RF-003 from CHECKOUT-1
```

**Do código para a spec:**

```bash
$ grep -rn "CHECKOUT-1" src/
src/checkout/shipping.ts:42:  // Implements RF-003 from CHECKOUT-1
src/checkout/shipping.ts:67:  // Implements RF-004 from CHECKOUT-1
src/checkout/shipping.test.ts:15:  // Tests RF-003 from CHECKOUT-1
src/checkout/shipping.test.ts:38:  // Tests RF-004 from CHECKOUT-1
```

**Na verificação pós-implementação:**

```bash
# Quais requisitos da spec CHECKOUT-1 foram implementados?
$ grep -rn "from CHECKOUT-1" src/ | grep -oP 'RF-\d+' | sort -u
RF-003
RF-004
RF-005

# Comparar com a lista de RFs da spec para identificar gaps
```

### Spec como proteção contra context drift do modelo

Em sessões longas, o modelo acumula contexto e começa a "inventar" decisões que parecem consistentes mas não estão em nenhuma spec. O modelo implementa algo que contradiz o que fez no início, e nem percebe.

A spec funciona como âncora. A instrução que mitiga context drift:

```markdown
### Recalibração durante sessões longas

Em tarefas que envolvem múltiplas subtarefas ou mais de 3 arquivos:
- Antes de cada subtarefa, releia a seção relevante da spec.
- Antes de cada subtarefa, releia a seção "Não fazer" da spec.
- Se não lembrar se uma decisão foi aprovada, pergunte em vez de assumir.
```

O overhead é mínimo (reler 10-20 linhas da spec) e previne o custo alto de reverter implementação incorreta. A fundamentação é o efeito *"lost in the middle"* (Stanford, 2023): informações no meio do contexto perdem até 30% de precisão. Numa sessão com muitas subtarefas, as decisões das primeiras subtarefas ficam literalmente "no meio" — enterradas sob camadas de código, diffs, e tool outputs das subtarefas seguintes. Reler a spec trás essas decisões de volta para o final do contexto, onde o modelo as processa com mais precisão.

Combinado com o context budget, isso forma uma proteção dupla: o budget previne sessões longas demais, e a recalibração previne drift nas sessões que existem.

### Task breakdown com sub-agents (Grande/Complexo)

Para features grandes ou complexas, o breakdown de tasks na spec permite execução paralela:

```markdown
## Breakdown de tasks

### Ordem de execução (waves)

Wave 1 (sequencial): T1 → T2 → T3
Wave 2 (paralela):   T4 [P] | T5 [P] | T6 [P]
Wave 3 (integração):  T7 → T8

### T1: Criar schema do banco
- **O que:** Criar migration com tabelas X, Y, Z
- **Onde:** `database/migrations/`
- **Depende de:** — (primeiro)
- **Reutiliza:** padrão de migration existente
- **Pronto quando:** migration roda sem erro e rollback funciona

### T4: Implementar endpoint de listagem [P]
- **O que:** GET /api/items com paginação
- **Onde:** `src/routes/items.ts`
- **Depende de:** T1 (schema precisa existir)
- **Reutiliza:** middleware de auth existente
- **Pronto quando:** Tests RF-003 from ITEMS-1 passam
```

Tasks marcadas com `[P]` podem rodar em sub-agents simultâneos do Claude Code, cada um com seu próprio context limpo. Isso é especialmente útil para features que tocam em áreas independentes do código.

### Design doc — decisões arquiteturais separadas da spec

Para features grandes ou complexas, decisões arquiteturais (qual padrão usar, trade-offs de performance, modelo de dados) tendem a poluir a spec. O design doc é um arquivo separado que:

- Documenta decisões de arquitetura com justificativa
- Define modelo de dados e diagramas de fluxo
- Lista riscos e mitigações
- Explicita o que está fora do escopo do design

Template em `specs/DESIGN_TEMPLATE.md`. Obrigatório para Complexo, recomendado para Grande.

---

## Depois da implementação: fechando o ciclo

### Verificação pós-implementação

Antes de mover uma spec para `concluída`:

- [ ]  Cada critério de aceitação verificado no código (abrir o arquivo e confirmar, não de memória)
- [ ]  Cada checkbox do escopo marcado `[x]` ou movido para novo item no backlog
- [ ]  Cada item da seção "Não fazer" confirmado como não implementado
- [ ]  Todos os testes passam localmente
- [ ]  Rastreabilidade verificada: grep pelos RF-XXX retorna implementação para todos os requisitos
- [ ]  Docs atualizados (docstrings, README, contratos)
- [ ]  Status no SPECS_INDEX atualizado para `concluída`
- [ ]  Se implementação foi parcial: itens pendentes explícitos como novos cards no backlog
- [ ]  Se Grande/Complexo: STATE.md atualizado (lições, blockers resolvidos, ideias adiadas registradas)
- [ ]  Se Grande/Complexo: design doc movido junto com spec para `done/`
- [ ]  Nenhuma mudança fora do escopo foi incluída (scope guardrail)

Red flags que indicam problema de processo:

- Spec em `done/` com status `rascunho` no SPECS_INDEX → alguém implementou sem a spec estar aprovada
- Spec em `done/` com checkboxes desmarcados → implementação incompleta aceita como completa
- Grep por RF-XXX retorna menos requisitos do que a spec lista → funcionalidade faltando
- Seção "Não fazer" violada no código → escopo extrapolado

### CI check concreto

O framework inclui `scripts/verify.sh` com checks de integridade que rodam automaticamente:

```bash
# Checks de integridade do sistema de specs:

# 14. Toda spec ativa tem entrada no SPECS_INDEX.md (ativo por padrão)
# 14b. Toda entrada no SPECS_INDEX aponta para arquivo que existe (ativo por padrão)
# 15. Specs em done/ têm status concluída (comentado — descomentar quando tiver specs em done/)
# 16. Specs com breakdown de tasks têm STATE.md (comentado — descomentar quando tiver specs com breakdown)
# 17. Design docs referenciados nas specs existem no disco
```

Além desses, o script inclui checks de testes, segurança (OWASP top 10), e docs sync. A ideia é que o CI falhe se a integridade estrutural estiver quebrada.

Exemplo de integração com GitHub Actions:

```yaml
# .github/workflows/verify-specs.yml
name: Verify Specs
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: chmod +x scripts/verify.sh && ./scripts/verify.sh
```

---

## Onde as specs ficam de fato

O índice é agnóstico à localização das specs. Ele funciona com qualquer backend:

**Specs no mesmo repo** (`specs/dominio/feature.md`). A abordagem mais simples. O modelo lê o índice e abre o arquivo. Sem dependência de rede, sem latência, sem risco de indisponibilidade. Desvantagem: specs e código acoplados no mesmo repositório.

**Specs em outro repo via submodule.** O índice aponta para paths dentro do submodule. Funciona bem desde que o time mantenha o submodule atualizado. Risco principal: specs desatualizadas se o `git submodule update` não é feito regularmente.

**Specs em ferramenta externa (Notion, Confluence, Linear).** O índice contém External IDs (Page IDs, issue keys, URLs) em vez de paths. O modelo usa MCP para acessar. Vantagens: PMs editam na ferramenta que já usam. Desvantagens: dependência de rede, formato de retorno pode ser ruidoso, sem versionamento integrado ao Git. O SPECS_INDEX usa colunas específicas para esse caso: `Título na ferramenta | External ID` (ver Apêndice B).

**Sync automático (híbrido).** Um script exporta specs da ferramenta externa para Markdown no repo. O índice aponta para os arquivos locais exportados. O modelo lê local, o PM edita na ferramenta original. Melhor dos dois mundos, ao custo de manter o pipeline de sync.

### Riscos específicos do Notion como backend

Se o time usa Notion como source of truth para specs, há riscos adicionais a considerar:

- **Latência e confiabilidade.** Cada consulta é uma chamada de rede. Se o Notion está lento ou fora do ar, o Claude Code trava ou falha silenciosamente.
- **Formato do retorno.** Tabelas, toggles, databases relacionais e embeds do Notion podem vir como estrutura confusa para o modelo interpretar. Markdown em arquivo local é trivial de parsear.
- **Versionamento.** Código vive no Git com branches e tags. Specs no Notion são mutáveis em tempo real. Quando um dev implementa na branch X, a spec no Notion pode já ter sido editada para a v2.
- **Descoberta.** Sem o índice, o modelo precisaria fazer search no workspace inteiro — lento, caro em tokens, e retorna resultados irrelevantes.

O índice com External ID mitiga o problema de descoberta. Os demais riscos permanecem e devem ser aceitos conscientemente.

### Integração nativa com Notion (v2.1.0+)

A partir da v2.1.0, o framework suporta integração nativa com Notion via MCP. Quando configurada pelo `/setup-framework`, as skills `/spec` e `/backlog-update` operam diretamente na database do Notion:

- **`/spec`** cria páginas no Notion usando os templates da database (Spec Pequena, Média, Grande/Complexa, Design Doc), preenche as propriedades automaticamente (Status, Fase, Severidade, Camadas, etc.) e registra no SPECS_INDEX.md local.
- **`/backlog-update`** lê e atualiza propriedades (Status, Concluída em, etc.) diretamente na página do Notion.
- **Leitura de specs** usa `notion-fetch` com o URL da página — o Claude lê o conteúdo completo incluindo o body preenchido pelo template.

A configuração é armazenada na seção `## Integracao Notion (specs)` do CLAUDE.md, que inclui o data source ID da database e a tabela de mapeamento de templates por complexidade. Ver `docs/SETUP_GUIDE.md` para detalhes da configuração.

## Impacto no consumo de tokens

Para um time usando Claude Code via API pay-as-you-go, o impacto é mensurável.

Cenário sem índice: o modelo lê 5 specs de ~500 linhas cada para encontrar a relevante. São ~2.500 linhas de input desnecessário por sessão. Com prompt caching, parte disso é amortizada — mas a primeira leitura é custo total.

Cenário com índice: o modelo lê ~80 linhas do índice + ~500 linhas da spec relevante. Redução de ~75% no consumo de tokens de input para a fase de discovery.

Multiplicado por 30 desenvolvedores fazendo várias sessões por dia, a economia acumula.

O context budget por modelo adiciona outra camada de economia: ao dividir tarefas grandes em sessões menores (~60-70% do context window), cada sessão é mais eficiente e precisa.

## Convenções recomendadas para as specs

O índice funciona melhor quando as specs seguem uma estrutura previsível. Isso permite que a instrução no `CLAUDE.md` diga "leia a seção API Contract" e o modelo saiba exatamente o que procurar.

Estrutura sugerida para cada spec. O template do framework (`specs/TEMPLATE.md`) contém as seções core. Seções adicionais (marcadas com *) podem ser adicionadas conforme o tipo de feature:

```
# [Nome da Feature]

## Contexto
Por que essa feature existe e qual problema resolve.

## Dependências
Quais specs esta spec depende, o que usa de cada uma, e qual seção consultar.

## Requisitos Funcionais
Lista numerada (RF-001, RF-002...) dos requisitos.

## Escopo
O que está dentro desta spec (checkboxes verificáveis).

## Critérios de aceitação
Condições verificáveis para considerar a spec implementada. Cada critério deve ser mapeável para um teste.

## Arquivos afetados
Tabela com path e tipo de mudança (Criar / Modificar / Remover).

## Breakdown de tasks (Grande/Complexo)
Formato: O que / Onde / Depende de / Reutiliza / Pronto quando.
Tasks paralelizáveis marcadas com [P] para sub-agents.

## Não fazer
O que está explicitamente fora do escopo. Listar com referência à spec futura quando aplicável.

## Skills a consultar
Quais skills devem ser lidas antes de implementar.

## Notas
Decisões técnicas, alternativas consideradas, referências.

## Verificação pós-implementação
Checklist resumido para fechar a spec.

--- Seções adicionais (conforme tipo de feature) ---

## *Requisitos Não-Funcionais
Performance, segurança, escalabilidade.

## *Data Model
Entidades, campos, relações.

## *API Contract
Endpoints, request/response examples, error codes.

## *Edge Cases
Cenários de borda documentados explicitamente.
```

Os IDs numerados (RF-001) são importantes: o modelo pode referenciar `// Implements RF-003 from Spec: Checkout Flow` em comentários no código, criando um vínculo buscável entre implementação e requisito.

## Manutenção do índice

O ponto fraco do padrão é que o índice é um artefato manual. Se alguém cria uma spec e não atualiza o índice, o modelo não sabe que ela existe.

Mitigações práticas:

**PR template com checklist.** Adicione ao template de PR do repositório um item: "Se esta PR implementa ou altera uma spec, o `SPECS_INDEX.md` foi atualizado?". Simples, sem automação, depende de disciplina.

**CI check.** O `scripts/verify.sh` do framework inclui 3 checks de integridade:
- Check 14: toda spec ativa tem entrada no SPECS_INDEX (ativo por padrão)
- Check 14b: toda entrada no SPECS_INDEX aponta para arquivo que existe (ativo por padrão)
- Check 15: specs em `done/` não têm status `rascunho` (comentado — descomentar quando aplicável)
- Check 16: specs com breakdown têm STATE.md (comentado — descomentar quando aplicável)

Se uma spec nova aparece sem entrada no índice, ou o índice aponta para arquivo que não existe, o CI falha.

**Automação via skill.** A skill `/spec` cria spec + entrada no índice automaticamente. A skill `/backlog-update` mantém o backlog sincronizado e atualiza STATUS.md quando uma spec é movida para `concluída`.

## Setup automatizado

O framework inclui uma skill `/setup-framework` que automatiza a implantação em qualquer projeto existente:

1. **Analisa** o projeto (stack, estrutura, package.json, etc.)
2. **Pergunta** nome, domínio, modelo de specs (repo/externo/híbrido), fases do roadmap, skills desejadas
3. **Gera** todos os arquivos: CLAUDE.md, SPECS_INDEX.md, templates, skills, scripts, docs
4. **Adapta** automaticamente ao stack detectado (Node, Python, Go, Ruby, etc.)

Pode ser instalada como skill pessoal (`~/.claude/skills/`) ou distribuída para o time via plugin do Claude Code.

## Quando este padrão não compensa

Se o projeto tem menos de 10 specs e todas cabem confortavelmente no contexto do modelo, o índice adiciona burocracia sem benefício real. Nesse caso, uma instrução simples no `CLAUDE.md` apontando para o diretório `specs/` é suficiente.

O ponto de inflexão geralmente está em torno de 15-20 specs, ou quando o conteúdo total ultrapassa ~5.000 linhas. A partir daí, a fase de discovery começa a competir com o espaço de contexto que o modelo precisa para gerar código.

## Resumo dos componentes

| Componente | O que é | Onde vive |
| --- | --- | --- |
| `SPECS_INDEX.md` | Catálogo leve com metadados, resumos e owner. O modelo lê inteiro a cada sessão. | Raiz do repo |
| `specs/` (ou fonte externa) | Specs completas. O modelo abre sob demanda, apenas a relevante. | Repo, submodule, ou Notion |
| `specs/done/` | Specs concluídas. Arquivo histórico, fora do fluxo ativo. | Dentro de specs/ |
| `CLAUDE.md` (trecho de specs) | Instrução explícita para o modelo seguir o fluxo: índice → classificar → spec → implementação. | Raiz do repo |
| Mapa de dependências | Tabela no final do SPECS_INDEX mostrando relações entre specs. | Dentro do SPECS_INDEX |
| Seção de dependências por spec | Dentro de cada spec, lista o que usa de outras specs e qual seção. | Dentro de cada spec |
| Seção "Não fazer" | Boundaries explícitos de escopo negativo. Previne over-implementation pelo modelo. | Dentro de cada spec |
| Critérios de aceitação | Condições verificáveis que alimentam o ciclo TDD e a verificação pós-implementação. | Dentro de cada spec |
| Breakdown de tasks | Tasks com ordem de execução, dependências e marcador [P] para paralelismo. | Dentro de cada spec (Grande/Complexo) |
| Resumo por entrada | 1-2 frases com termos técnicos. Permite ao modelo descartar specs irrelevantes sem abri-las. | Dentro do SPECS_INDEX |
| Status por entrada | Previne implementação de specs em `rascunho` ou `descontinuada`. | Dentro do SPECS_INDEX |
| Owner por entrada | Responsável pela spec (opcional). Útil para times com múltiplos PMs/leads. | Dentro do SPECS_INDEX |
| IDs de requisitos (RF-XXX) | Rastreabilidade bidirecional entre código e especificação via grep. | Dentro de cada spec + comentários no código |
| Auto-sizing | Tabela de 4 tamanhos (Pequeno/Médio/Grande/Complexo) que define nível de cerimônia. | CLAUDE.md |
| Context budget | Limite de ~60-70% do context window por sessão, por modelo. Previne degradação de qualidade. | CLAUDE.md |
| STATE.md | Memória persistente entre sessões (decisões, blockers, lições, ideias adiadas). | specs/STATE.md |
| Design doc | Decisões arquiteturais separadas da spec. Obrigatório para Complexo, recomendado para Grande. | specs/{id}-design.md |
| Scope guardrail | 3 regras para não sair do escopo (não corrigir bugs alheios, não implementar ideias). | CLAUDE.md |
| Fluxo RPI | Research → Plan → Implement em sessões separadas (Grande/Complexo). | CLAUDE.md |
| `/spec` | Skill que cria spec + entrada no índice automaticamente, classificando complexidade. | Slash command |
| `/setup-framework` | Skill que analisa projeto e gera toda a estrutura de arquivos do framework automaticamente. | Slash command |
| `scripts/verify.sh` | CI check que valida integridade estrutural: índice ↔ filesystem + testes + segurança. | Raiz do repo / pipeline CI |
