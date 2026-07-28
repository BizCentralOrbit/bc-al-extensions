# Topic 2 — Live Sales Dashboard in Business Central

A free AL extension that renders a **real-time Sales Dashboard** inside BC using a Control Add-in and the HTML5 Canvas API — no Chart.js, no external CDN, no AppSource required.

> 📺 **Watch the full tutorial:** [YouTube — BizCentralOrbit]

---

## ✨ What It Does

- Reads live sales data directly from **Customer Ledger Entries**
- Displays a **12-month sales trend line chart** with gradient fill
- Shows **Top 5 Customers** as a horizontal bar chart
- Shows **3 KPI cards**: Total Sales, Order Count, Avg Monthly Sales
- One-click **Refresh Charts** button to reload data
- Works on BC Cloud (SaaS) — no external libraries or CDN

**Dashboard Preview:**

```
┌─────────────────────────────────────────────────────────┐
│  Total Sales: ₹526.4K  │  Orders: 206  │  Avg: ₹43.9K  │
├───────────────────────────────┬─────────────────────────┤
│  Monthly Sales (₹K)           │  Top Customers (₹K)     │
│  [line chart — 12 months]     │  Adatum Corp  ₹290.7K   │
│                               │  School of FA ₹272.4K   │
│                               │  Relecloud    ₹101.4K   │
└───────────────────────────────┴─────────────────────────┘
```

---

## 📁 File Structure

```
SalesDashboard_AL/
├── app.json
├── .vscode/
│   └── launch.json              ← Update with your tenant details
├── ControlAddins/
│   ├── SalesChartAddin.al       ← Control add-in declaration
│   └── js/
│       └── saleschart.js        ← Canvas chart rendering
├── Codeunits/
│   └── SalesDataMgmt.al         ← Reads BC data, builds JSON
└── Pages/
    └── SalesDashPage.al         ← Sales Dashboard page (ID 50201)
```

---

## 🚀 Deploy to Your Sandbox

**Step 1** — Open the `SalesDashboard_AL` folder in VS Code.

**Step 2** — Update `.vscode/launch.json`:
```json
"tenant": "YOUR-TENANT-ID",
"environmentName": "Sandbox"
```

**Step 3** — Press **Ctrl + F5** to publish.

**Step 4** — In BC, search for **Sales Dashboard** in the search bar (Alt + Q).

**Step 5** — The charts load automatically. Click **Refresh Charts** to reload.

---

## 🔑 Key Technical Points (for the curious)

| Topic | Detail |
|-------|--------|
| Data source | `Cust. Ledger Entry` — Document Type = Invoice, `Sales (LCY)` field |
| Chart library | None — pure HTML5 Canvas API (BC Cloud blocks external CDN in iframes) |
| BC integration | `StartupScript` (not `Scripts`) — guarantees `Microsoft.Dynamics.NAV` is available on load |
| Iframe height | Forced via `window.parent.document` + `MutationObserver` + `!important` |
| Format tokens | AL only supports `<Year4>` — `<Year2>` and `<Month Text,3>` are invalid |

---

## 🛠 Requirements

- VS Code + AL Language extension
- BC Platform 22.0+ (Business Central 2023 Wave 2 or later)
- Sandbox environment with sales data (works with CRONUS demo data)

---

## 📄 License

MIT — free to use and modify.
