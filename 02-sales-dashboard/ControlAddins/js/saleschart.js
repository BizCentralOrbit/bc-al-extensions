// ================================================================
//  saleschart.js — PRODUCTION v2
//  BizCentralOrbit — Live Charts in Business Central (Topic 2)
//
//  Changes from v1:
//  - Use StartupScript (not Scripts) — Microsoft.Dynamics.NAV is
//    guaranteed available on first run.
//  - Force iframe height using style.setProperty + 'important' so
//    BC's layout engine cannot override it.
//  - MutationObserver watches for BC resetting height and reapplies.
//  - Periodic re-apply for first 5 s as an extra safety net.
// ================================================================

(function () {
    'use strict';

    // ── Palette ────────────────────────────────────────────────
    var TEAL    = '#14b8a6';
    var GOLD    = '#eab308';
    var ORANGE  = '#fb923c';
    var BG      = '#0a1a1a';
    var CARD_BG = '#0f2d2d';
    var GRID    = '#1a3535';
    var WHITE   = '#ffffff';
    var GRAY    = '#cccccc';
    var DIM     = '#88998f';

    var TARGET_H = 560;     // desired iframe height in pixels

    // ── Iframe height guard ────────────────────────────────────
    // Finds the iframe element in the BC parent page and forces
    // height with !important on it and up to 8 ancestors.
    // A MutationObserver + interval ensure BC cannot reset it.
    var _iframeEl = null;

    function findMyIframe() {
        try {
            var frames = window.parent.document.querySelectorAll('iframe');
            for (var i = 0; i < frames.length; i++) {
                if (frames[i].contentWindow === window) {
                    return frames[i];
                }
            }
        } catch (e) {}
        return null;
    }

    function applyHeight() {
        if (!_iframeEl) return;
        try {
            var el = _iframeEl;
            for (var d = 0; d < 8; d++) {
                el.style.setProperty('height',     TARGET_H + 'px', 'important');
                el.style.setProperty('min-height', TARGET_H + 'px', 'important');
                el.style.setProperty('overflow',   'visible',       'important');
                if (el.parentElement &&
                        el.parentElement !== window.parent.document.body) {
                    el = el.parentElement;
                } else {
                    break;
                }
            }
        } catch (e) {}
    }

    function setupHeightGuard() {
        _iframeEl = findMyIframe();
        if (!_iframeEl) return;

        applyHeight();

        // Watch BC style mutations and reapply immediately
        try {
            var observer = new MutationObserver(applyHeight);
            var el = _iframeEl;
            for (var d = 0; d < 8; d++) {
                observer.observe(el, { attributes: true, attributeFilter: ['style'] });
                if (el.parentElement &&
                        el.parentElement !== window.parent.document.body) {
                    el = el.parentElement;
                } else {
                    break;
                }
            }
        } catch (e) {}

        // Belt-and-braces: re-apply every 250 ms for the first 6 s
        var ticker = setInterval(applyHeight, 250);
        setTimeout(function () { clearInterval(ticker); }, 6000);
    }

    // ── Page skeleton ──────────────────────────────────────────
    function buildSkeleton() {
        setupHeightGuard();

        document.body.style.cssText =
            'margin:0;padding:10px;background:' + BG +
            ';font-family:Segoe UI,sans-serif;font-size:13px;color:' + WHITE +
            ';box-sizing:border-box;';
        document.body.innerHTML = '';

        var kpiRow   = makeEl('div', 'display:flex;gap:10px;margin-bottom:10px;');
        var chartRow = makeEl('div', 'display:flex;gap:10px;');
        document.body.appendChild(kpiRow);
        document.body.appendChild(chartRow);

        var lineWrap = makeEl('div',
            'flex:1.6;background:' + CARD_BG + ';border-radius:10px;padding:12px;min-width:0;');
        lineWrap.appendChild(sectionLabel('Monthly Sales (₹K)'));
        var lineCanvas = makeEl('canvas');
        lineWrap.appendChild(lineCanvas);
        chartRow.appendChild(lineWrap);

        var barWrap = makeEl('div',
            'flex:1;background:' + CARD_BG + ';border-radius:10px;padding:12px;min-width:0;');
        barWrap.appendChild(sectionLabel('Top Customers (₹K)'));
        var barCanvas = makeEl('canvas');
        barWrap.appendChild(barCanvas);
        chartRow.appendChild(barWrap);

        window._BCO = { kpiRow: kpiRow, lineWrap: lineWrap, barWrap: barWrap };
    }

    // ── KPI card ───────────────────────────────────────────────
    function addKPI(container, label, value, accent) {
        var card = makeEl('div',
            'flex:1;background:' + CARD_BG + ';border-radius:10px;padding:12px 14px;' +
            'border-left:3px solid ' + accent + ';');
        var lbl = makeEl('div',
            'color:' + DIM + ';font-size:10px;font-weight:600;letter-spacing:.5px;' +
            'text-transform:uppercase;margin-bottom:5px;');
        lbl.textContent = label;
        var val = makeEl('div',
            'color:' + WHITE + ';font-size:22px;font-weight:700;line-height:1.1;');
        val.textContent = value;
        card.appendChild(lbl);
        card.appendChild(val);
        container.appendChild(card);
    }

    // ── Line chart ─────────────────────────────────────────────
    function drawLine(wrap, labels, data) {
        var canvas = wrap.querySelector('canvas');
        var W = wrap.clientWidth - 24;
        if (W < 50) W = 320;
        var H = 210;
        canvas.width  = W;
        canvas.height = H;
        canvas.style.display = 'block';

        var ctx = canvas.getContext('2d');
        var P   = { t: 14, r: 12, b: 30, l: 38 };
        var cw  = W - P.l - P.r;
        var ch  = H - P.t - P.b;

        var maxVal = Math.max.apply(null, data);
        maxVal = maxVal > 0 ? maxVal * 1.15 : 100;

        // Grid + Y labels
        ctx.strokeStyle = GRID;
        ctx.lineWidth   = 1;
        for (var g = 0; g <= 4; g++) {
            var gy = P.t + ch - (g / 4) * ch;
            ctx.beginPath();
            ctx.moveTo(P.l, gy);
            ctx.lineTo(P.l + cw, gy);
            ctx.stroke();
            ctx.fillStyle = DIM;
            ctx.font      = '9px Segoe UI';
            ctx.textAlign = 'right';
            ctx.fillText(Math.round((g / 4) * maxVal), P.l - 4, gy + 3);
        }

        var pts = data.map(function (v, i) {
            return {
                x: P.l + (data.length > 1 ? (i / (data.length - 1)) * cw : cw / 2),
                y: P.t + ch - ((v > 0 ? v : 0) / maxVal) * ch
            };
        });

        // Gradient fill
        var grad = ctx.createLinearGradient(0, P.t, 0, P.t + ch);
        grad.addColorStop(0, 'rgba(20,184,166,.4)');
        grad.addColorStop(1, 'rgba(20,184,166,0)');
        ctx.beginPath();
        ctx.moveTo(pts[0].x, P.t + ch);
        ctx.lineTo(pts[0].x, pts[0].y);
        for (var i = 1; i < pts.length; i++) {
            var mx = (pts[i - 1].x + pts[i].x) / 2;
            ctx.bezierCurveTo(mx, pts[i - 1].y, mx, pts[i].y, pts[i].x, pts[i].y);
        }
        ctx.lineTo(pts[pts.length - 1].x, P.t + ch);
        ctx.closePath();
        ctx.fillStyle = grad;
        ctx.fill();

        // Line
        ctx.beginPath();
        ctx.moveTo(pts[0].x, pts[0].y);
        for (var j = 1; j < pts.length; j++) {
            var mx2 = (pts[j - 1].x + pts[j].x) / 2;
            ctx.bezierCurveTo(mx2, pts[j - 1].y, mx2, pts[j].y, pts[j].x, pts[j].y);
        }
        ctx.strokeStyle = TEAL;
        ctx.lineWidth   = 2.5;
        ctx.stroke();

        // Dots
        pts.forEach(function (p) {
            ctx.beginPath();
            ctx.arc(p.x, p.y, 3.5, 0, Math.PI * 2);
            ctx.fillStyle = TEAL;
            ctx.fill();
        });

        // X labels (every other)
        ctx.fillStyle = DIM;
        ctx.font      = '9px Segoe UI';
        ctx.textAlign = 'center';
        labels.forEach(function (lbl, i) {
            if (i % 2 === 0) {
                ctx.fillText(lbl.substring(0, 7), pts[i].x, H - 7);
            }
        });
    }

    // ── Horizontal bar chart ───────────────────────────────────
    function drawBars(wrap, labels, data) {
        var canvas = wrap.querySelector('canvas');
        var W      = wrap.clientWidth - 24;
        if (W < 50) W = 200;
        var barH   = 26;
        var gap    = 14;
        var padTop = 6;
        var H      = padTop + labels.length * (barH + gap);
        canvas.width  = W;
        canvas.height = H;
        canvas.style.display = 'block';

        var ctx    = canvas.getContext('2d');
        var maxVal = Math.max.apply(null, data);
        maxVal     = maxVal > 0 ? maxVal * 1.1 : 1;

        labels.forEach(function (name, i) {
            var y    = padTop + i * (barH + gap);
            var barW = (data[i] / maxVal) * W;

            // Track
            ctx.fillStyle = GRID;
            ctx.fillRect(0, y + 16, W, 8);

            // Bar
            if (barW > 2) {
                var grd = ctx.createLinearGradient(0, 0, barW, 0);
                grd.addColorStop(0, '#eab308');
                grd.addColorStop(1, '#f59e0b');
                ctx.fillStyle = grd;
                ctx.fillRect(0, y + 16, barW, 8);
            }

            // Name
            ctx.fillStyle = GRAY;
            ctx.font      = '10px Segoe UI';
            ctx.textAlign = 'left';
            var short = name.length > 24 ? name.substring(0, 24) + '…' : name;
            ctx.fillText(short, 0, y + 12);

            // Value
            ctx.fillStyle = GOLD;
            ctx.textAlign = 'right';
            ctx.fillText('₹' + data[i].toFixed(1) + 'K', W, y + 12);
        });
    }

    // ── LoadData — called by AL ────────────────────────────────
    window.LoadData = function (jsonStr) {
        try {
            var d = JSON.parse(jsonStr);
            applyHeight();

            var g = window._BCO;
            if (!g) return;

            g.kpiRow.innerHTML = '';   // clear before re-adding on refresh

            var avg = d.monthlySales.data.length
                ? (d.kpis.totalSalesK / d.monthlySales.data.length).toFixed(1)
                : '0';

            addKPI(g.kpiRow, 'Total Sales (12M)',  '₹' + d.kpis.totalSalesK + 'K', TEAL);
            addKPI(g.kpiRow, 'Total Orders',        String(d.kpis.orderCount),       GOLD);
            addKPI(g.kpiRow, 'Avg Monthly Sales',   '₹' + avg + 'K',                ORANGE);

            setTimeout(function () {
                applyHeight();
                drawLine(g.lineWrap, d.monthlySales.labels, d.monthlySales.data);
                drawBars(g.barWrap,  d.topCustomers.labels, d.topCustomers.data);
            }, 100);
        } catch (e) {}
    };

    // ── Helpers ────────────────────────────────────────────────
    function makeEl(tag, css) {
        var el = document.createElement(tag);
        if (css) el.style.cssText = css;
        return el;
    }
    function sectionLabel(text) {
        var el = makeEl('div',
            'color:' + GRAY + ';font-size:10px;font-weight:600;letter-spacing:.5px;' +
            'text-transform:uppercase;margin-bottom:8px;');
        el.textContent = text;
        return el;
    }

    // ── ControlAddInReady — fires to AL ────────────────────────
    // StartupScript guarantees Microsoft.Dynamics.NAV is available
    // on first call, so retries are just a safety net.
    var _readyAttempts = 0;
    function tryReady() {
        _readyAttempts++;
        var fired = false;
        try {
            if (typeof Microsoft !== 'undefined'
                    && Microsoft.Dynamics && Microsoft.Dynamics.NAV
                    && typeof Microsoft.Dynamics.NAV.InvokeExtensibilityMethod === 'function') {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', null);
                fired = true;
            }
        } catch (e) {
            // Exception — keep retrying (don't return early)
        }
        if (!fired && _readyAttempts < 20) {
            setTimeout(tryReady, _readyAttempts * 250);
        }
    }

    // ── Boot ───────────────────────────────────────────────────
    buildSkeleton();
    tryReady();

}());
