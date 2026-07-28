// ============================================================
//  SalesChartAddin.al
//  Control Add-in declaration for the Chart.js Sales Dashboard
//  BizCentralOrbit — Live Charts in Business Central
// ============================================================

controladdin SalesChartAddin
{
    RequestedHeight = 580;
    MinimumHeight = 480;
    MaximumHeight = 700;
    RequestedWidth = 700;
    MinimumWidth = 400;
    MaximumWidth = 1800;
    VerticalStretch = false;   // fixed height — VerticalStretch collapses on Card pages
    HorizontalStretch = true;

    // StartupScript guarantees Microsoft.Dynamics.NAV is injected before the
    // script runs — unlike Scripts which loads asynchronously.
    StartupScript = 'ControlAddins/js/saleschart.js';

    // AL calls this to push JSON data into the JS dashboard
    procedure LoadData(jsonData: Text);

    // JS fires this once it has finished initialising — AL then calls LoadData()
    event ControlAddInReady();
}
