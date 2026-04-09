# MO8 — NPX installer

**Contexto:** o onboarding atual exige clonar o repo e rodar `./scripts/install-skills.sh`. Todo concorrente (GSD, cc-sdd, OpenSpec, Spec Kit) usa `npx` — uma linha sem clone. A barreira de entrada é maior do que precisa ser.

**Abordagem:** publicar o framework no npm como pacote `claude-code-framework`. O binário `npx claude-code-framework@latest` executa o equivalente ao `install-skills.sh` atual:

1. Baixa a versão mais recente do pacote
2. Copia skills de gestão (`setup-framework`, `update-framework`) para `~/.claude/skills/`
3. Exibe mensagem de sucesso com próximos passos (`/setup-framework` no projeto)

O `install-skills.sh` continua existindo para quem clonou o repo — npx é alternativa, não substituto.

**Estrutura do pacote npm:**

```
package.json          ← name: "claude-code-framework", bin: { "claude-code-framework": "bin/install.js" }
bin/install.js        ← script Node que copia os arquivos para ~/.claude/skills/
skills/               ← setup-framework/ e update-framework/ incluídos no pacote
```

**Critérios de aceitação:**
- [ ] `package.json` na raiz com `name`, `version` (sincronizado com `VERSION`), `bin`, `files`
- [ ] `bin/install.js` copia `setup-framework` e `update-framework` para `~/.claude/skills/`
- [ ] `npx claude-code-framework@latest` funciona sem clone prévio
- [ ] versão no npm e versão no `VERSION` sempre iguais — processo de release atualiza ambos
- [ ] `install-skills.sh` continua funcionando (não é removido)
- [ ] README atualizado com `npx` como método primário de instalação

**Impacto no processo de release:**
- Adicionar `npm publish` ao checklist de release (após `git push --tags`)
- Ou configurar GitHub Action para publicar automaticamente ao criar tag `vX.Y.Z`

**Restrições:** não incluir o repo inteiro no pacote npm — só `bin/install.js` + `skills/setup-framework/` + `skills/update-framework/`. Usar campo `files` no `package.json` para controlar o que vai no pacote.
