# Ecosystem — Repos de Referência

Ferramentas do ecossistema de spec-driven development monitoradas para inspiração e benchmarking.
Usadas como referência no BACKLOG.md para identificar ideias a absorver.

> **Nota:** URLs verificadas em 2026-04-09. Confirmar se ainda ativas antes de implementar monitoramento automático.

## Repos

| Nome | GitHub | Stars (ref) | Foco principal | O que tem de único |
|------|--------|-------------|---------------|-------------------|
| **GSD v1** | [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | ~50k | Orquestração autônoma (prompt framework) | Context-fresh execution, waves paralelas, spec-driven via slash commands — arquitetura mais próxima da nossa |
| **GSD v2** | [gsd-build/gsd-2](https://github.com/gsd-build/gsd-2) | ~5k | Orquestração autônoma (CLI TypeScript/Pi SDK) | Reescrita autônoma com controle programático de agentes, state persistence, crash recovery, git isolation, cost tracking — referência para DF1 |
| **Spec Kit** | [github/spec-kit](https://github.com/github/spec-kit) | ~72k | Scaffolding SDD multi-agent | Constitution file, specify CLI, 22+ agents |
| **OpenSpec** | [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | ~37k | Brownfield iteration | Delta markers (ADDED/MODIFIED/REMOVED), state machine |
| **cc-sdd** | [gotalab/cc-sdd](https://github.com/gotalab/cc-sdd) | ~3k | Kiro-style workflow | EARS format, Mermaid, validation gates, 13 idiomas |
| **Taskmaster AI** | [eyaltoledano/claude-task-master](https://github.com/eyaltoledano/claude-task-master) | ~25k | Task decomposition | PRD→task graph, dependency-aware, complexity scores |

## Última análise

**Data:** 2026-04-03  
**Resultado:** ver seção "Notas → Contexto: Análise do ecossistema SDD" no BACKLOG.md

## Como monitorar

Item **OP1** no BACKLOG.md descreve a implementação de monitoramento automático via GitHub Action mensal.
Enquanto não implementado, revisar manualmente a cada trimestre ou ao iniciar uma sessão de roadmap.
