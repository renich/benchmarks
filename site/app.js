// Interactive Benchmark Dashboard Logic

let benchmarkData = null;
let currentSuiteId = "one_million";
let currentMode = "optimized"; // 'optimized' | 'naive'
let currentCategoryFilter = "all";

const SUITE_ICONS = {
  one_million: "⚡",
  pipeline: "🔀",
  tree_walk: "📁",
  async_checker: "⏱️",
};

document.addEventListener("DOMContentLoaded", () => {
  if (window.BENCHMARK_DATA) {
    benchmarkData = window.BENCHMARK_DATA;
    initDashboard();
  } else {
    fetch("benchmark_data.json")
      .then((res) => res.json())
      .then((data) => {
        benchmarkData = data;
        initDashboard();
      })
      .catch((err) => {
        console.error("Failed to load benchmark data:", err);
      });
  }
});

function initDashboard() {
  if (!benchmarkData || !benchmarkData.suites) return;

  const suites = Object.keys(benchmarkData.suites);
  if (!suites.includes(currentSuiteId) && suites.length > 0) {
    currentSuiteId = suites[0];
  }

  renderSystemSpecs(benchmarkData.system);
  setupSuiteControls();
  renderDashboard();

  // Attach Mode Switcher handlers
  document.querySelectorAll("[data-mode-btn]").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      document.querySelectorAll("[data-mode-btn]").forEach((b) => b.classList.remove("active"));
      e.target.classList.add("active");
      currentMode = e.target.getAttribute("data-mode-btn");
      renderDashboard();
    });
  });

  // Attach Category Filter handler
  const filterSelect = document.getElementById("category-filter");
  if (filterSelect) {
    filterSelect.addEventListener("change", (e) => {
      currentCategoryFilter = e.target.value;
      renderDashboard();
    });
  }
}

function renderSystemSpecs(system) {
  if (!system) return;
  const hostEl = document.getElementById("host-specs");
  if (hostEl) {
    hostEl.textContent = `${system.cpu_model} (${system.cpu_cores} vCPUs) | ${system.os} (${system.architecture}) | RAM: ${system.total_memory_mb} MB`;
  }
  const dateEl = document.getElementById("run-timestamp");
  if (dateEl && system.timestamp) {
    dateEl.textContent = new Date(system.timestamp).toLocaleString();
  }
}

function setupSuiteControls() {
  const suites = Object.keys(benchmarkData.suites);
  const tabsList = document.getElementById("suite-tabs-list");
  const selectEl = document.getElementById("suite-select");

  if (tabsList) {
    tabsList.innerHTML = "";
    suites.forEach((suiteId) => {
      const suite = benchmarkData.suites[suiteId];
      const icon = SUITE_ICONS[suiteId] || "📊";
      const li = document.createElement("li");
      const btn = document.createElement("button");
      btn.id = `tab-btn-${suiteId}`;
      btn.className = `suite-tab-btn ${suiteId === currentSuiteId ? "active" : ""}`;
      btn.innerHTML = `<span>${icon}</span> <span>${suite.title || suiteId}</span>`;
      btn.addEventListener("click", () => {
        if (currentSuiteId === suiteId) return;
        currentSuiteId = suiteId;
        updateSuiteActiveState();
        renderDashboard();
      });
      li.appendChild(btn);
      tabsList.appendChild(li);
    });
  }

  if (selectEl) {
    selectEl.innerHTML = "";
    suites.forEach((suiteId) => {
      const suite = benchmarkData.suites[suiteId];
      const icon = SUITE_ICONS[suiteId] || "📊";
      const opt = document.createElement("option");
      opt.value = suiteId;
      opt.textContent = `${icon} ${suite.title || suiteId}`;
      opt.selected = suiteId === currentSuiteId;
      selectEl.appendChild(opt);
    });

    selectEl.addEventListener("change", (e) => {
      const selected = e.target.value;
      if (currentSuiteId === selected) return;
      currentSuiteId = selected;
      updateSuiteActiveState();
      renderDashboard();
    });
  }
}

function updateSuiteActiveState() {
  const suites = Object.keys(benchmarkData.suites);
  suites.forEach((suiteId) => {
    const btn = document.getElementById(`tab-btn-${suiteId}`);
    if (btn) {
      if (suiteId === currentSuiteId) {
        btn.classList.add("active");
        btn.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "center" });
      } else {
        btn.classList.remove("active");
      }
    }
  });

  const selectEl = document.getElementById("suite-select");
  if (selectEl) {
    selectEl.value = currentSuiteId;
  }
}

function formatDurationMs(seconds) {
  if (seconds === undefined || seconds === null || isNaN(seconds)) return "-";
  const ms = seconds * 1000.0;
  if (ms < 1.0) {
    return `${ms.toFixed(2)} ms`;
  } else if (ms < 100.0) {
    return `${ms.toFixed(1)} ms`;
  } else if (ms < 1000.0) {
    return `${ms.toFixed(1)} ms`;
  } else {
    return `${ms.toLocaleString(undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 })} ms`;
  }
}

