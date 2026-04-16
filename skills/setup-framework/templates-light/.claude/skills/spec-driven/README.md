<!-- framework-tag: v2.49.0 framework-file: light:skills/spec-driven/README.md -->
<!-- framework-mode: light -->
# Skill: Spec-Driven Development — {NOME_DO_PROJETO}

> **OBRIGATÓRIA:** Ler ANTES de implementar qualquer feature, bug fix ou refatoração.

## Quando usar

- Antes de implementar qualquer feature, bugfix ou refatoração
- Ao iniciar nova sessão de desenvolvimento
- Ao receber demanda sem spec associada

## Quando NÃO usar

- Para exploração inicial ou spike técnico
- Para hotfix emergencial (criar spec após a entrega)

## Triagem: classificar antes de iniciar

> **Quick task:** Correções triviais (typo, bump, ajuste de config, fix de 1-2 linhas sem lógica de negócio nova) não precisam de spec. Implementar → testar → verify.sh → commit → PR. **Se toca lógica de negócio, não é trivial.**

Para tudo que não é quick task:

| Tamanho | Critério | Fluxo |
|---|---|---|
| **Pequeno** | ≤3 arquivos, sem nova abstração | Spec light → implementa → testa → commit |
| **Médio** | 4-10 arquivos, escopo claro | Spec completa → implementa sequencialmente → commit |

> Na dúvida, classificar para cima. Se aparecem >5 passos → Médio.

## Fluxo: da demanda ao código

1. **Consultar `SPECS_INDEX.md`** para localizar a spec relevante.
2. **Abrir APENAS a spec identificada.** Não ler todas.
3. **Verificar status:** `rascunho` → perguntar antes. `descontinuada` → NÃO implementar.
4. **Ao criar spec nova:** adicionar entrada no `SPECS_INDEX.md`.

## Validação pré-implementação

1. **Ler a spec** em `.claude/specs/`.
2. **Verificar o código atual** — confirmar que as premissas ainda valem.
3. **Listar divergências** — se algo mudou, atualizar a spec ANTES de implementar.
4. **Só então implementar.**

## Testes

{Se o projeto usa TDD (ver CLAUDE.md). Se não, seguir a política de testes do projeto.}

1. Ler critérios de aceitação da spec → definir cenários de teste.
2. Escrever testes → implementar → refatorar.

## Pós-implementação

1. Se implementou spec: marcar checkboxes, atualizar status para `concluída`, mover arquivo para `done/`.
   **Mover a entrada do SPECS_INDEX.md para SPECS_INDEX_ARCHIVE.md** (seção Concluídas).
   Se SPECS_INDEX_ARCHIVE.md não existe, criar com template do framework.
2. Atualizar backlog: `/backlog-update {ID} done`
3. Se spec descontinuada: **mover entrada para SPECS_INDEX_ARCHIVE.md** (seção Descontinuadas).
4. Atualizar STATE.md com status.

## Regras

1. **Spec é fonte de verdade.** Se spec diz X e código faz Y → reportar divergência.
2. **Um item por vez.** Completar ciclo inteiro antes do próximo.
3. **verify.sh obrigatório.** Sempre antes de commit.
4. **Definition of Done antes de fechar.** Aplicar `.claude/skills/definition-of-done/README.md`.
