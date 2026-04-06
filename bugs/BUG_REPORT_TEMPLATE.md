<!-- framework-tag: v2.13.0 framework-file: bugs/BUG_REPORT_TEMPLATE.md -->
# Bug Report — {ID}: {Titulo}

> Severidade: `critico` | `alto` | `medio` | `baixo`
> Status: `investigando` | `confirmado` | `escalado` | `resolvido` | `nao-reproduzivel`
> Investigado por: {nome do investigador N2/N3}
> Data: YYYY-MM-DD

## Sintoma reportado

*Exatamente o que o usuario/cliente relatou, sem interpretar.*

- **Quem reportou:** *{usuario, cliente, monitoramento}*
- **Canal:** *{ticket, chat, email, alerta}*
- **Relato original:** *{transcrever ou resumir o relato}*

### Validacao do sintoma

*O que foi reportado e o bug real ou e consequencia de algo mais profundo?*

- **Sintoma original:** *{o que o usuario ve}*
- **Bug real identificado:** *{se diferente do sintoma — o que realmente esta errado}*
- **Nivel:** `sintoma visivel` | `bug intermediario` | `bug raiz`
- **Bugs similares anteriores:** *{links para ocorrencias anteriores, se existem}*

## Comportamento esperado vs real

| Aspecto | Esperado | Real |
|---------|----------|------|
| *{aspecto 1}* | *{o que deveria acontecer}* | *{o que acontece}* |
| *{aspecto 2}* | *{o que deveria acontecer}* | *{o que acontece}* |

**Referencia do comportamento esperado:** *{link para spec, PRD, documentacao, ou "expectativa implicita (sem spec)"}*

## Contexto da funcionalidade

*Onde o bug acontece no produto e como o usuario chega ate ele.*

- **Funcionalidade/modulo:** *{nome}*
- **Tela/endpoint/fluxo:** *{caminho ate o bug}*
- **Dependencias conhecidas:** *{APIs, servicos, integracoes envolvidas}*
- **Referencias:**
  - Spec: *{link ou "nao existe"}*
  - PRD: *{link ou "nao existe"}*
  - Documentacao: *{link ou "nao existe"}*
  - Repositorio/modulo: *{link}*

## Reproducao

### Pre-condicoes

- *{estado inicial necessario}*
- *{dados necessarios}*
- *{permissoes/roles}*

### Passos

1. *{Ir para X}*
2. *{Clicar em Y}*
3. *{Preencher Z com...}*
4. *{Observar...}*

### Resultado esperado

*{O que deveria acontecer no passo N}*

### Resultado real

*{O que acontece de fato}*

### Frequencia e ambiente

| Item | Valor |
|------|-------|
| Frequencia | `sempre` / `intermitente (~X%)` / `uma vez` |
| Ambiente | *{producao, staging, local}* |
| Browser/OS/App | *{versao}* |
| Data primeira ocorrencia | *{data}* |

> Se nao reproduzido: registrar tentativas feitas e ambientes testados.

## Evidencias

*Todas as evidencias coletadas durante a investigacao.*

### Logs

```
{Logs relevantes com timestamp e request ID}
```

### Screenshots/gravacoes

- *{descricao do screenshot/gravacao e link}*

### Metricas/monitoramento

- *{Metrica afetada: valor antes vs agora}*
- *{Dashboard/ferramenta: link}*

### Relatos de outros usuarios

- *{Quantos usuarios reportaram}*
- *{Desde quando}*
- *{Padrao em comum entre relatos}*

## Porques (causa raiz do bug)

*Para cada hipotese de causa, encadear "por que?" ate chegar na raiz.*

### Hipotese 1 — *{titulo}*

1. Por que o bug acontece? → *{resposta}*
2. Por que? → *{resposta}*
3. Por que? → *{resposta}*
4. Por que? → *{se necessario}*
5. Por que? → *{se necessario}*

**Causa raiz provavel:** *{resumo}*
**Tipo:** `codigo` | `dados` | `infra` | `config` | `processo`
**Confianca:** `alta (evidencia direta)` | `media (evidencia indireta)` | `baixa (hipotese)`

### Hipotese 2 — *{titulo}*

1. Por que? → *{resposta}*
2. Por que? → *{resposta}*
3. Por que? → *{resposta}*

**Causa raiz provavel:** *{resumo}*
**Tipo:** `codigo` | `dados` | `infra` | `config` | `processo`
**Confianca:** `alta` | `media` | `baixa`

## Mapa de impacto

| Dimensao | Detalhe |
|----------|---------|
| Usuarios afetados | *{quantos, que segmento, todos ou condicao especifica}* |
| Impacto no negocio | *{receita, reputacao, SLA, compliance}* |
| Blast radius | *{so esta funcionalidade ou efeito cascata?}* |
| Workaround | *{existe? qual? aceitavel?}* |
| Desde quando | *{data/deploy/release que introduziu — se identificavel}* |

## Recomendacao para engenharia

*O que o time de engenharia precisa saber para resolver.*

- **Causa raiz mais provavel:** *{resumo da analise}*
- **Area do sistema afetada:** *{modulo, servico, tabela, API}*
- **Sugestao de correcao:** *{o que mudar — nivel de produto, nao implementacao}*
- **Riscos da correcao:** *{o que pode quebrar, efeitos colaterais}*
- **Sugestao de testes:** *{como validar que o fix resolveu}*
- **Prioridade sugerida:** *{com justificativa baseada no mapa de impacto}*

## Calibracao de completude

*Validacao de que o relatorio esta completo para engenharia.*

- [ ] Engenharia consegue reproduzir so com este relatorio
- [ ] Causa raiz tem evidencia (nao e so suposicao)
- [ ] Comportamento esperado tem referencia (spec/doc)
- [ ] Impacto esta quantificado (usuarios, negocio)
- [ ] Recomendacao aponta area especifica do sistema
- [ ] Evidencias tem timestamp
- [ ] Bugs similares anteriores foram referenciados (se existem)
