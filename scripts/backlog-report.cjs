#!/usr/bin/env node
// framework-tag: v2.17.1 framework-file: scripts/backlog-report.cjs
/**
 * Backlog Report — HTML navegável
 *
 * Gera relatório HTML mostrando:
 * - Pendentes agrupados por fase (F1, F2, F3, T)
 * - Concluídos com datas
 * - Métricas: total, por tipo, por camada, por severidade
 * - Decisões futuras
 *
 * Uso: node scripts/backlog-report.cjs
 * Output: docs/backlog-report.html
 */

const fs = require("fs");
const path = require("path");

const BACKLOG = path.join(__dirname, "..", ".claude", "specs", "backlog.md");
const OUTPUT = path.join(__dirname, "..", "docs", "backlog-report.html");

// ─── Config ───
// Customize these for your project
const PROJECT_NAME = process.env.PROJECT_NAME || path.basename(path.join(__dirname, ".."));
const FASE_LABELS = {
  F1: "Fase 1 — Quick Wins",
  F2: "Fase 2 — Diferenciação",
  F3: "Fase 3 — Expansão",
  T: "Testes e Qualidade",
};

// ─── 1. Parse backlog.md ───

function parseTable(lines) {
  const rows = [];
  for (const line of lines) {
    if (!line.startsWith("|") || line.includes("---")) continue;
    const cells = line
      .split("|")
      .slice(1, -1)
      .map((c) => c.trim());
    if (cells.length < 2) continue;
    rows.push(cells);
  }
  // Remove header row
  if (rows.length > 0 && (rows[0][0] === "ID" || rows[0][0] === "Emoji")) {
    rows.shift();
  }
  return rows;
}

function parseBacklog() {
  const content = fs.readFileSync(BACKLOG, "utf-8");
  const lines = content.split("\n");

  let section = null;
  const sections = { pendentes: [], concluidos: [], decisoes: [], notas: [] };
  const sectionLines = { pendentes: [], concluidos: [], decisoes: [], notas: [] };

  // Extract last update date
  const updateMatch = content.match(/Última atualização:\s*(.+)/);
  const lastUpdate = updateMatch ? updateMatch[1].trim() : "—";

  for (const line of lines) {
    if (line.startsWith("## Pendentes")) { section = "pendentes"; continue; }
    if (line.startsWith("## Concluídos")) { section = "concluidos"; continue; }
    if (line.startsWith("## Decisões futuras")) { section = "decisoes"; continue; }
    if (line.startsWith("## Notas")) { section = "notas"; continue; }
    if (section && sectionLines[section]) {
      sectionLines[section].push(line);
    }
  }

  // Parse pendentes: ID | Fase | Item | Sev. | Impacto | Tipo | Camadas | Compl. | Est. | Deps | Origem | Spec
  for (const cells of parseTable(sectionLines.pendentes)) {
    if (cells.length >= 12) {
      sections.pendentes.push({
        id: cells[0], fase: cells[1], item: cells[2], sev: cells[3],
        impacto: cells[4], tipo: cells[5], camadas: cells[6],
        compl: cells[7], est: cells[8], deps: cells[9],
        origem: cells[10], spec: cells[11],
      });
    }
  }

  // Parse concluidos: ID | Item | Concluído em
  for (const cells of parseTable(sectionLines.concluidos)) {
    if (cells.length >= 3) {
      sections.concluidos.push({ id: cells[0], item: cells[1], data: cells[2] });
    }
  }

  // Parse decisoes: ID | Decisão | Gatilho | Recomendação | Ref
  for (const cells of parseTable(sectionLines.decisoes)) {
    if (cells.length >= 5) {
      sections.decisoes.push({
        id: cells[0], decisao: cells[1], gatilho: cells[2],
        recomendacao: cells[3], ref: cells[4],
      });
    }
  }

  return { ...sections, lastUpdate };
}

// ─── 2. Compute metrics ───

