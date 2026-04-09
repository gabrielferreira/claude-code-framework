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

## Última análise

**Data:** 2026-04-03  
**Resultado:** ver seção "Notas → Contexto: Análise do ecossistema SDD" no BACKLOG.md

## Como monitorar

Item **OP1** no BACKLOG.md descreve a implementação de monitoramento automático via GitHub Action mensal.
Enquanto não implementado, revisar manualmente a cada trimestre ou ao iniciar uma sessão de roadmap.
