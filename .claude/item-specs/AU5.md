# AU5 — Skill `/babysit-pr`

**Contexto:** hoje o dev abre o PR via `/pr` e precisa monitorar manualmente: verificar se CI passou, ler comentários de reviewer, corrigir o que foi apontado, responder, aguardar nova rodada. Esse loop de babysitting é mecânico mas exige atenção constante — o dev fica interrompido por notificações ou atrasa porque esqueceu de checar. O framework já cobre a abertura do PR mas não o ciclo de vida depois.

**Abordagem:** skill `/babysit-pr` que roda em loop usando `gh` CLI para monitorar o PR atual e agir conforme o que chega:

### Loop principal

1. **Polling de status** via `gh pr view --json statusCheckRollup,reviews,comments,state`
2. **CI failing**: ler log (`gh run view --log-failed`), analisar causa, propor fix; se auto-fix habilitado, fazer commit e aguardar re-run
3. **Quality gate reprovado**: tratar igual a CI failing — ler output, corrigir, commitar
4. **Comentário de reviewer**: ler comentário, responder com raciocínio (contexto de spec se disponível) ou aplicar sugestão inline; marcar como resolved se resolvido
5. **Aprovação recebida**: notificar dev; se `auto_merge: true` configurado, fazer merge via `gh pr merge`
6. **Loop termina** quando: PR merged, PR fechado, dev interrompe (Ctrl+C), ou número máximo de iterações atingido (configurable)

### Configuração por projeto

Bloco `## PR Babysitting` no CLAUDE.md do projeto (gerado pelo setup, opcional):

```markdown
## PR Babysitting

| Config | Valor |
|---|---|
| Monitorar CI | true |
| Auto-fix CI | false (propõe, aguarda aprovação do dev) |
| Monitorar quality gates | true |
| Responder comentários | true |
| Auto-aplicar sugestões inline | false |
| Auto-merge quando aprovado | false |
| Intervalo de polling (segundos) | 60 |
| Máximo de iterações | 20 |
```

Defaults conservadores: propõe mas não age sem confirmação, não faz merge automático. Dev habilita o que quiser.

### Integração com `/pr`

Após `/pr` abrir o PR com sucesso, perguntar: "Quer que eu fique monitorando o PR? (`/babysit-pr`)"

### Monorepo

Configuração no CLAUDE.md L0 vale para todo o monorepo. Sub-projetos podem ter bloco próprio que sobrescreve o L0.

**Alternativas descartadas:**
- **Hook pós-push** — hook não tem contexto de qual PR monitorar; e o Claude Code não roda em background sem ser invocado
- **Agent dedicado** — agent é read-only por padrão; babysit precisa escrever (commits, comentários). Skill é o formato correto
- **Integração direta com GitHub Actions** — fora do escopo do framework (markdown-first, sem infraestrutura externa)

**Critérios de aceitação:**
- [ ] Skill `skills/babysit-pr/SKILL.md` criada com: frontmatter, seções obrigatórias, exemplos concretos de cada ação (CI fix, resposta a comentário, merge)
- [ ] Bloco `## PR Babysitting` gerado pelo setup com defaults conservadores e comentários explicativos
- [ ] Loop de polling implementado com intervalo configurável e máximo de iterações
- [ ] CI failure: lê log via `gh run view --log-failed`, analisa causa, propõe fix com diff antes de commitar
- [ ] Comentários: detecta comentários novos desde última iteração (evita re-processar antigos), responde com contexto
- [ ] Parada limpa: Ctrl+C ou PR merged/fechado encerra o loop com resumo do que foi feito
- [ ] update-framework detecta ausência do bloco e oferece adicionar ao CLAUDE.md existente
- [ ] MANIFEST.md registra a skill
- [ ] CLAUDE.template.md lista a skill na tabela de skills

**Restrições:**
- Não fazer commit sem mostrar diff e aguardar confirmação (a menos que `auto-fix CI: true`)
- Não fazer merge sem confirmação explícita do dev (a menos que `auto-merge: true`)
- Não responder comentários de reviewer de forma genérica — sempre referenciar o trecho de código ou a spec relevante
- Não entrar em loop infinito: respeitar `máximo de iterações` e alertar dev se atingido sem resolução
