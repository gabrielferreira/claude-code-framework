<!-- framework-tag: v2.19.1 framework-file: skills/ux-review/README.md -->
# Skill: UX Review — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ao criar/modificar telas, componentes visuais ou fluxos do usuário.
> Critério base: "uma pessoa não-técnica conseguiria usar isso sem ajuda?"

## Quando usar

- Ao criar nova tela ou componente visual
- Ao modificar fluxo do usuário (auth, compra, onboarding, export)
- Ao adicionar campo de formulário ou input
- Ao mexer na landing page ou painel admin
- Ao fazer redesign ou ajuste visual

## Identidade visual — Design System

### Fontes

{Adaptar: fonte da verdade — ex: frontend/styles/tokens.js ou Figma}

| Uso | Fonte | Peso |
|---|---|---|
| Body, labels, inputs | {Sans-serif — ex: Inter, DM Sans} | 400, 500, 600, 700 |
| Títulos, branding | {Opcional — ex: Instrument Serif} | {italic / bold} |
| Código, valores numéricos | {Monospace — ex: JetBrains Mono, DM Mono} | 400, 500 |

**Regra:** NUNCA usar system fonts genéricas em componentes novos. Se um arquivo existente usa fontes diferentes, considerar migração.

### Cores

{Adaptar: tokens de cor conforme a paleta do projeto}

| Token | Valor | Uso |
|---|---|---|
| `primary` | {#hex} | Botões, links, acentos |
| `ink` / `text` | {#hex} | Texto principal |
| `muted` | {#hex} | Texto secundário |
| `success` | {#hex} | Confirmações, valores positivos |
| `error` | {#hex} | Erros, valores negativos |
| `warning` | {#hex} | Alertas |
| `background` | {#hex} | Fundos |

**Regra:** NUNCA hardcodar cores. Usar tokens do design system. Cor nova = adicionar ao sistema.

### Branding

- Nome: **{NOME_DO_PROJETO}**
- {Variações proibidas — ex: nunca usar abreviações em contextos visíveis ao usuário}
- {Logo usage rules}

## Checklist por tipo de mudança

### Nova tela / componente

- [ ] Usa fontes do design system?
- [ ] Usa cores do design system (não hardcoda hex)?
- [ ] Funciona em viewport **375px** (iPhone SE)? Testar mentalmente
- [ ] Funciona em viewport **768px** (iPad)?
- [ ] Funciona em viewport **1440px** (desktop)?
- [ ] Touch targets ≥ **44px** em mobile?
- [ ] Tem **empty state** (o que aparece quando não tem dados)?
- [ ] Tem **loading state** (skeleton, spinner, texto)?
- [ ] Tem **error state** (mensagem clara + ação possível)?
- [ ] Branding consistente?

### Novo campo de formulário

- [ ] Label clara e não-técnica?
- [ ] Placeholder com exemplo do formato esperado?
- [ ] Máscara de input se aplicável (documento, código postal, telefone, data)?
- [ ] `inputMode` correto? (numeric para números, email para email, tel para telefone)
- [ ] Validação visual em tempo real (borda verde/vermelha)?
- [ ] Mensagem de erro que diz **O QUE** está errado e **COMO** corrigir?
- [ ] Tooltip/help text se o campo não é óbvio?
- [ ] `aria-label` presente?

### Novo botão / ação

- [ ] Texto do botão é verbo de ação? ("Enviar", "Baixar", não "OK" ou "Sim")
- [ ] Loading state no botão durante processamento? ("Enviando...", "Baixando...")
- [ ] Desabilitado visualmente quando não pode ser clicado?
- [ ] Se ação destrutiva → confirmação modal antes de executar?
- [ ] Se ação irreversível → warning explícito ("Esta ação não pode ser desfeita")
- [ ] É `<button>` com `aria-label`, não `<span onClick>`?

### Fluxo de compra / checkout

{Remover se não tem pagamento}

- [ ] Usuário vê preço antes de clicar?
- [ ] Se tem cupom → preço com desconto visível, original riscado?
- [ ] Loading state entre clique e redirect ao gateway?
- [ ] Mensagem de erro clara se checkout falhar?
- [ ] Estado do fluxo persistido entre redirecionamentos?

### Mensagem de erro

- [ ] Diz **O QUE** deu errado (não "Erro desconhecido")?
- [ ] Diz **COMO** corrigir (não apenas o problema)?
- [ ] Não expõe detalhes técnicos ao usuário (sem stack trace, sem SQL)?
- [ ] Usa linguagem simples (não jargão)?

## Mobile first

{Adaptar ao público-alvo. Se a maioria dos usuários acessa por celular, mobile first.}

1. **Sidebar → hamburger** em ≤768px
2. **Tabelas → scroll horizontal** em mobile
3. **Grid → stack vertical** em ≤500px
4. **Modal → fullscreen** em mobile
5. **FABs → não sobrepor** (se tem mais de um botão flutuante)
6. **Inputs numéricos → teclado numérico** (`inputMode="numeric"`)
7. **Downloads → Blob download**, não `window.open` (bloqueado em mobile)

## Acessibilidade mínima (WCAG AA)

- [ ] `aria-label` em todo botão sem texto visível (ícone-only)
- [ ] `role` em elementos interativos que não são `<button>` ou `<a>`
- [ ] Escape fecha modais/overlays
- [ ] Foco vai para o primeiro input ao abrir modal
- [ ] Contraste mínimo **4.5:1** para texto
- [ ] Skip-to-content link no topo da página
- [ ] Tab order faz sentido (não pula elementos)
- [ ] Screen reader consegue navegar os fluxos principais

## Anti-patterns

| Anti-pattern | Problema | Solução |
|---|---|---|
| `<span onClick>` | Inacessível, sem keyboard support | Usar `<button>` |
| Emoji como único indicador | Inacessível para screen readers | Adicionar texto ou cor |
| Font size < 12px | Ilegível em mobile | Mínimo 14px para body |
| Cor de baixo contraste em fundo branco | WCAG fail | Testar contraste (mínimo 4.5:1) |
| `window.open("", "_blank")` para download | Bloqueado em mobile | Usar Blob download |
| Timer frontend desacoplado do backend | Dessincroniza | Usar `expires_at` do server |
| Mensagem genérica ("Erro") | Usuário não sabe o que fazer | Dizer o que e como corrigir |