function computeMetrics(data) {
  const { pendentes, concluidos } = data;

  const byFase = {};
  const byTipo = {};
  const byCamada = {};
  const bySev = {};
  const byImpacto = {};

  for (const p of pendentes) {
    byFase[p.fase] = (byFase[p.fase] || 0) + 1;
    byTipo[p.tipo] = (byTipo[p.tipo] || 0) + 1;
    bySev[p.sev] = (bySev[p.sev] || 0) + 1;
    byImpacto[p.impacto] = (byImpacto[p.impacto] || 0) + 1;
    for (const c of p.camadas.replace(/`/g, "").split(",")) {
      const tag = c.trim();
      if (tag && tag !== "—") byCamada[tag] = (byCamada[tag] || 0) + 1;
    }
  }

  // Concluídos por mês
  const byMonth = {};
  for (const c of concluidos) {
    const match = c.data.match(/(\d{4}-\d{2})/);
    if (match) {
      byMonth[match[1]] = (byMonth[match[1]] || 0) + 1;
    }
  }

  return { byFase, byTipo, byCamada, bySev, byImpacto, byMonth };
}

// ─── 3. Generate HTML ───

function esc(s) {
  return String(s || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function sevColor(sev) {
  if (sev.includes("🔴")) return "#dc2626";
  if (sev.includes("🟠")) return "#ea580c";
  if (sev.includes("🟡")) return "#ca8a04";
  if (sev.includes("⚪")) return "#9ca3af";
  return "#6b7280";
}

function complColor(compl) {
  if (compl.includes("🟢")) return "#16a34a";
  if (compl.includes("🟡")) return "#ca8a04";
  if (compl.includes("🔴")) return "#dc2626";
  return "#6b7280";
}

function generateHTML(data, metrics) {
  const { pendentes, concluidos, decisoes, lastUpdate } = data;
  const { byFase, byTipo, byCamada, bySev, byImpacto, byMonth } = metrics;

  const totalPendentes = pendentes.length;
  const totalConcluidos = concluidos.length;
  const totalGeral = totalPendentes + totalConcluidos;
  const pctDone = totalGeral > 0 ? ((totalConcluidos / totalGeral) * 100).toFixed(1) : 0;

  // Group pendentes by fase
  const fases = Object.keys(FASE_LABELS);
  const grouped = {};
  for (const f of fases) grouped[f] = [];
  for (const p of pendentes) {
    const f = p.fase || "F2";
    if (!grouped[f]) grouped[f] = [];
    grouped[f].push(p);
  }

  // Metrics cards HTML
  function metricCards(obj, label) {
    const entries = Object.entries(obj).sort((a, b) => b[1] - a[1]);
    if (entries.length === 0) return "";
    return `
      <div class="metric-group">
        <h4>${esc(label)}</h4>
        <div class="chips">
          ${entries.map(([k, v]) => `<span class="chip">${esc(k)} <strong>${v}</strong></span>`).join("")}
        </div>
      </div>`;
  }

  // Pendentes table for a fase
  function pendentesTable(items) {
    if (items.length === 0) return '<p class="empty">Nenhum item nesta fase.</p>';
    return `
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Item</th><th>Sev.</th><th>Impacto</th>
            <th>Tipo</th><th>Camadas</th><th>Compl.</th><th>Est.</th><th>Deps</th><th>Spec</th>
          </tr>
        </thead>
        <tbody>
          ${items
            .map(
              (p) => `
            <tr>
              <td class="id-cell">${esc(p.id)}</td>
              <td class="item-cell">${esc(p.item)}</td>
              <td style="color:${sevColor(p.sev)}">${esc(p.sev)}</td>
              <td>${esc(p.impacto)}</td>
              <td><span class="badge">${esc(p.tipo)}</span></td>
              <td><code>${esc(p.camadas)}</code></td>
              <td style="color:${complColor(p.compl)}">${esc(p.compl)}</td>
              <td>${esc(p.est)}</td>
              <td>${esc(p.deps)}</td>
              <td>${esc(p.spec)}</td>
            </tr>`
            )
            .join("")}
        </tbody>
      </table>`;
  }

  // Month chart (simple bar)
  function monthChart() {
    const entries = Object.entries(byMonth).sort((a, b) => a[0].localeCompare(b[0]));
    if (entries.length === 0) return "";
    const max = Math.max(...entries.map(([, v]) => v));
    return `
      <div class="metric-group">
        <h4>Concluídos por mês</h4>
        <div class="bar-chart">
          ${entries
            .map(
              ([month, count]) => `
            <div class="bar-row">
              <span class="bar-label">${esc(month)}</span>
              <div class="bar" style="width:${(count / max) * 100}%">${count}</div>
            </div>`
            )
            .join("")}
        </div>
      </div>`;
  }

  return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${esc(PROJECT_NAME)} — Backlog Report</title>
  <style>
    :root {
      --bg: #0f172a; --surface: #1e293b; --surface2: #334155;
      --text: #e2e8f0; --text2: #94a3b8; --accent: #22c55e;
      --accent2: #3b82f6; --border: #475569; --radius: 8px;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: var(--bg); color: var(--text);
      line-height: 1.6; padding: 2rem; max-width: 1400px; margin: 0 auto;
    }
    h1 { font-size: 1.8rem; margin-bottom: 0.25rem; }
    h2 { font-size: 1.3rem; margin: 2rem 0 1rem; color: var(--accent); border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; }
    h3 { font-size: 1.1rem; margin: 1.5rem 0 0.75rem; color: var(--accent2); }
    h4 { font-size: 0.85rem; color: var(--text2); margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.05em; }
    .subtitle { color: var(--text2); font-size: 0.9rem; margin-bottom: 2rem; }

    /* Summary cards */
    .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
    .card {
      background: var(--surface); border-radius: var(--radius); padding: 1.25rem;
      border: 1px solid var(--border); text-align: center;
    }
    .card .number { font-size: 2rem; font-weight: 700; font-family: monospace; }
    .card .label { font-size: 0.8rem; color: var(--text2); margin-top: 0.25rem; }
    .card.green .number { color: var(--accent); }
    .card.blue .number { color: var(--accent2); }
    .card.orange .number { color: #f59e0b; }

    /* Progress bar */
    .progress-container { margin-bottom: 2rem; }
    .progress-bar { background: var(--surface2); border-radius: 999px; height: 24px; overflow: hidden; position: relative; }
    .progress-fill { background: var(--accent); height: 100%; border-radius: 999px; transition: width 0.3s; display: flex; align-items: center; justify-content: flex-end; padding-right: 8px; font-size: 0.75rem; font-weight: 600; color: #000; min-width: 40px; }

    /* Metrics */
    .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
    .metric-group { background: var(--surface); border-radius: var(--radius); padding: 1rem; border: 1px solid var(--border); }
    .chips { display: flex; flex-wrap: wrap; gap: 0.4rem; }
    .chip { background: var(--surface2); padding: 0.25rem 0.6rem; border-radius: 999px; font-size: 0.8rem; white-space: nowrap; }
    .chip strong { color: var(--accent); margin-left: 0.3rem; }

    /* Bar chart */
    .bar-chart { display: flex; flex-direction: column; gap: 0.4rem; }
    .bar-row { display: flex; align-items: center; gap: 0.5rem; }
    .bar-label { font-size: 0.8rem; color: var(--text2); min-width: 60px; text-align: right; font-family: monospace; }
    .bar { background: var(--accent); border-radius: 4px; padding: 2px 8px; font-size: 0.75rem; font-weight: 600; color: #000; min-width: 28px; text-align: right; }

    /* Tables */
    table { width: 100%; border-collapse: collapse; font-size: 0.85rem; margin-bottom: 1rem; }
    thead { background: var(--surface2); }
    th { padding: 0.6rem 0.5rem; text-align: left; font-weight: 600; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.04em; color: var(--text2); white-space: nowrap; }
    td { padding: 0.5rem; border-bottom: 1px solid var(--border); vertical-align: top; }
    tr:hover { background: rgba(255,255,255,0.03); }
    .id-cell { font-family: monospace; font-weight: 600; color: var(--accent2); white-space: nowrap; font-size: 0.8rem; }
    .item-cell { max-width: 400px; }
    .date-cell { font-family: monospace; font-size: 0.8rem; color: var(--text2); white-space: nowrap; }
    code { background: var(--surface2); padding: 0.15rem 0.4rem; border-radius: 4px; font-size: 0.8rem; }
    .badge { background: var(--accent2); color: #fff; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.7rem; font-weight: 600; white-space: nowrap; }
    .empty { color: var(--text2); font-style: italic; padding: 1rem 0; }

    /* Nav */
    .nav { position: sticky; top: 0; background: var(--bg); padding: 0.75rem 0; border-bottom: 1px solid var(--border); margin-bottom: 1.5rem; z-index: 10; display: flex; gap: 1rem; flex-wrap: wrap; }
    .nav a { color: var(--accent2); text-decoration: none; font-size: 0.85rem; padding: 0.3rem 0.6rem; border-radius: 4px; }
    .nav a:hover { background: var(--surface); }

    /* Fase section */
    .fase-header { display: flex; align-items: center; gap: 0.75rem; }
    .fase-count { background: var(--surface2); padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; font-family: monospace; }

    /* Decisões */
    .decisao-card { background: var(--surface); border-radius: var(--radius); padding: 1rem; border: 1px solid var(--border); margin-bottom: 0.75rem; }
    .decisao-card .gatilho { color: #f59e0b; font-size: 0.85rem; margin-top: 0.5rem; }
    .decisao-card .rec { color: var(--text2); font-size: 0.85rem; margin-top: 0.25rem; }

    @media (max-width: 768px) {
      body { padding: 1rem; }
      .summary { grid-template-columns: repeat(2, 1fr); }
      table { font-size: 0.75rem; }
      .item-cell { max-width: 200px; }
    }

    @media print {
      body { background: #fff; color: #000; }
      .nav { display: none; }
      .card { border: 1px solid #ddd; }
      table { border: 1px solid #ddd; }
      td, th { border: 1px solid #ddd; }
    }
  </style>
</head>
<body>

<h1>${esc(PROJECT_NAME)} — Backlog</h1>
<p class="subtitle">Gerado em ${new Date().toISOString().slice(0, 16).replace("T", " ")} · Última atualização: ${esc(lastUpdate)}</p>

<nav class="nav">
  <a href="#resumo">Resumo</a>
  <a href="#metricas">Métricas</a>
  ${fases.filter((f) => (grouped[f] || []).length > 0).map((f) => `<a href="#fase-${f}">${f}</a>`).join("")}
  <a href="#concluidos">Concluídos (${totalConcluidos})</a>
  ${decisoes.length > 0 ? '<a href="#decisoes">Decisões Futuras</a>' : ""}
</nav>

<section id="resumo">
  <h2>Resumo</h2>
  <div class="summary">
    <div class="card blue"><div class="number">${totalPendentes}</div><div class="label">Pendentes</div></div>
    <div class="card green"><div class="number">${totalConcluidos}</div><div class="label">Concluídos</div></div>
    <div class="card orange"><div class="number">${pctDone}%</div><div class="label">Progresso</div></div>
    ${fases.map((f) => `<div class="card"><div class="number">${byFase[f] || 0}</div><div class="label">${esc(f)} — ${esc((FASE_LABELS[f] || f).replace(/^Fase \d+ — /, ""))}</div></div>`).join("")}
  </div>
  <div class="progress-container">
    <div class="progress-bar">
      <div class="progress-fill" style="width:${pctDone}%">${pctDone}%</div>
    </div>
  </div>
</section>

<section id="metricas">
  <h2>Métricas</h2>
  <div class="metrics">
    ${metricCards(byTipo, "Por tipo")}
    ${metricCards(byCamada, "Por camada")}
    ${metricCards(bySev, "Por severidade")}
    ${metricCards(byImpacto, "Por impacto")}
    ${monthChart()}
  </div>
</section>

${fases
  .filter((f) => (grouped[f] || []).length > 0)
  .map(
    (f) => `
<section id="fase-${f}">
  <h2>
    <span class="fase-header">
      ${esc(FASE_LABELS[f] || f)}
      <span class="fase-count">${grouped[f].length} itens</span>
    </span>
  </h2>
  ${pendentesTable(grouped[f])}
</section>`
  )
  .join("")}

<section id="concluidos">
  <h2>Concluídos (${totalConcluidos})</h2>
  ${
    concluidos.length > 0
      ? `<table>
        <thead><tr><th>ID</th><th>Item</th><th>Data</th></tr></thead>
        <tbody>
          ${concluidos
            .map(
              (c) => `
            <tr>
              <td class="id-cell">${esc(c.id)}</td>
              <td class="item-cell">${esc(c.item)}</td>
              <td class="date-cell">${esc(c.data)}</td>
            </tr>`
            )
            .join("")}
        </tbody>
      </table>`
      : '<p class="empty">Nenhum item concluído.</p>'
  }
</section>

${
  decisoes.length > 0
    ? `
<section id="decisoes">
  <h2>Decisões Futuras (${decisoes.length})</h2>
  ${decisoes
    .map(
      (d) => `
    <div class="decisao-card">
      <strong>${esc(d.id)}</strong> — ${esc(d.decisao)}
      <div class="gatilho">Gatilho: ${esc(d.gatilho)}</div>
      <div class="rec">Recomendação: ${esc(d.recomendacao)}</div>
    </div>`
    )
    .join("")}
</section>`
    : ""
}

<footer style="margin-top:3rem;padding-top:1rem;border-top:1px solid var(--border);color:var(--text2);font-size:0.8rem;">
  ${esc(PROJECT_NAME)} · Gerado por <code>scripts/backlog-report.cjs</code>
</footer>

</body>
</html>`;
}

// ─── 4. Main ───

const data = parseBacklog();
const metrics = computeMetrics(data);
const html = generateHTML(data, metrics);

// Ensure output dir exists
const outDir = path.dirname(OUTPUT);
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

fs.writeFileSync(OUTPUT, html, "utf-8");

console.log(`✅ Backlog report gerado: ${OUTPUT}`);
console.log(`   Pendentes: ${data.pendentes.length} | Concluídos: ${data.concluidos.length} | Decisões: ${data.decisoes.length}`);
