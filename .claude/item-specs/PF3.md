# PF3 — CODE_PATTERNS em paralelo

**Contexto:** a detecção de CODE_PATTERNS (Fase 1.6 do setup, Fase 0.6 do update) lê 10-15 arquivos representativos do projeto para extrair libs, padrões e convenções. Hoje cada Read é uma tool call sequencial — o Claude espera o resultado de um antes de ler o próximo. Claude Code suporta múltiplas tool calls na mesma mensagem.

**Abordagem:** instruir explicitamente para emitir todas as chamadas Read em paralelo (mesma mensagem). Claude Code processa em paralelo nativamente quando recebe múltiplas tool calls.

**Mudança concreta:**

Antes (Fase 1.6):
```
Para cada categoria detectada:
  1. Identificar arquivo representativo
  2. Ler o arquivo
  3. Extrair padrão
```

Depois:
```
INSTRUÇÃO DE PERFORMANCE — PARALELO OBRIGATÓRIO:

1. Identificar 1-2 arquivos representativos por categoria:
   - logging: {arquivo com mais imports de logger}
   - errors: {arquivo com try/catch ou error wrapping}
   - http: {arquivo com rotas ou client HTTP}
   - validation: {arquivo com validação}
   - orm/db: {arquivo com queries ou models}
   - config: {arquivo de config ou env}

2. Ler TODOS os arquivos identificados em UMA ÚNICA MENSAGEM
   (múltiplas chamadas Read em paralelo, NÃO sequenciais).
   Máximo: 12 arquivos simultâneos.

3. Após todos os Reads retornarem, analisar e extrair padrões.
```

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Fase 1.6 reescrita com instrução de paralelismo |
| `skills/update-framework/SKILL.md` | Fase 0.6 reescrita com mesma instrução |
| Mirrors | Sync |

**Critérios de aceitação:**
- [ ] Fase 1.6 do setup instrui leitura paralela explicitamente
- [ ] Fase 0.6 do update instrui leitura paralela explicitamente
- [ ] Máximo de 12 arquivos por batch (evitar sobrecarga)
- [ ] Resultado: mesmo CODE_PATTERNS que antes, só mais rápido
- [ ] Tempo de leitura: ~30s em vez de ~3-5 min

**Restrições:**
- Não mudar o que é detectado — só como é lido
- Se um Read falhar (arquivo não existe), continuar com os demais

**Deps:** nenhuma (independente de PF1/PF2)
