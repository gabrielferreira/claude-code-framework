<!-- framework-tag: v2.33.0 framework-file: docs/SPEC_EXAMPLE.md -->
# FEAT-42 — Notificacoes por email quando spec muda de status

> Status: `aprovada`
> Prioridade: `media`
> Criada em: 2026-03-15

## Contexto

Atualmente, membros do time so descobrem que uma spec mudou de status ao abrir o backlog manualmente. Isso causa atrasos na comunicacao e tarefas que ficam bloqueadas sem que o responsavel saiba. Enviar notificacoes por email quando o status de uma spec muda resolve esse problema e melhora a visibilidade do progresso.

## Dependencias

| Spec | O que esta spec usa | Secao relevante |
|------|---------------------|-----------------|
| FEAT-30 | Sistema de autenticacao de usuarios | RF-002 (identificar destinatarios) |

## Requisitos Funcionais

- RF-001: O sistema deve enviar um email ao autor da spec quando o status mudar de qualquer valor para outro.
- RF-002: O sistema deve enviar email a todos os usuarios atribuidos a tasks da spec afetada.
- RF-003: O email deve conter: titulo da spec, status anterior, status novo, link direto para a spec, e timestamp da mudanca.
- RF-004: O usuario deve poder desativar notificacoes por email nas suas preferencias.

## Escopo

- [ ] Criar tabela `email_preferences` no PostgreSQL
- [ ] Implementar servico de envio de email via SendGrid
- [ ] Criar endpoint POST /api/specs/:id/status que dispara notificacao
- [ ] Adicionar tela de preferencias de notificacao no perfil do usuario
- [ ] Escrever testes unitarios e de integracao

## Criterios de aceitacao

1. Ao mudar status de uma spec via API, todos os usuarios associados recebem email em ate 30 segundos.
2. O email contem titulo, status anterior, status novo e link funcional para a spec.
3. Usuarios que desativaram notificacoes NAO recebem email.
4. Se o SendGrid estiver indisponivel, o sistema registra o erro no log e enfileira para retry (max 3 tentativas).
5. Testes cobrem os cenarios: envio com sucesso, usuario com notificacao desativada, falha no SendGrid com retry.

## Possiveis riscos

| Risco | Probabilidade | Impacto | Mitigacao |
|---|---|---|---|
| SendGrid fora do ar causa perda de notificacoes | media | alto | Implementar fila com retry e dead-letter queue para emails que falharam 3x |
| Volume alto de mudancas de status gera spam de emails | baixa | medio | Agrupar notificacoes em janela de 5 minutos (debounce) |
| Credenciais do SendGrid expostas em logs | baixa | alto | Usar variavel de ambiente, nunca logar payload completo do request |

## Arquivos afetados

| Arquivo | Tipo de mudanca |
|---|---|
| `src/services/email.service.ts` | Criar |
| `src/routes/specs.ts` | Modificar |
| `src/models/email-preferences.ts` | Criar |
| `migrations/20260315_email_preferences.sql` | Criar |
| `src/pages/profile/notifications.tsx` | Criar |
| `tests/email.service.test.ts` | Criar |
| `tests/specs-status.integration.test.ts` | Criar |

## Breakdown de tasks

### Grafo de dependencias

| Task | Depende de | Arquivos | Tipo | Paralelizavel? |
|------|-----------|----------|------|-----------------|
| T1 | — | `migrations/20260315_email_preferences.sql`, `src/models/email-preferences.ts` | implementacao | — (primeira) |
| T2 | T1 | `src/services/email.service.ts` | implementacao | Nao (depende de T1) |
| T3 | T2 | `src/routes/specs.ts` | implementacao | Sim [P] (sem overlap com T4) |
| T4 | T1 | `src/pages/profile/notifications.tsx` | implementacao | Sim [P] (sem overlap com T3) |
| T5 | T3, T4 | `tests/email.service.test.ts`, `tests/specs-status.integration.test.ts` | teste | Nao (integracao) |

### Ordem de execucao (waves)

```
Wave 1 (sequencial): T1 → T2
Wave 2 (paralela):   T3 [P] | T4 [P]  (sem overlap de arquivos)
Wave 3 (integracao): T5
```

### T1: Criar tabela e modelo de preferencias de email
- **O que:** Migration SQL + modelo TypeScript para `email_preferences`
- **Onde:** `migrations/20260315_email_preferences.sql`, `src/models/email-preferences.ts`
- **Tipo:** implementacao
- **Depende de:** — (primeiro)
- **Reutiliza:** Padrao de migrations existente do projeto
- **Pronto quando:** Migration roda sem erro e modelo exporta tipos corretos (RF-004)

### T2: Implementar servico de envio de email
- **O que:** Servico que envia email via SendGrid com retry e tratamento de erro
- **Onde:** `src/services/email.service.ts`
- **Tipo:** implementacao
- **Depende de:** T1 (precisa consultar preferencias)
- **Reutiliza:** —
- **Pronto quando:** Servico envia email e respeita preferencias do usuario (RF-001, RF-003)

### T3: Integrar notificacao na rota de mudanca de status [P]
- **O que:** Chamar servico de email quando status da spec mudar via API
- **Onde:** `src/routes/specs.ts`
- **Tipo:** implementacao
- **Depende de:** T2
- **Reutiliza:** Middleware de autenticacao existente
- **Pronto quando:** POST /api/specs/:id/status dispara email para usuarios associados (RF-001, RF-002)

### T4: Tela de preferencias de notificacao [P]
- **O que:** Pagina no perfil do usuario para ativar/desativar notificacoes
- **Onde:** `src/pages/profile/notifications.tsx`
- **Tipo:** implementacao
- **Depende de:** T1 (usa modelo de preferencias)
- **Reutiliza:** Componentes de formulario do design system
- **Pronto quando:** Usuario consegue desativar notificacoes e a preferencia persiste (RF-004)

### T5: Testes unitarios e de integracao
- **O que:** Testes cobrindo envio, opt-out e falha do SendGrid
- **Onde:** `tests/email.service.test.ts`, `tests/specs-status.integration.test.ts`
- **Tipo:** teste
- **Depende de:** T3, T4
- **Reutiliza:** Fixtures de teste existentes
- **Pronto quando:** Todos os cenarios dos criterios de aceitacao item 5 passam

## Nao fazer

- Notificacoes push ou in-app (escopo futuro)
- Customizacao do template do email pelo usuario
- Notificacoes para mudancas em bulk (importacao de specs)

## Skills a consultar

- [ ] `.claude/skills/testing/README.md`
- [ ] `.claude/skills/security-review/README.md`
- [ ] `.claude/skills/dba-review/README.md`

## Notas

- SendGrid foi escolhido por ja ser usado em outro modulo do projeto. Alternativa considerada: AWS SES (descartada por complexidade de setup).
- O debounce de 5 minutos (mitigacao de spam) pode ser implementado como melhoria futura se o volume justificar.

## Verificacao pos-implementacao

Antes de mover para `done/`:

- [ ] Cada criterio de aceitacao verificado no codigo (nao de memoria)
- [ ] Cada checkbox do escopo marcado `[x]` ou movido para novo item no backlog
- [ ] Status atualizado para `concluida` (ou `parcial — {detalhe}`)
- [ ] Testes passam
- [ ] Docs atualizados (ver `.claude/skills/docs-sync/README.md`)
- [ ] Contagem de testes atualizada se adicionou/removeu
