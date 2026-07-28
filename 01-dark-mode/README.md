# Topic 1 — Dark Mode for Business Central

A free AL extension that adds a **Dark Mode toggle** to Microsoft Dynamics 365 Business Central.  
No third-party tools. No AppSource. Just install and switch.

> 📺 **Watch the full tutorial:** [YouTube — BizCentralOrbit]

---

## ✨ What It Does

- Adds a **Dark Mode On/Off** button to the BC Role Center
- Applies a dark theme across the entire BC UI using a Control Add-in + CSS injection
- Toggle persists per session
- Works on BC Cloud (SaaS) sandbox

**Before / After:**

| Light Mode (Default) | Dark Mode |
|----------------------|-----------|
| Standard white BC UI | Deep dark theme with teal accents |

---

## 📁 File Structure

```
DarkModeBC_AL/
├── app.json
├── .vscode/
│   └── launch.json          ← Update with your tenant details
├── ControlAddins/
│   └── DarkModeAddin/
│       ├── DarkModeAddin.al  ← Control add-in declaration
│       └── js/
│           └── darkmode.js   ← CSS injection logic
└── PageExtensions/
    ├── DarkModePartPage.al   ← CardPart page with the toggle control
    └── RoleCenterExt.al      ← Adds the Dark Mode part to Role Center
```

---

## 🚀 Deploy to Your Sandbox

**Step 1** — Open the `DarkModeBC_AL` folder in VS Code.

**Step 2** — Update `.vscode/launch.json`:
```json
"tenant": "YOUR-TENANT-ID",
"environmentName": "Sandbox"
```

**Step 3** — Press **Ctrl + F5** to publish.

**Step 4** — Open Business Central → your Role Center → click **Dark Mode** button.

---

## 🛠 Requirements

- VS Code + AL Language extension
- BC Platform 22.0+ (Business Central 2023 Wave 2 or later)
- Sandbox environment

---

## 📄 License

MIT — free to use and modify.
