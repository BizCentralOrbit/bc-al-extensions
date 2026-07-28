// ============================================================
// Page           : BCO Dark Mode Part
// Type           : CardPart (hidden, height = 0)
// Publisher      : BizCentralOrbit
// Description    : Hosts the Dark Mode usercontrol.
//                  Triggers are allowed here (not on RoleCenter).
//                  Called from RoleCenterExt via CurrPage.DarkModePart.Page
// ============================================================

page 50101 "BCO Dark Mode Part"
{
    PageType          = CardPart;
    Caption           = '';
    ApplicationArea   = All;

    layout
    {
        area(content)
        {
            usercontrol(DarkCtrl; "BCO Dark Mode Addin")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    // Restore saved dark/light preference when page loads
                    CurrPage.DarkCtrl.InitDarkMode();
                end;
            }
        }
    }

    // Called from the Role Center action
    procedure ToggleDarkMode()
    begin
        CurrPage.DarkCtrl.ToggleDarkMode();
    end;
}
