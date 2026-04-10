<!-- framework-tag: v2.37.2 framework-file: docs/SKILLS_GUIDE.md -->
# Skills Guide — Catálogo de skills

> Skills formam a camada de *expertise* do harness — checklists por dominio que o Claude Code consulta antes de agir.
> Referencia descritiva de todas as skills: o que cada uma faz, quando usar e o que produz.
>
> Para dependencias e ordem de execucao, consultar `docs/SKILLS_MAP.md`.

---

## quick (`/quick`)

**O que é:** Fast-path para correções triviais que não justificam spec. Valida critérios (typo, bump, config, fix de 1-2 linhas sem lógica de negócio) e segue fluxo simplificado: implementar → testar → verify.sh → commit → PR.

**Quando usar:**
- Typo, fix de texto, ajuste de mensagem
- Bump de dependência, ajuste de config
- Fix trivial de 1-2 linhas sem nova lógica de negócio

**Output:** Mudança commitada e PR aberto. Sem spec, sem STATE.md, sem DoD completo.

---

## spec-driven

**O que é:** Skill obrigatória que define o fluxo completo de desenvolvimento — da demanda ao código. Classifica a complexidade do item (Pequeno/Médio/Grande/Complexo) e determina o nível de cerimônia (spec light, spec completa, design doc, research).

**Quando usar:**
- Antes de implementar qualquer feature, bugfix ou refatoração
- Ao iniciar nova sessão de desenvolvimento
- Ao receber demanda sem spec associada

**Output:** Classificação de complexidade, fluxo de execução definido (backlog → spec → plan → implementação), e gate de validação pré-implementação.

---

## spec-creator (`/spec`)

**O que é:** Cria nova spec a partir do `TEMPLATE.md`, registra no `SPECS_INDEX.md` e no backlog. Suporta modo repo (arquivos locais) e modo Notion (via MCP). Aceita `--from {jira-key|url}` para pré-preencher a partir de issues externas.

**Quando usar:**
- Antes de implementar qualquer feature, bugfix ou refatoração (gate obrigatório)
- Ao formalizar item do backlog em spec completa
- Ao registrar decisão técnica relevante como spec de referência

**Output:** Arquivo `.claude/specs/{ID}-spec.md` (ou página no Notion) com contexto, requisitos funcionais, critérios de aceitação e breakdown de tasks.

---

## discuss (`/discuss`)

**O que é:** Fase conversacional estruturada antes da spec. Faz scout no codebase, identifica gray areas (ambiguidades, decisões técnicas, dependências, conflitos), guia deep-dive em cada uma e gera spec completa ao final com decisões incorporadas. Substitui o salto direto de "quero X" para `/spec` quando há incerteza.

**Quando usar:**
- Feature com 2+ interpretações possíveis da solução técnica
- Decisões técnicas não triviais (escolha de lib, pattern, schema)
- Domínio novo (primeira feature nessa área do projeto)
- Escopo vago onde critérios de aceitação ainda não estão claros

**Output:** Spec gerada (repo ou Notion) com decisões consolidadas, gray areas exploradas documentadas como "Notas — Decisões do /discuss", e gray areas não exploradas marcadas como `{A DETALHAR}` com impacto documentado.

---

## prd-creator (`/prd`)

**O que é:** Cria um PRD (Product Requirements Document) para documentar análise de causa raiz antes de criar specs técnicas. Um PRD pode gerar múltiplas specs. Suporta modo repo, Notion e exportação para copy-paste.

**Quando usar:**
- Ao iniciar análise de nova demanda antes de criar specs técnicas
- Quando há múltiplas causas possíveis que precisam de investigação estruturada
- Ao documentar decisão de produto que vai gerar várias specs

**Output:** Arquivo `.claude/prds/{ID}-prd.md` (ou página no Notion) com análise de causa raiz, hipóteses priorizadas e specs técnicas derivadas.

---

## research

