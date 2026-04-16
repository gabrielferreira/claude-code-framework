<!-- framework-tag: v2.46.2 framework-file: skills/research/README.md -->
# Skill: Research — Investigação estruturada antes do planning

> Protocolo para investigar o codebase antes de planejar e implementar.
> Produz achados estruturados que alimentam a spec, o design doc e o execution-plan.

## Quando usar

- Item classificado como **Grande** ou **Complexo**
- **Brownfield:** codebase existente com patterns desconhecidos
- **Domínio novo** para o agente (nunca trabalhou nesta área do projeto)
- Múltiplas soluções possíveis, decisão arquitetural necessária
- Fase `research` no STATE.md

## Quando NÃO usar

- **Pequeno/Médio** com escopo claro e stack conhecida
- **Greenfield** com stack definida e sem dependências externas
- Task de refatoração onde o código-alvo já é entendido
- Research anterior ainda válido (verificar se `{id}-research.md` já existe e está atualizado)

## Pré-requisitos

- [ ] Item no backlog com ID definido
- [ ] Complexidade classificada (spec-driven) como Grande ou Complexo
- [ ] STATE.md atualizado com fase `research`

## Protocolo de research

Investigar os 6 eixos abaixo. Nem todos se aplicam a toda feature — pular os irrelevantes, mas documentar que foram avaliados.

### Eixo 1 — Stack e convenções

Ler `CLAUDE.md`, `PROJECT_CONTEXT.md`, `docs/ARCHITECTURE.md` (se existem). Identificar:

- Stack principal (linguagem, framework, runtime)
- Convenções de naming, estrutura de pastas, padrão de módulos
- Padrões de erro, logging, validação
- Regras de negócio relevantes documentadas

### Eixo 2 — Código existente

Explorar os arquivos que a feature vai tocar ou que estão próximos. Identificar:

- Funções e módulos relevantes (o que já existe)
- Hook points (onde a nova funcionalidade se encaixa)
- Contratos internos (interfaces, tipos, schemas que devem ser respeitados)
- Testes existentes que cobrem a área

### Eixo 3 — Patterns de reuso

Buscar funcionalidade similar já implementada no projeto:

- Se existe: documentar o pattern para reutilizar (arquivo, função, abordagem)
- Se não existe: documentar que será necessário criar novo
- Se existe mas é inadequado: documentar por que e o que fazer diferente

### Eixo 4 — Dependências e integrações

Listar APIs externas, bibliotecas, serviços que a feature vai consumir:

- Versões atuais e limites conhecidos
- Autenticação e rate limits
- Formato de dados (request/response)
- Documentação relevante (URLs, exemplos)

### Eixo 5 — Riscos e restrições

Identificar o que pode dar errado:

- Edge cases conhecidos
- Limites de performance (queries pesadas, renderização, payload)
- Restrições de segurança (auth, CORS, sanitização)
- Migrations necessárias (banco, config, infra)
- Backward compatibility (APIs públicas, contratos com outros serviços)

### Eixo 6 — Gaps de conhecimento

Listar o que NÃO conseguiu descobrir e precisa de input humano:

- Decisões de negócio pendentes
- Acesso a serviços/ambientes que não conseguiu verificar
- Ambiguidades na spec ou no código que requerem esclarecimento

## Formato de saída

Salvar em `.claude/specs/{id}-research.md`:

```markdown
# Research — {ID}

> Spec relacionada: {ID da spec, se já existe, ou "a ser criada após research"}
> Data: YYYY-MM-DD
> Descartável: sim — este arquivo é referência, não artefato permanente

## Contexto da investigação

{1-2 frases sobre o que foi investigado e por quê}

## Achados

### Stack e convenções
- {achado 1}
- {achado 2}

### Código existente relevante

| Arquivo | O que faz | Relevância para a feature |
|---------|-----------|--------------------------|
| `path/to/file` | {função/módulo} | {como afeta a feature} |

### Patterns de reuso
- {pattern existente} em `path` — reutilizar para {parte da feature}
- {Ou: "Nenhum pattern similar encontrado — criar novo"}

### Dependências e integrações

| Dependência | Versão | Uso previsto | Risco |
|-------------|--------|-------------|-------|
| {lib/api} | {v} | {o que usar} | {risco ou "nenhum"} |

### Riscos identificados

| Risco | Probabilidade | Impacto | Mitigação sugerida |
|-------|--------------|---------|-------------------|
| {risco} | {alta/média/baixa} | {alto/médio/baixo} | {sugestão} |

### Gaps de conhecimento
- {O que não conseguiu descobrir — requer input humano}
- {Ou: "Nenhum gap — investigação completa"}

## Decisões sugeridas

| # | Questão | Alternativas | Recomendação | Motivo |
|---|---------|-------------|--------------|--------|
| 1 | {questão arquitetural} | {A vs B} | {sugestão} | {motivo} |

## Próximos passos
- [ ] Resolver gaps com input humano (se houver)
- [ ] Criar/atualizar spec usando estes achados
- [ ] Criar design doc (se Complexo)
- [ ] Criar execution-plan referenciando este research
```

