// ============================================================
// Control Add-in: BCO Dark Mode Addin
// Publisher    : BizCentralOrbit
// Description  : Injects dark mode CSS into Business Central
//                web client via JavaScript.
// ============================================================

controladdin "BCO Dark Mode Addin"
{
    RequestedHeight   = 0;
    MinimumHeight     = 0;
    MaximumHeight     = 0;
    RequestedWidth    = 0;
    MinimumWidth      = 0;
    MaximumWidth      = 0;
    HorizontalStretch = true;
    VerticalStretch   = false;

    Scripts = 'ControlAddins/DarkModeAddin/js/darkmode.js';

    // Fired when the JS file is loaded and ready
    event ControlAddInReady();

    // Toggle between dark and light mode
    procedure ToggleDarkMode();

    // Restore saved dark/light preference on page load
    procedure InitDarkMode();
}
