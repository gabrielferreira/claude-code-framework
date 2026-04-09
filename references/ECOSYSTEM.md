# Ecosystem — Repos de Referência

Ferramentas do ecossistema de spec-driven development monitoradas para inspiração e benchmarking.
Usadas como referência no BACKLOG.md para identificar ideias a absorver.

> **Nota:** URLs verificadas em 2026-04-09. Confirmar se ainda ativas antes de implementar monitoramento automático.

## Repos

### Ferramentas de grandes empresas

| Nome | URL | Lançamento | Foco principal | O que tem de único |
|------|-----|-----------|---------------|-------------------|
| **GitHub Spec Kit** | [github/spec-kit](https://github.com/github/spec-kit) — [docs](https://github.github.com/spec-kit/) | Set 2024 | Metodologia SDD open-source (quem criou a tendência) | Ciclo specify→plan→tasks→implement, 22+ plataformas de agent suportadas, constitution file |
| **AWS Kiro** | [kiro.dev](https://kiro.dev/) | Jul 2025 (preview) / Nov 2025 (GA) | IDE spec-driven completo (powered by Claude/Bedrock) | Requirements→Design→Implementation como fases nativas, agent hooks, steering files — referência direta para como Kiro popularizou o modelo |
| **Google Antigravity** | [developers.googleblog.com](https://developers.googleblog.com/build-with-google-antigravity-our-new-agentic-development-platform/) | Nov 2025 | IDE agent-first (powered by Gemini) | Arquitetura agent-first para workflows assíncronos e verificáveis |

### Ferramentas da comunidade

| Nome | GitHub | Stars (ref) | Foco principal | O que tem de único |
|------|--------|-------------|---------------|-------------------|
| **GSD v1** | [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | ~50k | Orquestração autônoma (prompt framework) | Context-fresh execution, waves paralelas, spec-driven via slash commands — arquitetura mais próxima da nossa |
| **GSD v2** | [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2) | ~5k | Orquestração autônoma (CLI TypeScript/Pi SDK) | Reescrita autônoma com controle programático, state persistence, crash recovery, git isolation, cost tracking — referência para DF1 |
| **OpenSpec** | [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | ~37k | Brownfield iteration | Delta markers (ADDED/MODIFIED/REMOVED), state machine (proposal→apply→archive) |
| **cc-sdd** | [gotalab/cc-sdd](https://github.com/gotalab/cc-sdd) | ~3k | Kiro-style workflow (community) | EARS format, Mermaid, validation gates, 13 idiomas |
| **Taskmaster AI** | [eyaltoledano/claude-task-master](https://github.com/eyaltoledano/claude-task-master) | ~25k | Task decomposition | PRD→task graph, dependency-aware, complexity scores |

## Análise comparativa (2026-04-03)

**Posicionamento:** nenhuma dessas ferramentas tem profundidade de domínio comparável (22 skills especializados + 10 agents de auditoria). Todas focam em "como estruturar e executar", nenhuma foca em "o que verificar por domínio". Somos complementares a todas.

**Categorização do mercado** (fonte: Augment Code):
- **Living-spec platforms**: mantêm docs sincronizados com código (Intent, Kiro)
- **Static-spec tools**: estruturam requirements upfront, reconciliação manual depois (Spec Kit, OpenSpec)
- **Execution orchestrators**: focam em despachar e paralelizar tasks (GSD, Taskmaster)
- **Quality frameworks**: focam em verificação e padrões por domínio (**nós** — categoria que ocupamos sozinhos)

**Tendência 2026:** context engineering substituiu prompt engineering como disciplina crítica. Multi-agent orchestration cresceu 1.445% em consultas Q1/24→Q2/25. O mercado converge para: spec primeiro → plan com gates → execute com context fresco → verify automatizado.

### GSD vs nosso framework

**Diferenciais nossos que GSD não tem:** profundidade de domínio (DBA, SEO, UX, security com OWASP, golden tests, mock mode, logging, performance profiling, docs sync), sistema de update com estratégias (overwrite/structural/manual/skip), integração Notion, TDD obrigatório no workflow.

**Diferenciais do GSD absorvidos:** context-fresh execution ✅, waves paralelas ✅, research phase ✅, resume/state machine ✅, stuck detection (AU1 pendente), cost tracking (AU2 — decisão futura).

**Conclusão:** frameworks resolvem problemas complementares. GSD = orquestração de execução autônoma. Nosso = qualidade e disciplina de domínio.

## Como monitorar

Item **OP1** no BACKLOG.md descreve a implementação de monitoramento automático via GitHub Action semanal que adiciona linhas `🔔` neste arquivo ao detectar novos releases.
Enquanto não implementado, revisar manualmente a cada trimestre ou ao iniciar uma sessão de roadmap.