### Exemplo concreto

Para uma feature "Sistema de notificações por email" num projeto Node.js + PostgreSQL:

```markdown
# Research — NOTIF-001

> Spec relacionada: a ser criada após research
> Data: 2026-04-09
> Descartável: sim

## Contexto da investigação

Investigar como implementar notificações por email no projeto. O projeto já tem envio transacional
via SendGrid para reset de senha, mas não tem sistema de notificações configuráveis por usuário.

## Achados

### Stack e convenções
- Backend: Node.js + Express + TypeScript
- ORM: Prisma com PostgreSQL
- Jobs assíncronos: BullMQ com Redis (já configurado para processamento de imagens)
- Padrão de services: `src/services/{domain}.service.ts` com injeção via constructor

### Código existente relevante

| Arquivo | O que faz | Relevância |
|---------|-----------|-----------|
| `src/services/email.service.ts` | Wrapper SendGrid — `sendTransactional(to, template, data)` | Reutilizar para envio. Já tem retry e rate limit. |
| `src/jobs/image-processor.job.ts` | Job BullMQ com dead-letter queue | Pattern de job a seguir para fila de emails. |
| `prisma/schema.prisma` | Schema atual — User não tem preferences | Precisa de migration para NotificationPreference. |

### Patterns de reuso
- Job pattern em `image-processor.job.ts` — reutilizar para `email-notification.job.ts`
- Service pattern com DI — seguir para `notification.service.ts`
- SendGrid wrapper já pronto — não criar novo client

### Dependências e integrações

| Dependência | Versão | Uso previsto | Risco |
|-------------|--------|-------------|-------|
| @sendgrid/mail | 7.7.0 | Envio de emails | Rate limit: 100/s (suficiente) |
| bullmq | 4.12.0 | Fila de jobs | Já em uso, sem risco adicional |

### Riscos identificados

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Migration em tabela User (lock) | média | alto | Criar tabela separada NotificationPreference com FK |
| SendGrid template IDs hardcoded | baixa | médio | Usar env vars + fallback para template padrão |

### Gaps de conhecimento
- Quantos templates de email o produto quer? (afeta schema)
- Frequência de digest: diário, semanal, ou configurável?

## Decisões sugeridas

| # | Questão | Alternativas | Recomendação | Motivo |
|---|---------|-------------|--------------|--------|
| 1 | Tabela de preferences | A: Colunas na User / B: Tabela separada | B: Tabela separada | Evita lock na migration + extensível |
| 2 | Processamento | A: Síncrono no request / B: Fila BullMQ | B: Fila BullMQ | Pattern já existe no projeto, não bloqueia request |

## Próximos passos
- [ ] Resolver gaps: quantidade de templates e frequência de digest
- [ ] Criar spec NOTIF-001 usando estes achados
- [ ] Criar execution-plan referenciando este research
```

## Regras

1. **Research NÃO produz código.** Produz achados. Se durante a investigação encontrar um bug, registrar em STATE.md — não corrigir.
2. **Research NÃO toma decisões finais.** Sugere e documenta alternativas com prós/contras. A decisão é do usuário ou da sessão de planning.
3. **Output auto-contido.** Quem lê o `{id}-research.md` não precisa refazer a exploração. Se um achado depende de contexto, incluir o contexto.
4. **Limite de context budget:** se a research está consumindo >40% do context window, parar e salvar achados parciais. Marcar eixos incompletos como gaps.
5. **Funciona igual em repo mode e Notion mode.** Achados são salvos como arquivo local (`.claude/specs/{id}-research.md`) em ambos os casos — é arquivo descartável, não artefato permanente da spec.
6. **Não duplicar.** Se `{id}-research.md` já existe, ler e atualizar em vez de criar do zero. Marcar seções atualizadas com data.
7. **Scope mínimo.** Investigar o que é necessário para planejar a feature, não mapear o projeto inteiro. Focar nos eixos relevantes.

## Checklist

- [ ] Eixo 1: stack e convenções documentados
- [ ] Eixo 2: código existente relevante mapeado
- [ ] Eixo 3: patterns de reuso identificados (ou ausência documentada)
- [ ] Eixo 4: dependências e integrações listadas
- [ ] Eixo 5: riscos identificados com mitigações
- [ ] Eixo 6: gaps de conhecimento listados (ou "nenhum")
- [ ] Decisões sugeridas com alternativas
- [ ] Achados salvos em `.claude/specs/{id}-research.md`
- [ ] STATE.md atualizado (fase research → pronto para plan)
