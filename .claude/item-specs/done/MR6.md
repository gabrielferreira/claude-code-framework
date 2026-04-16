# MR6 — Promoção de artefatos duplicados entre camadas (monorepo)

**Contexto:** em monorepos com múltiplos sub-projetos, é comum skills, agents e docs serem copiados identicamente entre sub-projetos (ex: `backend/.claude/skills/logging/` = `frontend/.claude/skills/logging/`). Isso gera duplicação, divergência silenciosa ao longo do tempo, e desperdício de contexto. O framework deve detectar e sugerir consolidação.

**Abordagem:** nova lógica de detecção + sugestão no setup (cenário B: sub-projeto com framework pré-existente) e no update (auditoria periódica — nova Categoria 7).

### Artefatos cobertos

| Artefato | Comparação | Promoção para |
|---|---|---|
| Skills (`*.md` em `.claude/skills/`) | diff do conteúdo (ignorar framework-tag) | Nível que agrega todos os sub-projetos com versão idêntica |
| Agents (`*.md` em `.claude/agents/`) | diff do conteúdo (ignorar framework-tag) | Mesmo |
| Docs (`docs/*.md`) | **Só docs de processo** (GIT_CONVENTIONS, WORKFLOW_DIAGRAM, SKILLS_MAP). Docs de conteúdo (ARCHITECTURE, ACCESS_CONTROL, SECURITY_AUDIT) são por natureza específicos do sub-projeto — **não promover**, mesmo se parecidos. A diferença legítima é o contexto do sub-projeto. | Raiz `docs/` (só processo) |
| `scripts/verify.sh` | diff dos checks (ignorar paths relativos) | Orquestrador na raiz que chama verify.sh dos sub-projetos |
| `specs/TEMPLATE.md` | diff do conteúdo | Raiz `.claude/specs/TEMPLATE.md` |

**Artefatos que NÃO promovem:**
- CLAUDE.md L2 — por definição específico do sub-projeto
- CODE_PATTERNS — específicos por stack
- backlog.md — conteúdo diferente por sub-projeto
- specs individuais — conteúdo diferente

### Lógica de detecção

1. **Listar artefatos por sub-projeto:** para cada sub-projeto no `### Estrutura`, listar skills, agents, docs
2. **Comparar entre pares:** para cada artefato, comparar conteúdo entre todos os sub-projetos que o têm (diff ignorando framework-tag e nomes de projeto)
3. **Calcular interseção:** se N de M sub-projetos têm versão idêntica:
   - N = M (todos): sugerir promover para nível que agrega todos (geralmente L0)
   - N > M/2 (maioria): sugerir promover para L0 e manter override nos sub-projetos diferentes
   - N = 2 e M > 3: informar mas não sugerir promoção (pode ser coincidência)
4. **Verificar se já existe no nível superior:** se L0 já tem a mesma skill, os sub-projetos estão duplicando — sugerir remover dos sub-projetos

### Lógica de promoção (multi-nível)

A promoção pode pular níveis se a interseção justificar:
- L3 skill idêntica em 2 sub-domínios do mesmo L2 → promover para L2
- L2 skill idêntica em 3 sub-projetos → promover para L0
- L3 skill idêntica em sub-domínios de sub-projetos diferentes → promover direto para L0

**Regra:** promover para o nível mais alto que agrega todos os sub-projetos com versão idêntica.

### No setup (cenário B — sub-projeto com framework pré-existente)

Ao detectar sub-projeto com framework já configurado:
1. Listar skills/agents do sub-projeto
2. Comparar com skills/agents dos outros sub-projetos já mapeados
3. Se duplicatas encontradas: informar e sugerir promoção
   > "As skills `logging`, `code-quality` e `testing` são idênticas em `backend/` e `frontend/`. Quer mover para a raiz (`.claude/skills/`) e compartilhar entre ambos?"
4. Se o dev aceitar: mover para L0, remover dos sub-projetos, atualizar CLAUDE.md L2 para referenciar a skill da raiz

### No update (nova Categoria 7 — Deduplicação de artefatos)

Auditoria periódica:
1. Escanear skills/agents/docs em todos os sub-projetos listados em `### Estrutura`
2. Comparar entre pares
3. Se duplicatas: informar com diff e sugerir promoção
4. Se artefato já existe no L0 e é idêntico ao L2: sugerir remover do L2 (já herdado)

**Severidade:** ⚪ info (sugestão, nunca obrigatório)

### Critérios de aceitação

- [x] Setup cenário B detecta skills/agents idênticos entre sub-projetos e sugere promoção
- [x] Update Categoria 8 escaneia e reporta duplicatas
- [x] Interseção inteligente: maioria idêntica → sugerir L0 + override no diferente
- [x] Promoção multi-nível funciona (L3→L0 se justificado)
- [x] Artefato já existente no L0 = sugestão de remover do L2
- [x] Docs cobertos (não só skills/agents)
- [x] verify.sh e TEMPLATE.md cobertos
- [x] Nunca promover automaticamente — sempre perguntar
- [x] Single-repo: zero mudança (skip)

### Restrições

- Nunca mover automaticamente — sempre sugerir e aguardar confirmação
- Comparação ignora framework-tag e nomes de projeto (normalizar antes de diff)
- Se o dev recusar: registrar no SETUP_REPORT como info, não insistir
- Não aplicar em projetos com < 2 sub-projetos (não faz sentido)

**Deps:** MR1 ✅, MR2 ✅