**O que é:** Protocolo de investigação estruturada do codebase antes de planejar. Investiga 6 eixos (stack, código existente, patterns de reuso, dependências, riscos, decisões arquiteturais) e produz achados que alimentam a spec e o execution-plan.

**Quando usar:**
- Item classificado como Grande ou Complexo
- Codebase existente com patterns desconhecidos (brownfield)
- Múltiplas soluções possíveis com decisão arquitetural necessária

**Output:** Arquivo `.claude/specs/{ID}-research.md` com achados estruturados, riscos identificados e decisão arquitetural recomendada.

---

## execution-plan

**O que é:** Plano de execução obrigatório para itens Médio+. Decompõe a spec em partes, mapeia todos os arquivos que serão tocados, deriva waves de execução respeitando dependências, e define briefings para sub-agents se o projeto os usa.

**Quando usar:**
- Item classificado como Médio, Grande ou Complexo
- Batch de 2+ itens que afetam 6+ arquivos ou 3+ domínios no total
- Antes de despachar tasks para sub-agents

**Output:** Arquivo `.claude/specs/{ID}-plan.md` com mapa de arquivos, decomposição em partes, waves de execução e briefings.

---

## context-fresh

**O que é:** Protocolo de orquestração por sub-agents. Despacha tasks do execution-plan para sub-agents com contexto limpo (briefing focado), evitando context rot na sessão principal. Define waves de paralelização e rastreia completion.

**Quando usar:**
- Item Médio+ com execution-plan pronto e projeto usando sub-agents
- Sessão principal atingindo ~40-50% do context budget
- Spec com breakdown de tasks e grafo de dependências preenchido

**Output:** Briefings por task despachados para sub-agents, waves de execução executadas, completion log preenchido.

---

## map-codebase (`/map-codebase`)

**O que é:** Analisa o projeto em 4 dimensões paralelas (stack tecnológico, arquitetura, convenções de código, concerns ativos) e gera mapa estruturado. Útil para onboarding em projetos existentes e para o Claude iniciar sessão em repositório desconhecido.

**Quando usar:**
- Onboarding em projeto existente (primeiro contato)
- Início de sessão após longa ausência
- Antes de planejar feature em área desconhecida do código

**Output:** Mapa estruturado na conversa, ou arquivo `.claude/CODEBASE_MAP.md` com `--save`.

---

## resume (`/resume`)

**O que é:** Protocolo de retomada estruturada após crash, timeout ou context limit. Lê `STATE.md` e o execution-plan da task em andamento, apresenta resumo do estado anterior (tasks concluídas vs pendentes, fase atual) e propõe próximo passo.

**Quando usar:**
- Ao iniciar sessão nova após crash ou timeout da sessão anterior
- Quando a sessão anterior atingiu context limit no meio de uma task
- Ao retomar trabalho após pausa longa com STATE.md ativo

**Output:** Resumo da sessão anterior (fase, tasks concluídas, próximo passo previsto) e confirmação antes de retomar.

---

## backlog-update (`/backlog-update`)

**O que é:** Atualiza o backlog do projeto — adiciona, conclui ou edita itens seguindo o padrão de classificações (Sev, Impacto, Tipo, Est, Deps) definido no CLAUDE.md. Suporta modo repo (`backlog.md`) e modo Notion.

**Quando usar:**
- Ao adicionar novo item ao backlog do projeto
- Ao marcar item como concluído após entrega
- Ao descartar item com justificativa

**Output:** Backlog atualizado com item classificado, ou item movido para Concluídos/Descartados.

---

## bug-investigation (`/bug-report`)

**O que é:** Guia times N2/N3 numa investigação profunda de bugs antes de escalar para engenharia. Produz pacote completo: problema validado, causa raiz, evidências, comportamento esperado vs real, e passos de reprodução.

**Quando usar:**
- Ao receber relato de bug que precisa de investigação antes de escalar
- Quando o time N2/N3 precisa documentar causa raiz e evidências completas
- Ao criar relatório estruturado para o time de engenharia

