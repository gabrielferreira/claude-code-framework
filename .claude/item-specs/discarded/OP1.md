# OP1 — Monitoramento do ecossistema

**Contexto:** o ECOSYSTEM.md lista os repos de referência com última versão conhecida. Hoje o monitoramento é manual — alguém precisa lembrar de checar novos releases. Sem automação, é fácil perder features relevantes de concorrentes.

**Abordagem:** GitHub Action com cron semanal que:

1. Lê `references/ECOSYSTEM.md` — extrai os repos listados e a última versão registrada para cada um
2. Consulta a GitHub API para obter o release mais recente de cada repo
3. Compara: se a versão do release é mais nova que a registrada no ECOSYSTEM.md, adiciona uma linha de "pendente de validação" na seção do repo

**Formato da linha adicionada:**

```markdown
| 🔔 v2.5.0 | 2026-04-15 | Pendente validação | [Release notes](https://github.com/...releases/tag/v2.5.0) |
```

A linha fica no ECOSYSTEM.md até o time revisitar, validar o que é relevante e atualizar a "última versão conhecida". Nenhuma notificação externa — o ECOSYSTEM.md é o log.

**Critérios de aceitação:**
- [ ] GitHub Action `.github/workflows/ecosystem-monitor.yml` com `schedule: cron: '0 9 * * 1'` (toda segunda, 9h)
- [ ] Action lê repos do ECOSYSTEM.md via script (Python ou Node)
- [ ] Para cada repo com release mais novo: adiciona linha `🔔` na seção correspondente do ECOSYSTEM.md
- [ ] Commit automático das linhas adicionadas com mensagem `chore: ecosystem monitor — novos releases detectados`
- [ ] Se nenhum repo tem release novo: nenhum commit (sem ruído)
- [ ] Linhas `🔔` acumulam até serem revisadas manualmente — não são sobrescritas na próxima rodada

**Restrições:** não sobrescrever conteúdo existente do ECOSYSTEM.md — só append de linhas novas. Não notificar em canal externo. A Action precisa de `GITHUB_TOKEN` com permissão de escrita no repo (já disponível por padrão nas Actions).

**Descartado em:** 2026-04-10
**Motivo:** Framework-internal sem valor para usuários. GitHub Action para detectar releases de concorrentes é overhead de manutenção sem retorno.