function renderDashboard() {
  const suite = benchmarkData.suites[currentSuiteId];
  if (!suite) return;

  document.getElementById("suite-title").textContent = suite.title;
  document.getElementById("suite-description").textContent = suite.description;

  const modeData = suite.modes[currentMode] || [];

  // Filter by category
  const filteredData = modeData.filter((item) => {
    if (currentCategoryFilter === "all") return true;
    return item.category.toLowerCase().includes(currentCategoryFilter.toLowerCase());
  });

  renderStatCards(modeData);
  renderVisualCharts(filteredData, modeData);
  renderLeaderboardTable(filteredData);
}

function renderStatCards(modeData) {
  if (!modeData || modeData.length === 0) return;

  const fastest = modeData[0];
  const slowest = modeData[modeData.length - 1];
  const medianTimes = modeData.map((d) => d.stats.median_seconds);
  const avgMedian = medianTimes.reduce((a, b) => a + b, 0) / medianTimes.length;

  document.getElementById("stat-fastest-name").textContent = fastest.name;
  document.getElementById("stat-fastest-val").textContent = formatDurationMs(fastest.stats.median_seconds);
  document.getElementById("stat-fastest-sub").textContent = fastest.version || "";

  document.getElementById("stat-avg-val").textContent = formatDurationMs(avgMedian);
  document.getElementById("stat-count-val").textContent = modeData.length;

  const maxSpeedup = (slowest.stats.median_seconds / (fastest.stats.median_seconds || 0.0001)).toFixed(1);
  document.getElementById("stat-spread-val").textContent = `${maxSpeedup}x`;
}

function getCategoryClass(category) {
  const cat = category.toLowerCase();
  if (cat.includes("compiled")) return "compiled";
  if (cat.includes("jit") || cat.includes("vm")) return "jit";
  return "interpreted";
}

function renderVisualCharts(data, allModeData) {
  const chartContainer = document.getElementById("chart-bars");
  if (!chartContainer) return;
  chartContainer.innerHTML = "";

  if (data.length === 0) {
    chartContainer.innerHTML = "<p style='padding: 1rem; color: var(--pico-muted-color);'>No entries match the selected filter.</p>";
    return;
  }

  const maxTime = Math.max(...allModeData.map((d) => d.stats.median_seconds), 0.0001);

  data.forEach((item) => {
    const catClass = getCategoryClass(item.category);
    const pct = Math.max(1, (item.stats.median_seconds / maxTime) * 100);

    const row = document.createElement("div");
    row.className = "chart-bar-row";
    row.innerHTML = `
      <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 0.25rem;">
        <span style="font-weight: 600;">#${item.rank} ${item.name}</span>
        <span style="font-family: monospace; color: var(--pico-muted-color);">${formatDurationMs(item.stats.median_seconds)} (${item.speedup_factor}x)</span>
      </div>
      <div class="bar-track">
        <div class="bar-fill bar-${catClass}" style="width: ${pct}%;"></div>
      </div>
    `;
    chartContainer.appendChild(row);
  });
}

function renderLeaderboardTable(data) {
  const tbody = document.getElementById("leaderboard-body");
  if (!tbody) return;
  tbody.innerHTML = "";

  if (data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 2rem; color: var(--pico-muted-color);">No implementations found.</td></tr>`;
    return;
  }

  data.forEach((item) => {
    const catClass = getCategoryClass(item.category);
    const rankClass = item.rank <= 3 ? `rank-${item.rank}` : "rank-other";

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>
        <span class="rank-badge ${rankClass}">#${item.rank}</span>
      </td>
      <td>
        <strong>${item.name}</strong>
        <br>
        <small style="color: var(--pico-muted-color); font-size: 0.75rem;">${escapeHtml(item.version || "")}</small>
      </td>
      <td>
        <span class="badge badge-${catClass}">${item.category}</span>
      </td>
      <td>
        <strong style="font-family: monospace; font-size: 0.95rem;">${formatDurationMs(item.stats.median_seconds)}</strong>
        <br>
        <small style="color: var(--pico-muted-color); font-family: monospace; font-size: 0.75rem;">[${formatDurationMs(item.stats.min_seconds)} – ${formatDurationMs(item.stats.max_seconds)}]</small>
      </td>
      <td>
        <span class="speedup-pill" style="color: ${item.rank === 1 ? 'var(--pico-primary)' : 'var(--pico-color)'}">
          ${item.rank === 1 ? '⚡ 1.0x (Baseline)' : `${item.speedup_factor}x`}
        </span>
      </td>
      <td style="font-family: monospace; font-size: 0.9rem;">
        ${item.stats.max_rss_mb ? `${item.stats.max_rss_mb} MB` : 'N/A'}
      </td>
      <td style="text-align: right;">
        <button class="outline btn-inspect" onclick="openCodeModal('${item.id}')">Inspect</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function openCodeModal(langId) {
  const suite = benchmarkData.suites[currentSuiteId];
  const modeData = suite.modes[currentMode];
  const item = modeData.find((d) => d.id === langId);
  if (!item) return;

  document.getElementById("modal-lang-title").textContent = `${item.name} (${currentMode.toUpperCase()} Implementation)`;
  document.getElementById("modal-run-cmd").textContent = item.run_command || item.file;
  document.getElementById("modal-code").textContent = item.source_code || "";

  const modal = document.getElementById("code-modal");
  if (modal) {
    modal.setAttribute("open", "true");
  }
}

function closeCodeModal() {
  const modal = document.getElementById("code-modal");
  if (modal) {
    modal.removeAttribute("open");
  }
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
