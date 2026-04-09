# Task Checklist — claude-code-framework

> Carregado automaticamente pelo Claude em toda sessão de desenvolvimento do framework.
> Cobre os pontos críticos que qualquer implementação deve verificar antes de considerar uma tarefa concluída.
>
> **NAO distribuído para projetos** — este arquivo é interno do repo do framework (não está no MANIFEST.md).

---

## 1. Source ↔ template em sincronia

Todo arquivo distribuído existe em dois lugares: **source** (raiz) e `skills/setup-framework/templates/`. Ao editar qualquer source, copiar para o template correspondente imediatamente. Nunca editar só um lado.

```bash
bash scripts/check-sync.sh  # valida sincronia de todos os arquivos
```

## 2. MANIFEST.md atualizado

Ao adicionar ou remover qualquer arquivo distribuído, registrar no MANIFEST com path no projeto, template source e estratégia (overwrite/structural/manual/skip). Consultar MANIFEST.md antes de qualquer adição.

## 3. Setup E update cobertos

Toda mudança deve funcionar nos dois fluxos:

- **`/setup-framework`** (`skills/setup-framework/SKILL.md`): projetos novos recebem a funcionalidade?
- **`/update-framework`** (`skills/update-framework/SKILL.md`): projetos existentes são notificados ou migrados?

Se a mudança adiciona arquivo novo: setup deve copiá-lo; update deve detectar que está faltando e informar.
A seção "5b. Auditoria de completude" deve ser idêntica entre setup e update — ao adicionar check em um, aplicar no outro.

## 4. Dual-mode (repo + Notion)

`spec-creator` e `backlog-update` operam em dois modos, detectados por `## Integracao Notion (specs)` no CLAUDE.md do projeto:

- **Repo mode**: arquivos locais (`.claude/specs/`, `.claude/specs/backlog.md`)
- **Notion mode**: MCP Notion (database de specs, propriedades de página)

Qualquer mudança nessas skills deve funcionar nos dois modos. Se a mudança cria ou busca artefatos (specs, tasks, itens de backlog), verificar o comportamento em cada modo.

## 5. Projetos downstream: single-repo e monorepo

Este framework é distribuído para projetos reais de outras pessoas. Ao implementar qualquer mudança, considerar:

**Single-repo**: estrutura plana, CLAUDE.md único na raiz. Cenário mais simples.

**Monorepo**: hierarquia pode ser arbitrariamente profunda (`platform/service/module/...`). Cada nível pode ter seu próprio:
- `CLAUDE.md` com regras de stack (L0 = raiz, L2+ = sub-projetos)
- `.claude/skills/` com customizações locais
- `.claude/agents/`
- `docs/`
- `.claude/specs/` com specs locais
- `scripts/verify.sh` próprio

Skills que criam ou buscam artefatos devem considerar: estou operando na raiz ou em um sub-projeto? Se ambíguo, perguntar ao usuário ou inferir de `## Monorepo` no CLAUDE.md L0.

Customizações preservadas pela estratégia `structural` nunca devem ser sobrescritas por mudanças do framework.

## 6. Backlog local vs remoto

- **Local** (`.claude/specs/backlog.md`): markdown no repo — sempre presente
- **Notion** (database remota): via MCP — presente só se `## Integracao Notion` configurado

Skills que operam no backlog devem funcionar nos dois casos.

## 7. Docs e CLAUDE.template.md ao finalizar

Qualquer alteração de fluxo, comportamento ou arquivo distribuído pode tornar docs ou CLAUDE.template.md desatualizados. Revisar obrigatoriamente ao finalizar:

- [ ] `docs/SKILLS_MAP.md` — skill ou agent novo aparece?
- [ ] `docs/WORKFLOW_DIAGRAM.md` — fluxo mudou?
- [ ] `docs/QUICK_START.md` — passos afetados?
- [ ] `docs/SPEC_DRIVEN_GUIDE.md` — guia de workflow desatualizado?
- [ ] `CLAUDE.template.md` — seções de skills/agents desatualizadas?
- [ ] Dois mirrors: `skills/setup-framework/templates/CLAUDE.template.md` e `skills/setup-framework/templates/CLAUDE.md`
- [ ] `MANIFEST.md` — arquivo novo/removido registrado?
