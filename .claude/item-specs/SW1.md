# SW1 — Delta markers para brownfield

**Contexto:** specs de features novas e specs de alterações em código existente têm o mesmo formato hoje. O Claude precisa inferir o que criar vs modificar vs remover — o que aumenta o risco de sobrescrever código existente ou criar duplicatas.

**Abordagem:** adicionar marcadores `[ADDED]` / `[MODIFIED]` / `[REMOVED]` por RF, inline na linha do requisito. Formato escolhido: marcador no início da linha de RF, opcional (specs greenfield puras não precisam):

```markdown
## Requisitos Funcionais

- [ADDED] RF-001 — novo endpoint POST /users/invite
- [MODIFIED] RF-002 — expandir UserService.create() para aceitar campo `invited_by` → afeta: `services/user.ts:45`
- [REMOVED] RF-003 — remover endpoint legado GET /users/legacy
```

Referência de arquivo é opcional mas recomendada para `[MODIFIED]` e `[REMOVED]`.

**Impacto no framework:**

| Arquivo | Mudança | Estratégia |
|---------|---------|-----------|
| `specs/TEMPLATE.md` | Adicionar nota de uso dos marcadores na seção RFs | `⚠️ Migrável` — update-framework oferece via structural merge |
| `skills/spec-creator/SKILL.md` | Perguntar ao dev se a feature é brownfield; se sim, instruir a classificar cada RF | `⚠️ Migrável` |
| `skills/spec-driven/README.md` | Instruir o Claude a ler marcadores ao implementar — `[MODIFIED]` = localizar código existente antes de editar, `[REMOVED]` = verificar impacto antes de deletar | `⚠️ Migrável` |
| `skills/setup-framework/templates/*` | Espelhar todas as mudanças acima | sync obrigatório |

**Impacto em projetos downstream:**
- Specs existentes sem marcadores continuam funcionando — marcadores são aditivos
- Projetos que não atualizarem ficam com spec-creator sem a pergunta brownfield — funcional mas sem orientação
- O Claude que implementar specs com marcadores precisa da versão atualizada do spec-driven para saber interpretá-los

**Critérios de aceitação:**
- [ ] `specs/TEMPLATE.md` documenta os marcadores com exemplo
- [ ] spec-creator detecta feature brownfield (pergunta ao dev ou infere da descrição) e orienta classificação por RF
- [ ] spec-driven instrui o Claude a: para `[MODIFIED]` → localizar o código existente primeiro; para `[REMOVED]` → listar impactos antes de deletar
- [ ] specs sem marcadores continuam funcionando sem erro
- [ ] sources e templates em sincronia

**Restrições:** marcadores são opcionais — não bloquear criação de spec se o dev não usar. Specs greenfield puras não precisam de marcadores.
