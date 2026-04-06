<!-- framework-tag: v2.13.0 framework-file: skills/seo-performance/README.md -->
# Skill: SEO & Performance

> **PROATIVA:** Executar ao criar ou modificar qualquer página pública.
> Também executar ao adicionar dependência nova ou alterar build/bundle.
>
> **Para auditoria completa:** invocar agent `.claude/agents/seo-audit.md`.
> Esta skill contém checklists para uso durante codificação.

## Quando usar

- Ao criar/modificar página pública (landing, blog, docs públicos)
- Ao adicionar nova dependência no frontend (verificar impacto no bundle)
- Ao modificar build config ou estratégia de bundling
- Ao mexer em Service Worker ou manifest.json
- Ao fazer deploy para produção (validação pré-deploy)

## Checklist SEO — páginas públicas

### Meta tags obrigatórias

```html
<!-- Toda página pública DEVE ter: -->
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{título descritivo} | {Nome do Projeto}</title>
<meta name="description" content="{descrição 150-160 chars}">
<link rel="canonical" href="https://{domínio}/{path}">

<!-- Open Graph (compartilhamento social) -->
<meta property="og:title" content="{título}">
<meta property="og:description" content="{descrição}">
<meta property="og:image" content="https://{domínio}/og-image.png">
<meta property="og:url" content="https://{domínio}/{path}">
<meta property="og:type" content="website">
<meta property="og:locale" content="{locale}">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{título}">
<meta name="twitter:description" content="{descrição}">
```

### Páginas internas — noindex obrigatório

```html
<!-- /app, /admin, páginas autenticadas -->
<meta name="robots" content="noindex, nofollow">
```

### Structured Data (JSON-LD)

```html
<!-- Landing page: Organization + WebApplication -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "{Nome do Projeto}",
  "description": "{descrição}",
  "url": "https://{domínio}",
  "applicationCategory": "{categoria}",
  "operatingSystem": "Web"
}
</script>

<!-- Blog posts: Article -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "{título}",
  "datePublished": "{data ISO}",
  "author": { "@type": "Organization", "name": "{Nome}" }
}
</script>
```

### Sitemap

- `sitemap.xml` deve listar TODAS as páginas públicas
- Atualizar ao criar nova página pública ou blog post
- Formato: `<url><loc>https://{domínio}/{path}</loc><lastmod>{date}</lastmod></url>`

### robots.txt

- Verificar que páginas públicas são permitidas
- Verificar que crawlers de IA estão bloqueados (se desejado)

## Checklist Performance — Core Web Vitals

### LCP (Largest Contentful Paint) — target < 2.5s

- [ ] Hero image/text carrega sem JS (SSR ou HTML estático)
- [ ] Fontes com `font-display: swap` (não bloqueia render)
- [ ] Preload de recursos críticos: `<link rel="preload" href="..." as="font">`
- [ ] Imagens com dimensões explícitas (`width`/`height` no HTML)
- [ ] Não carregar componentes pesados no above-the-fold

### FID/INP (Interaction to Next Paint) — target < 200ms

- [ ] Código JS pesado com lazy loading (import dinâmico)
- [ ] Libs pesadas carregadas APENAS quando necessário
- [ ] Event handlers não fazem trabalho pesado no main thread
- [ ] `requestAnimationFrame` para animações (não setInterval)

### CLS (Cumulative Layout Shift) — target < 0.1

- [ ] Imagens com dimensões fixas (não causar reflow)
- [ ] Fontes com fallback de mesmo tamanho (métricas CSS)
- [ ] Ads/banners com espaço reservado
- [ ] Skeleton loaders para conteúdo dinâmico

### Bundle Size

| Chunk | Target | Ação se exceder |
|---|---|---|
| main.js | < 200KB gzip | Code split, tree shake |
| vendor.js | < 150KB gzip | Analisar deps pesados |
| {libs pesadas} | lazy loaded | Não incluir no bundle principal |

### Lazy Loading

```
// Componentes pesados — SEMPRE lazy
const HeavyComponent = lazy(() => import("./HeavyComponent"));

// Libs pesadas — SEMPRE import dinâmico
const lib = await import("heavy-lib");
```

### Imagens

- [ ] Formato WebP/AVIF (fallback PNG)
- [ ] `loading="lazy"` para imagens below-the-fold
- [ ] Dimensões explícitas para evitar CLS
- [ ] Icons inline SVG (não carregar sprite sheet inteira)

## Checklist Acessibilidade (básico)

- [ ] `<html lang="{idioma}">`
- [ ] `<title>` descritivo
- [ ] Headings hierárquicos (h1 → h2 → h3, sem pular)
- [ ] Alt text em imagens informativas
- [ ] Contraste mínimo 4.5:1 para texto (3:1 para texto grande)
- [ ] Touch targets ≥ 44px em mobile
- [ ] Focus visible em elementos interativos

## Ferramentas de validação

```bash
# Lighthouse CI (rodando localmente)
npx lighthouse https://localhost:{port}/ --output=json --output=html

# PageSpeed Insights API
curl "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://{domínio}&strategy=mobile"

# Bundle analyzer
{bundle analyzer command do projeto}

# Meta tags check
curl -s https://{domínio} | grep -E "<title|<meta|<link rel=\"canonical"
```

## Regra de ouro

> Se a página é pública, ela é canal de aquisição.
> Cada 0.1s a mais no LCP = -7% de conversão.
> SEO sem performance é ranking sem visita.
> Performance sem SEO é velocidade sem destino.