**Output:** Relatório de bug em `.claude/bugs/{ID}-bug.md` (ou página no Notion/Jira) com análise completa e passos de reprodução.

---

## definition-of-done

**O que é:** Checklist de verificação final antes de finalizar qualquer entrega. Cobre verificação automatizada (`verify.sh`), planejamento (spec, plan, STATE.md), testes (cobertura, qualidade), segurança (decisões de design) e documentação.

**Quando usar:**
- Antes de finalizar qualquer entrega (feature, bugfix, refatoração)
- Ao abrir PR — verificar todos os itens aplicáveis antes de solicitar review
- Ao concluir item do backlog e mover spec para `done/`

**Output:** Checklist verificado com todos os itens aplicáveis marcados, entrega considerada completa.

---

## testing

**O que é:** Guia de testes por nível da pirâmide (unitários, integração, E2E). Define quando usar cada tipo, padrões de mock, cobertura mínima e como escrever testes que testam comportamento, não implementação.

**Quando usar:**
- Ao escrever testes para nova feature, bugfix ou refatoração
- Ao modificar testes existentes para refletir novo comportamento
- Ao revisar cobertura de testes de um módulo

**Output:** Testes escritos nos tipos corretos (unit/integração/E2E), cobertura adequada para a complexidade do código.

---

## golden-tests

**O que é:** Protocolo de snapshot testing para endpoints HTTP e componentes UI. Captura a resposta completa como golden file e detecta qualquer desvio em execuções futuras (regressão vs mudança intencional). Inclui custom serializers para normalizar dados dinâmicos (timestamps, UUIDs).

**Quando usar:**
- Endpoints HTTP: capturar response completo (status + body + headers relevantes)
- Componentes UI: capturar render output (DOM tree ou markup)
- APIs internas: capturar return shape de funções públicas

**Output:** Arquivos golden em `{tests}/golden/` com snapshots normalizados, testes que detectam regressões automaticamente.

---

## code-quality

**O que é:** Checklist de qualidade de código focado em duplicação, extração de helpers e padrões repetidos. Identifica funções e constantes de negócio duplicadas entre arquivos, sugere extração para módulos compartilhados.

**Quando usar:**
- Ao criar novo arquivo ou módulo
- Ao modificar mais de 1 arquivo na mesma entrega
- Antes de todo commit que altera arquivos de código

**Output:** Lista de duplicações encontradas com sugestão de extração, confirmação de que não há constantes de negócio espalhadas.

---

## security-review

**O que é:** Checklist de segurança pré-commit para quem está escrevendo código. Cobre autenticação/autorização, SQL injection, IDOR, rate limiting, secrets e webhooks. Diferente do agent `security-audit` (que audita o sistema todo), esta skill é guidance durante implementação.

**Quando usar:**
- Ao implementar novo endpoint ou rota
- Ao modificar lógica de autenticação ou autorização
- Antes de commitar código que toca middleware, service ou model crítico

**Output:** Checklist de segurança verificado por tipo de mudança (nova rota, endpoint que modifica dados, autenticação), identificação de vulnerabilidades antes do commit.

---

## dependency-audit

**O que é:** Auditoria de dependências antes de instalar ou atualizar pacotes. Verifica vulnerabilidades conhecidas, versões desatualizadas, licenças compatíveis, dependências abandonadas e impacto no bundle size.

**Quando usar:**
- Ao adicionar nova dependência (`npm install`, `pip install`, `go get`)
- Ao fazer upgrade de versão (minor ou major)
- Ao revisar PR que altera lock file

**Output:** Relatório de vulnerabilidades, licenças, versões e impacto no bundle, decisão documentada sobre a dependência.

---

## dba-review

**O que é:** Checklist de revisão de banco de dados para migrations, schema e queries. Verifica tipos consistentes, índices adequados para queries, migrations seguras para produção (sem lock em tabelas grandes), integridade referencial e performance.

