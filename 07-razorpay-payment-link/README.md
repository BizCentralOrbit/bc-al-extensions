# 07 — Send Razorpay Payment Link via WhatsApp from Business Central

Generate a Razorpay payment link from a Posted Sales Invoice in BC and send it to the customer on WhatsApp — all with one click. Built with a custom AL Extension, Razorpay REST API, and Meta WhatsApp Cloud API. **100% Free.**

▶ **[Watch the full tutorial on YouTube — BizCentralOrbit](https://youtube.com/@BizCentralOrbit)**

---

## What This Does

1. Open any **Posted Sales Invoice** in Business Central
2. Click **"Send Payment Link via WhatsApp"** (Process ribbon)
3. AL Extension calls Razorpay API → generates `rzp.io/l/xxxxxx` short link
4. AL Extension calls Meta WhatsApp Cloud API → customer receives the link on WhatsApp
5. Customer taps the link and pays online (UPI, card, net banking)

---

## Files

```
07-razorpay-payment-link/
├── .vscode/
│   └── launch.json                          ← Update tenant ID before publishing
├── Tables/
│   └── RazorpaySetup.al                     ← Table 50400 — stores API credentials
├── Pages/
│   └── RazorpaySetupPage.al                 ← Page 50400 — admin config UI
├── Codeunits/
│   └── RazorpayMgt.al                       ← Codeunit 50400 — all API logic
├── PageExtensions/
│   └── PostedSalesInvoiceRazorpayExt.al     ← PageExtension 50400 — adds button
└── app.json                                 ← ID range 50400–50409
```

---

## Setup & Deployment

### Step 1 — Get Razorpay API Keys
1. Sign up free at [razorpay.com](https://razorpay.com)
2. Go to **Settings → API Keys → Generate Test Key**
3. Copy **Key ID** (starts with `rzp_test_`) and **Key Secret** — secret shown only once!

### Step 2 — Get Meta WhatsApp Credentials
1. Go to [developers.facebook.com](https://developers.facebook.com) — free account
2. Create App → Add WhatsApp product
3. From **WhatsApp → API Setup** copy: **Phone Number ID** and **Access Token**
4. Use test number `+1 555 670 9706` — send "Hi" from your phone first to open the conversation window

### Step 3 — Deploy to BC Sandbox
1. Open this folder in **VS Code** with the AL Language extension
2. Edit `.vscode/launch.json` — replace `YOUR-TENANT-ID-HERE` with your real Tenant ID
3. Press **Ctrl+F5** → compiles and publishes to your BC Sandbox
4. Click Install when BC prompts

### Step 4 — Configure in BC
1. Search **"Razorpay Setup"** in BC (Alt+Q)
2. Enter Key ID, Key Secret, Business Name, WA Phone Number ID, WA Access Token
3. Set **Enabled = true**
4. Click **Test Connection** to validate

### Step 5 — Test
1. Open any Posted Sales Invoice (customer must have a phone number)
2. Click **"Send Payment Link via WhatsApp"** in the Process ribbon
3. Check Razorpay Dashboard → Payment Links for the new link
4. Check customer WhatsApp for the message

---

## Technical Notes

| Point | Detail |
|-------|--------|
| Auth | Basic Auth — Base64(`KeyID:KeySecret`). BC has a built-in `Base64 Convert` codeunit |
| Amount | Must be in paise (×100, integer). `Format(Round(Amount*100,1), 0, '<Integer>')` |
| JSON | Response parsed with `JObject.ReadFrom()` to extract `short_url` field |
| WA Phone | International format, no `+` or spaces — `919876543210` not `+91 98765 43210` |
| Token | Meta access token expires in ~24 hrs. For production use a permanent System User token |

---

## Security

- **Never commit real API keys** — enter them in BC Setup page only
- `launch.json` uses placeholder `YOUR-TENANT-ID-HERE` — replace locally, never push with real ID
- Key Secret and Access Token are masked fields in the BC Setup page

---

## Requirements

- Business Central Online (Sandbox or Production)
- VS Code + [AL Language extension](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)
- Free [Razorpay account](https://razorpay.com) (TEST mode works for demo)
- Free [Meta Developer account](https://developers.facebook.com)

---

*BizCentralOrbit — Free Business Central AL tutorials every week*
*Subscribe: [youtube.com/@BizCentralOrbit](https://youtube.com/@BizCentralOrbit)*
