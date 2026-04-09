# MO4 — Git isolation por task

**Contexto:** o task-runner (CE1 ✅) executa tasks sequencialmente no branch corrente. Se uma task falhar a meio, o estado do repositório fica parcialmente modificado — difícil de reverter sem `git restore`. Isolamento por branch garante que cada task tem um escopo limpo e reversível.

**Abordagem:** instrução no `agents/task-runner.md` para criar uma branch isolada antes de executar cada task:

1. Antes de iniciar a task: criar branch `task/{spec-id}-{task-index}` a partir do branch atual (`git checkout -b task/AUTH-001-t1`)
2. Executar a task normalmente no novo branch
3. Ao concluir: reportar ao dev que a task está pronta para review (`git diff main..HEAD`)
4. Dev revisa e decide: merge (`git merge --no-ff task/AUTH-001-t1`) ou descarte (`git branch -D`)
5. Limpar o branch após merge

O dev mantém controle: o merge não acontece automaticamente — task-runner propõe, dev confirma.

**Impacto no framework:**

| Arquivo | Mudança | Compat. |
|---|---|---|
| `agents/task-runner.md` + template | Instruções de branch isolation nas seções "Antes de iniciar" e "Ao concluir task" | `✅ Aditivo` — adiciona comportamento opcional; task-runner existente continua funcionando sem branches se dev não quiser |

**Critérios de aceitação:**
- [ ] task-runner cria branch `task/{spec-id}-{task-index}` antes de cada task
- [ ] ao concluir, mostra diff resumido e aguarda confirmação do dev para merge
- [ ] se task falhar, instrui o dev a descartar o branch (`git branch -D`) — não tenta recuperar automaticamente
- [ ] comportamento é opt-in: task-runner pergunta no início da sessão se quer usar git isolation
- [ ] funciona mesmo quando `git worktree` não está disponível (fallback: branch normal sem worktree separado)

**Restrições:** não fazer merge automático — revisão humana obrigatória antes de merge. Não criar worktree separado por padrão (overhead de diretório); usar branch simples no mesmo worktree.

**Deps:** CE1 ✅