**Quando usar:**
- Ao criar ou alterar tabelas (`CREATE TABLE`, `ALTER TABLE`)
- Ao criar migrations
- Ao adicionar queries com JOIN, WHERE em colunas sem índice

**Output:** Checklist de schema, índices e migrations verificados, confirmação de que a mudança é segura para produção.

---

## api-testing

**O que é:** Checklist de validação de contratos de API REST/GraphQL. Cobre status codes corretos por operação, response schemas, headers obrigatórios, paginação, idempotência e contract testing com schema publicado.

**Quando usar:**
- Ao criar ou modificar endpoints REST/GraphQL
- Ao integrar com API externa (consumer side)
- Ao publicar API para terceiros (provider side)

**Output:** Checklist de status codes, schemas e headers verificados, contrato de API validado contra schema publicado.

---

## mock-mode

**O que é:** Guia para configuração do modo de simulação de serviços externos em desenvolvimento e testes. Define o que o mock mode substitui (APIs externas: pagamento, email, IA) e o que não substitui (banco, migrations). Inclui setup e checklist de cobertura.

**Quando usar:**
- Ao criar endpoint que chama serviço externo (pagamento, IA, email, SMS)
- Ao adicionar nova integração que precisa de simulação local
- Ao revisar se o mock mode cobre a plataforma toda

**Output:** Mock mode configurado e documentado, todos os serviços externos simuláveis cobertos.

---

## logging

**O que é:** Padrões de logging e error handling. Define níveis de log (error/info/warn), formato obrigatório com prefixo `[MODULE]`, o que nunca logar (dados sensíveis, stack traces em produção) e padrões de try/catch para serviços externos.

**Quando usar:**
- Ao adicionar logs em rota, serviço ou módulo
- Ao escrever try/catch ou tratar erros
- Ao integrar com serviço externo (que pode falhar)

**Output:** Logs padronizados com prefixo e dados estruturados, error handling com fallback documentado.

---

## docs-sync

**O que é:** Checklist de sincronização de documentação após entregas. Mapeia quais docs precisam ser atualizados por tipo de mudança (nova rota, feature visível, fix de segurança, mudança de stack) e fornece script de verificação automatizada pré-commit.

**Quando usar:**
- Ao finalizar qualquer entrega antes de abrir PR
- Ao adicionar nova feature visível ao usuário
- Quando alterar fluxo, endpoint, schema ou convenção documentada

**Output:** Documentação sincronizada com o código, matriz de impacto verificada, nenhum doc desatualizado no PR.

---

## ux-review

**O que é:** Checklist de revisão de UX para telas, componentes visuais e fluxos do usuário. Verifica design system (fontes, cores, tokens), acessibilidade, estados de loading/erro/vazio, responsividade e fluxos críticos (auth, checkout, onboarding).

**Quando usar:**
- Ao criar nova tela ou componente visual
- Ao modificar fluxo do usuário (auth, compra, onboarding, export)
- Ao fazer redesign ou ajuste visual

**Output:** Checklist de UX verificado por tipo de mudança, componente aprovado para entrega.

---

## seo-performance

**O que é:** Checklist de SEO e Core Web Vitals para páginas públicas. Cobre meta tags obrigatórias (Open Graph, Twitter Card), structured data (JSON-LD), Core Web Vitals (LCP, CLS, INP), e acessibilidade básica. Para auditoria completa, invocar agent `seo-audit`.

**Quando usar:**
- Ao criar ou modificar página pública (landing, blog, docs públicos)
- Ao adicionar nova dependência no frontend (verificar impacto no bundle)
- Ao fazer deploy para produção (validação pré-deploy)

**Output:** Checklist de SEO e performance verificado, páginas públicas com meta tags completas e Core Web Vitals dentro do target.

---

## Skills customizadas do projeto

{Adaptar: adicionar skills específicas do domínio do projeto aqui. Cada skill deve ter: nome, O que é (1-2 frases), Quando usar (2-3 bullets), Output (1 linha).}
