<!-- framework-tag: v2.13.3 framework-file: bugs/BUG_REPORT_TEMPLATE.md -->

> Severidade: `critico` | `alto` | `medio` | `baixo`
> Status: `investigando` | `confirmado` | `escalado` | `resolvido` | `nao-reproduzivel`
> Investigado por: {nome do investigador N2/N3}
> Data: YYYY-MM-DD

### Titulo Sugerido: `[Bug][{Vertical/Sistema}] {Breve resumo do problema}`

### 1. Contexto e Comportamento

- **Descricao do Problema:** *{Resumo claro do que esta acontecendo — usar o bug real identificado na validacao do sintoma, nao o sintoma superficial}*
- **Comportamento Atual:** *{O que o sistema esta fazendo de errado}*
- **Comportamento Esperado:** *{O que o sistema deveria fazer — com referencia a spec/doc se existir}*

**Validacao do sintoma (analise interna):**

- **Sintoma original reportado:** *{o que o usuario/cliente disse}*
- **Bug real identificado:** *{se diferente do sintoma — o que realmente esta errado}*
- **Nivel:** `sintoma visivel` | `bug intermediario` | `bug raiz`
- **Bugs similares anteriores:** *{links para ocorrencias anteriores, se existem}*

### 2. Reproducao e Validacao

- **Passos para Reproduzir:**
  1. *{Acessar a tela X}*
  2. *{Clicar no botao Y}*
  3. *{Inserir o dado Z}*
  4. *{Observar o erro...}*
- **Como validar a correcao:** *{Criterio de aceite derivado da causa raiz — o que confirma que o fix resolveu a raiz, nao so o sintoma}*
- **Midias (Evidencias):**
  - [ ] Prints anexados
  - [ ] Gravacao de tela anexada

**Pre-condicoes:**

- *{Estado inicial necessario}*
- *{Dados necessarios / massa de teste}*
- *{Permissoes/roles}*

**Frequencia e ambiente:**

| Item | Valor |
|------|-------|
| Frequencia | `sempre` / `intermitente (~X%)` / `uma vez` |
| Ambiente | *{producao, staging, local}* |
| Browser/OS/App | *{versao}* |
| Data primeira ocorrencia | *{data}* |

> Se nao reproduzido: registrar tentativas feitas e ambientes testados.

### 3. Dados Tecnicos (Adicoes criticas para reducao de Cycle Time)

- **Ambiente/Versao:** *{Ex: Producao, Staging / App v2.14.0, iOS 17}*
- **Massa de Dados Utilizada:** *{E-mail do usuario teste, ID do pedido, UUID do cliente}*
- **Logs / Console:** *{Prints do console do navegador, links do NewRelic/CloudWatch Logs, Payload de erro da API}*

```
{Logs relevantes com timestamp e request ID}
```

**Metricas/monitoramento:**

- *{Metrica afetada: valor antes vs agora}*
- *{Dashboard/ferramenta: link}*

**Relatos de outros usuarios:**

- *{Quantos usuarios reportaram}*
- *{Desde quando}*
- *{Padrao em comum entre relatos}*

**Analise de causa raiz (5 Whys):**

#### Hipotese 1 — *{titulo}*

1. Por que o bug acontece? → *{resposta}*
2. Por que? → *{resposta}*
3. Por que? → *{resposta}*
4. Por que? → *{se necessario}*
5. Por que? → *{se necessario}*

**Causa raiz provavel:** *{resumo}*
**Tipo:** `codigo` | `dados` | `infra` | `config` | `processo`
**Confianca:** `alta (evidencia direta)` | `media (evidencia indireta)` | `baixa (hipotese)`

#### Hipotese 2 — *{titulo}*

1. Por que? → *{resposta}*
2. Por que? → *{resposta}*
3. Por que? → *{resposta}*

**Causa raiz provavel:** *{resumo}*
**Tipo:** `codigo` | `dados` | `infra` | `config` | `processo`
**Confianca:** `alta` | `media` | `baixa`

**Recomendacao para engenharia:**

- **Causa raiz mais provavel:** *{resumo da analise}*
- **Area do sistema afetada:** *{modulo, servico, tabela, API}*
- **Sugestao de correcao:** *{o que mudar — nivel de produto, nao implementacao}*
- **Riscos da correcao:** *{o que pode quebrar, efeitos colaterais}*
- **Sugestao de testes:** *{como validar que o fix resolveu}*

### 4. Escopo e Impacto

- **Plataforma:** *{Plataforma nova / legado / especificar versao}*
- **Vertical:** *{Todas / especificar: Concursos, OAB, etc}*
- **Sistemas Afetados (Horizontal):** *{LDI, Auth, Payments, etc}*
- **Dispositivos Afetados:** *{Web / Aplicativo / detalhar OS se relevante: iOS/Android}*
- **Usuarios Afetados:** *{Todos / % estimada / perfil de usuario especifico}*
- **Blocante (Possui Workaround?):** *{Nao / Se sim, descrever qual e o contorno atual}*
- **Chamados Relacionados (Links/Threads):** *{links para tickets, threads, bugs similares anteriores}*

## Calibracao de completude

*Validacao interna de que o relatorio esta completo para engenharia.*

- [ ] Engenharia consegue reproduzir so com este relatorio
- [ ] Causa raiz tem evidencia (nao e so suposicao)
- [ ] Comportamento esperado tem referencia (spec/doc)
- [ ] Impacto esta quantificado (usuarios, negocio)
- [ ] Recomendacao aponta area especifica do sistema
- [ ] Evidencias tem timestamp
- [ ] Bugs similares anteriores foram referenciados (se existem)
