// ============================================================
// darkmode.js — Business Central Dark Mode
// Publisher   : BizCentralOrbit
// Version     : 2.0.0
// How it works: Injects CSS overrides + a floating toggle button
//               into BC's DOM. No AL triggers required.
//               Preference saved in localStorage (persists).
// ============================================================

(function () {
    'use strict';

    var STORAGE_KEY  = 'bco_dark_mode';
    var STYLE_TAG_ID = 'bco-dark-mode-style';
    var BTN_ID       = 'bco-dark-toggle-btn';

    // ── DARK THEME CSS ─────────────────────────────────────────
    var darkCSS = [
        'body { background-color: #1a1a2e !important; color: #e0e0e0 !important; }',
        '.ms-nav { background-color: #16213e !important; }',
        '.ms-nav-band { background-color: #0d1b2a !important; }',
        '.ms-nav-content-container { background-color: #1a1a2e !important; }',
        '.ms-nav-content { background-color: #1a1a2e !important; }',
        '.ms-nav-content-body { background-color: #1a1a2e !important; }',
        '.ms-nav-content-title { color: #7ec8e3 !important; }',
        '.ms-nav-actionbar { background-color: #16213e !important; border-color: #0d1b2a !important; }',
        '.ms-nav-actionbar-container { background-color: #16213e !important; }',
        '.ms-nav-actionbar button { color: #e0e0e0 !important; }',
        '.ms-nav-actionbar button:hover { background-color: #0f3460 !important; }',
        'h1, h2, h3, h4, h5, h6 { color: #7ec8e3 !important; }',
        '.ms-nav-title { color: #7ec8e3 !important; }',
        'label { color: #cccccc !important; }',
        '.card { background-color: #16213e !important; border-color: #0f3460 !important; }',
        '[class*="factbox"] { background-color: #16213e !important; color: #e0e0e0 !important; }',
        '[class*="FastTab"] { background-color: #16213e !important; }',
        'input[type="text"], input[type="number"], input[type="email"], input[type="search"], input[type="date"] {',
        '  background-color: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }',
        'textarea { background-color: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }',
        'select { background-color: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }',
        'table { background-color: #1a1a2e !important; color: #e0e0e0 !important; }',
        'thead, th { background-color: #0f3460 !important; color: #ffffff !important; border-color: #16213e !important; }',
        'tbody tr td { background-color: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }',
        'tbody tr:hover td { background-color: #0f3460 !important; }',
        'tbody tr.selected td { background-color: #1565c0 !important; color: #ffffff !important; }',
        'hr { border-color: #0f3460 !important; }',
        'a { color: #7ec8e3 !important; }',
        'a:hover { color: #ffffff !important; }',
        '::-webkit-scrollbar { width: 8px; background-color: #1a1a2e !important; }',
        '::-webkit-scrollbar-thumb { background-color: #0f3460 !important; border-radius: 4px; }',
        '::-webkit-scrollbar-thumb:hover { background-color: #1565c0 !important; }',
        '[class*="dropdown"] { background-color: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }',
        '[class*="dialog"] { background-color: #1a1a2e !important; color: #e0e0e0 !important; }'
    ].join('\n');

    // ── TARGET: parent BC page (control add-ins run in an iframe) ──
    var parentDoc  = (window.parent && window.parent.document) ? window.parent.document : document;

    // ── HELPERS ────────────────────────────────────────────────

    function isDarkMode() {
        return localStorage.getItem(STORAGE_KEY) === 'dark';
    }

    function applyDarkMode() {
        var el = parentDoc.getElementById(STYLE_TAG_ID);
        if (!el) {
            el = parentDoc.createElement('style');
            el.id   = STYLE_TAG_ID;
            el.type = 'text/css';
            parentDoc.head.appendChild(el);
        }
        el.textContent = darkCSS;
        localStorage.setItem(STORAGE_KEY, 'dark');
    }

    function removeDarkMode() {
        var el = parentDoc.getElementById(STYLE_TAG_ID);
        if (el && el.parentNode) { el.parentNode.removeChild(el); }
        localStorage.setItem(STORAGE_KEY, 'light');
    }

    // ── FLOATING TOGGLE BUTTON ─────────────────────────────────
    function updateButtonLabel(btn) {
        btn.textContent = isDarkMode() ? '☀️ Light Mode' : '🌙 Dark Mode';
    }

    function createFloatingButton() {
        if (parentDoc.getElementById(BTN_ID)) { return; }

        var btn = parentDoc.createElement('button');
        btn.id = BTN_ID;
        updateButtonLabel(btn);

        btn.style.cssText = [
            'position: fixed',
            'bottom: 24px',
            'right: 24px',
            'z-index: 999999',
            'background: #0f3460',
            'color: #ffffff',
            'border: none',
            'border-radius: 30px',
            'padding: 10px 20px',
            'font-size: 13px',
            'font-family: Segoe UI, Arial, sans-serif',
            'font-weight: 600',
            'cursor: pointer',
            'box-shadow: 0 4px 16px rgba(0,0,0,0.5)',
            'transition: background 0.2s ease'
        ].join('; ');

        btn.onmouseover = function () { btn.style.background = '#1565c0'; };
        btn.onmouseout  = function () { btn.style.background = '#0f3460'; };

        btn.onclick = function () {
            if (isDarkMode()) {
                removeDarkMode();
            } else {
                applyDarkMode();
            }
            updateButtonLabel(btn);
        };

        // Append into the real BC page body (not the iframe)
        var target = parentDoc.body || parentDoc.documentElement;
        target.appendChild(btn);
    }

    // ── PUBLIC API (called from AL) ────────────────────────────

    window.ToggleDarkMode = function () {
        var btn = parentDoc.getElementById(BTN_ID);
        if (isDarkMode()) {
            removeDarkMode();
        } else {
            applyDarkMode();
        }
        if (btn) { updateButtonLabel(btn); }
    };

    window.InitDarkMode = function () {
        if (isDarkMode()) { applyDarkMode(); }
        createFloatingButton();
    };

    // ── SIGNAL AL: JS IS READY ─────────────────────────────────
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', null);

}());
