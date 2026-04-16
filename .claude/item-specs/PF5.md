# PF5 — Structural merge otimizado (update)

**Contexto:** o merge structural no update é a operação mais cara. Hoje o algoritmo é descrito textualmente e Claude re-interpreta a cada arquivo. Cada merge envolve: parse de seções do source, parse do projeto, comparação, heurística de customização (>30% diferente = customizado), merge, validação de regressão. Para 3-5 arquivos structural, são 10-25 minutos.

**Abordagem:** substituir a descrição textual por uma receita mecânica com short-circuit, sem heurísticas de conteúdo. Seções existentes = intocáveis (sem análise).

**Receita mecânica:**

```
STRUCTURAL MERGE — receita (por arquivo):

0. SHORT-CIRCUIT:
   Se framework-tag do projeto = framework-tag do source → SKIP (nada mudou)
   Economia: ~80% dos arquivos em update típico (só muda o que o release alterou)

1. EXTRAIR headers do source:
   grep -n "^## \|^### " source.md → lista_source[]

2. EXTRAIR headers do projeto:
   grep -n "^## \|^### " projeto.md → lista_projeto[]

3. CALCULAR diff:
   NOVAS     = lista_source - lista_projeto   (seções no source que não estão no projeto)
   REMOVIDAS = lista_projeto - lista_source   (seções no projeto que não estão no source)
   EXISTENTES = interseção(lista_source, lista_projeto)

4. APLICAR:
   - NOVAS → extrair conteúdo da seção do source (desde header até próximo header) → APPEND ao final do projeto
   - REMOVIDAS → se header não é customização do projeto (tem framework-tag?):
     perguntar "Seção '{nome}' removida do framework. Remover? [Sim/Não]"
   - EXISTENTES → NÃO TOCAR (conteúdo do projeto, sagrado)

5. ATUALIZAR framework-tag na linha 1

Pronto. Sem regex de conteúdo, sem heurística 30%, sem parse de tabelas.
```

**Short-circuit em números:**
- Release típica muda 3-5 arquivos structural de ~80 totais
- Os outros ~75 têm mesma tag → short-circuit → 0 análise
- Economia: de ~80 análises para ~5

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/update-framework/SKILL.md` | Fase 3.2 reescrita como receita mecânica |
| Mirror | Sync |

**Critérios de aceitação:**
- [ ] Short-circuit funciona: arquivo com mesma tag = skip sem análise
- [ ] Merge só adiciona seções novas e pergunta sobre removidas
- [ ] Conteúdo de seções existentes NUNCA é alterado
- [ ] Framework-tag atualizado no final
- [ ] Resultado: mesmas seções que antes, mas 10x mais rápido
- [ ] Edge case: arquivo sem framework-tag (v0.0.0) → tratar como desatualizado, merge completo

**Restrições:**
- Content patches (mudanças DENTRO de seções existentes) continuam sendo aplicados via migration guide, não pelo merge structural — isso não muda
- A receita substitui TODA a lógica atual de merge structural — não é um patch, é rewrite

**Deps:** nenhuma (independente de PF1-PF4)
