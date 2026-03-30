#!/usr/bin/env node
/**
 * Reports Index — Página consolidada de reports
 *
 * Auto-detecta reports existentes e agrega em uma única página.
 * Suporta: coverage Istanbul, golden tests (backend/frontend), backlog.
 *
 * Uso: node scripts/reports-index.js
 * Output: reports/index.html
 *
 * Configuração via env vars:
 *   PROJECT_NAME — nome do projeto (default: nome da pasta raiz)
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const PROJECT_NAME = process.env.PROJECT_NAME || path.basename(ROOT);
const REPORTS_DIR = path.join(ROOT, "reports");
const OUTPUT = path.join(REPORTS_DIR, "index.html");

// ─── Auto-detectar reports existentes ───

const candidates = [
  {
    id: "coverage-be",
    title: "Coverage — Services & Middleware",
    subtitle: "Backend — cobertura via Istanbul/Jest (import direto)",
    path: path.join(ROOT, "backend", "coverage", "index.html"),
    relativePath: "../backend/coverage/index.html",
    icon: "📊",
    type: "istanbul",
  },
  {
    id: "coverage-fe",
    title: "Coverage — Frontend",
    subtitle: "Frontend — cobertura via Istanbul/Vitest",
    path: path.join(ROOT, "frontend", "coverage", "index.html"),
    relativePath: "../frontend/coverage/index.html",
    icon: "📊",
    type: "istanbul",
  },
  {
    id: "golden-be",
    title: "Coverage — Routes & Endpoints",
    subtitle: "Backend — cobertura de rotas via golden tests (supertest + snapshots)",
    path: path.join(ROOT, "backend", "coverage", "golden-report.html"),
    relativePath: "../backend/coverage/golden-report.html",
    icon: "🔒",
    type: "golden",
  },
  {
    id: "golden-fe",
    title: "Coverage — Componentes & Hooks",
    subtitle: "Frontend — cobertura de UI via golden tests (render + snapshots)",
    path: path.join(ROOT, "frontend", "coverage", "golden-report.html"),
    relativePath: "../frontend/coverage/golden-report.html",
    icon: "🎨",
    type: "golden",
  },
  {
    id: "backlog",
    title: "Backlog",
    subtitle: "Pendentes, concluídos, métricas e decisões futuras",
    path: path.join(ROOT, "docs", "backlog-report.html"),
    relativePath: "../docs/backlog-report.html",
    icon: "📋",
    type: "backlog",
  },
];

// Só incluir reports que existem no filesystem
const reports = candidates.filter((r) => fs.existsSync(r.path));

// ─── Extrair métricas de cada report ───

function extractIstanbulStats(htmlPath) {
  if (!fs.existsSync(htmlPath)) return null;
  const html = fs.readFileSync(htmlPath, "utf8");

  const match = html.match(
    /class="strong"[^>]*>(\d+\.?\d*)%\s*<\/span>\s*<\/span>\s*<br>\s*Statements/
  );
  if (match) return { pct: match[1], label: "Statements" };

  const fallback = html.match(/class="strong"[^>]*>(\d+\.?\d*)%/);
  if (fallback) return { pct: fallback[1], label: "Coverage" };

  return null;
}

function extractGoldenStats(htmlPath) {
  if (!fs.existsSync(htmlPath)) return null;
  const html = fs.readFileSync(htmlPath, "utf8");

  const pctMatch = html.match(
    /class="(?:value|number)">(\d+\.?\d*)%<\/div>\s*<div class="label">Cobertura/
  );
  const countMatch = html.match(
    /class="(?:value|number)">(\d+)\/(\d+)<\/div>\s*<div class="label">(Endpoints|Módulos) cobertos/i
  );
  const snapMatch = html.match(
    /class="(?:value|number)">(\d+)<\/div>\s*<div class="label">Snapshots/
  );

  if (!pctMatch) return null;

  return {
    pct: pctMatch[1],
    covered: countMatch ? countMatch[1] : "?",
    total: countMatch ? countMatch[2] : "?",
    snaps: snapMatch ? snapMatch[1] : "0",
    unit: countMatch ? countMatch[3].toLowerCase() : "itens",
  };
}

function extractBacklogStats(htmlPath) {
  if (!fs.existsSync(htmlPath)) return null;
  const html = fs.readFileSync(htmlPath, "utf8");

  const pendMatch = html.match(/class="(?:value|number)">(\d+)<\/div>\s*<div class="label">Pendentes/);
  const doneMatch = html.match(/class="(?:value|number)">(\d+)<\/div>\s*<div class="label">Conclu/);
  const pctMatch = html.match(/class="(?:value|number)">([\d.]+)%<\/div>\s*<div class="label">Progresso/);

  if (!pendMatch) return null;

  return {
    pending: pendMatch[1],
    done: doneMatch ? doneMatch[1] : "?",
    pct: pctMatch ? pctMatch[1] : null,
  };
}

function extractStats(report) {
  if (report.type === "istanbul") return extractIstanbulStats(report.path);
  if (report.type === "golden") return extractGoldenStats(report.path);
  if (report.type === "backlog") return extractBacklogStats(report.path);
  return null;
}

// ─── Gerar HTML ───

function esc(s) {
  return String(s || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function statColor(pct) {
  const n = parseFloat(pct);
  if (n >= 80) return "#16a34a";
  if (n >= 50) return "#d97706";
  return "#dc2626";
}

function cardHtml(report, stats) {
  const exists = fs.existsSync(report.path);

  let metricsHtml = "";
  if (report.type === "istanbul" && stats) {
    const color = statColor(stats.pct);
    metricsHtml = `<div class="metric-main" style="color:${color}">${stats.pct}%</div>
      <div class="metric-label">${esc(stats.label)}</div>`;
  } else if (report.type === "golden" && stats) {
    const color = statColor(stats.pct);
    metricsHtml = `<div class="metric-main" style="color:${color}">${stats.pct}%</div>
      <div class="metric-detail">${stats.covered}/${stats.total} ${esc(stats.unit)} &middot; ${stats.snaps} snapshots</div>`;
  } else if (report.type === "backlog" && stats) {
    const color = stats.pct ? statColor(stats.pct) : "#94a3b8";
    metricsHtml = `<div class="metric-main" style="color:${color}">${stats.pct ? stats.pct + "%" : stats.pending}</div>
      <div class="metric-detail">${stats.pending} pendentes &middot; ${stats.done} concluídos</div>`;
  } else {
    metricsHtml = `<div class="metric-main" style="color:#94a3b8">—</div>
      <div class="metric-label">${exists ? "Sem métricas" : "Não gerado"}</div>`;
  }

  return `<a href="${report.relativePath}" class="card ${exists ? "" : "disabled"}" ${!exists ? 'onclick="return false"' : ""}>
    <div class="card-icon">${report.icon}</div>
    <div class="card-body">
      <div class="card-title">${esc(report.title)}</div>
      <div class="card-subtitle">${esc(report.subtitle)}</div>
      <div class="card-metrics">
        ${metricsHtml}
      </div>
    </div>
    <div class="card-arrow">${exists ? "→" : "✕"}</div>
  </a>`;
}

function generate() {
  if (reports.length === 0) {
    console.log("[REPORTS] Nenhum report encontrado. Gere reports individuais primeiro.");
    return;
  }

  const cards = reports.map((r) => cardHtml(r, extractStats(r))).join("\n    ");

  const html = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>Reports — ${esc(PROJECT_NAME)}</title>
  <style>
    :root {
      --bg: #0f172a; --surface: #1e293b; --surface2: #334155;
      --text: #e2e8f0; --text2: #94a3b8; --accent: #22c55e;
      --accent2: #3b82f6; --border: #475569; --radius: 8px;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; min-height: 100vh; }
    .header { padding: 2rem 2rem 0; max-width: 1000px; margin: 0 auto; }
    .header h1 { font-size: 1.8rem; margin-bottom: 0.25rem; }
    .header p { color: var(--text2); font-size: 0.9rem; }
    .container { max-width: 1000px; margin: 2rem auto; padding: 0 2rem; }
    .cards { display: flex; flex-direction: column; gap: 1rem; }
    .card {
      display: flex; align-items: center; gap: 1rem;
      background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
      padding: 1.25rem 1.5rem; text-decoration: none; color: inherit;
      transition: border-color 0.15s, box-shadow 0.15s;
    }
    .card:hover { border-color: var(--accent2); box-shadow: 0 2px 12px rgba(0,0,0,0.2); }
    .card.disabled { opacity: 0.4; cursor: not-allowed; }
    .card.disabled:hover { border-color: var(--border); box-shadow: none; }
    .card-icon { font-size: 2rem; flex-shrink: 0; }
    .card-body { flex: 1; }
    .card-title { font-size: 1rem; font-weight: 600; color: var(--text); }
    .card-subtitle { font-size: 0.8rem; color: var(--text2); margin-top: 0.15rem; }
    .card-metrics { margin-top: 0.5rem; }
    .metric-main { font-size: 1.5rem; font-weight: 700; font-family: monospace; line-height: 1; }
    .metric-label { font-size: 0.75rem; color: var(--text2); margin-top: 0.15rem; }
    .metric-detail { font-size: 0.75rem; color: var(--text2); margin-top: 0.15rem; }
    .card-arrow { font-size: 1.25rem; color: var(--text2); flex-shrink: 0; }
    .how-to {
      margin-top: 1.5rem; padding: 1rem 1.25rem;
      background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
      font-size: 0.8rem; color: var(--text2);
    }
    .how-to strong { color: var(--text); }
    code { background: var(--surface2); padding: 0.15rem 0.4rem; border-radius: 4px; font-size: 0.8rem; }
    .timestamp { text-align: center; font-size: 0.8rem; color: var(--text2); margin-top: 2rem; padding-bottom: 2rem; }
    @media (max-width: 768px) { .header, .container { padding: 0 1rem; } }
    @media print { body { background: #fff; color: #000; } .card { border: 1px solid #ddd; } }
  </style>
</head>
<body>

<div class="header">
  <h1>${esc(PROJECT_NAME)} — Reports</h1>
  <p>Coverage, golden tests e backlog — ${reports.length} reports detectados</p>
</div>

<div class="container">
  <div class="cards">
    ${cards}
  </div>

  <div class="how-to">
    <strong>Como regenerar:</strong> <code>bash scripts/reports.sh</code>
  </div>

  <p class="timestamp">Gerado em ${new Date().toISOString().replace("T", " ").split(".")[0]} · <code>scripts/reports-index.js</code></p>
</div>

</body>
</html>`;

  if (!fs.existsSync(REPORTS_DIR)) fs.mkdirSync(REPORTS_DIR, { recursive: true });
  fs.writeFileSync(OUTPUT, html, "utf8");
  console.log(`[REPORTS] Página consolidada: ${OUTPUT} (${reports.length} reports)`);
}

generate();
