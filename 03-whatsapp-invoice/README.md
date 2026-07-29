# Topic 3 — Send Sales Invoice via WhatsApp

A free AL extension for Microsoft Dynamics 365 Business Central that sends **Posted Sales Invoices directly to customers on WhatsApp** using the Meta WhatsApp Business Cloud API.

> 📺 **Watch the full tutorial:** [YouTube — BizCentralOrbit]

---

## ✨ What It Does

- Adds a **"Send via WhatsApp"** button to the Posted Sales Invoice page (Process ribbon)
- Sends invoice details (number, customer, amount, due date) as a formatted WhatsApp text message
- Uses **Meta WhatsApp Cloud API v25.0** — 100% free for testing
- Configurable via the **WhatsApp Setup** page in BC (searchable with Alt+Q)
- **No third-party connectors** — pure AL + HTTP, direct call to Meta Graph API

**Message sent to customer's phone:**
```
Invoice from BizCentralOrbit
----------------------------
Invoice No : PS-INV103296
Customer   : Alpine Ski House
Amount     : 2,062.96
Due Date   : 31 May 2026
----------------------------
Thank you for your business!
```

---

## 📁 File Structure

```
03-whatsapp-invoice/
├── app.json
├── .vscode/
│   └── launch.json                  ← Update with your tenant ID
├── Tables/
│   └── WASetup.al                   ← API credentials table (Table 50300)
├── Pages/
│   └── WASetupPage.al               ← Admin card page (Page 50300)
├── Codeunits/
│   └── WAMessageMgt.al              ← HTTP + JSON logic (Codeunit 50300)
└── PageExtensions/
    └── PostedSalesInvoiceExt.al     ← Adds Send button to invoice (PageExt 50300)
```

---

## 🚀 Deploy to Your Sandbox

**Step 1** — Open the `03-whatsapp-invoice` folder in VS Code.

**Step 2** — Update `.vscode/launch.json`:
```json
"tenant": "YOUR-ACTUAL-TENANT-ID",
"environmentName": "Sandbox"
```
Your tenant ID is the GUID from `https://businesscentral.dynamics.com/YOUR-TENANT-ID/`.

**Step 3** — Press **Ctrl + F5** to publish to your BC Sandbox.

**Step 4** — In BC, press **Alt+Q** and search for **"WhatsApp Setup"**. Enter your credentials:

| Field | Value |
|-------|-------|
| Phone Number ID | From Meta App → API Setup |
| Access Token | From Meta App → Generate token |
| API Version | `v25.0` |
| Business Name | Your company name |
| Enabled | ✅ ON |

**Step 5** — Open any Posted Sales Invoice → click **"Send via WhatsApp"** in the Process ribbon.

---

## ⚙️ Meta API Setup (5 minutes, 100% free)

1. Go to [developers.facebook.com](https://developers.facebook.com) → Register (personal Facebook account works)
2. Create App → Use case: **Connect with customers through WhatsApp**
3. App Dashboard → Use Cases → WhatsApp → **Customize** → **API Setup**
4. Click **Generate access token** → copy **Phone Number ID** + **Access Token**
5. Free test sender number: **+1 555 670 9706** (provided by Meta)

> ⚠️ **Conversation Window:** Before sending your first message, open WhatsApp on your phone, find `+1 555 670 9706`, and send "Hi". This opens the 24-hour conversation window that Meta requires for the free tier.

---

## 🔑 Key Technical Points

| Topic | Detail |
|-------|--------|
| API endpoint | `POST https://graph.facebook.com/v25.0/{PhoneNumberID}/messages` |
| Authentication | `Authorization: Bearer {AccessToken}` request header |
| Token lifespan | Temporary token expires ~24 hrs — use System User Token for production |
| Phone lookup | Reads `Sell-to Phone No.` from invoice, falls back to Customer card `Phone No.` |
| Phone cleaning | `CleanPhoneNo()` strips all non-digit characters — pass international format |
| JSON escaping | `EscapeJson()` handles `\`, `"`, and newlines → `\n` |
| Object IDs | Table 50300, Page 50300, Codeunit 50300, PageExt 50300 (ID range 50300–50309) |

---

## 🛠 Requirements

- VS Code + [AL Language extension](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)
- BC Platform 22.0+ (Business Central 2023 Wave 2 or later)
- Sandbox environment
- Free Meta Developer account at [developers.facebook.com](https://developers.facebook.com)

---

## 📄 License

MIT — free to use and modify.
