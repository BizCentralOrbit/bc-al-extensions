// ============================================================
// Page Extension : BCO Dark Mode Role Center
// Publisher      : BizCentralOrbit
// Extends        : Business Manager Role Center
// Description    : Embeds the hidden Dark Mode CardPart.
//                  The toggle button is injected by darkmode.js
//                  as a floating button — no AL triggers needed.
// ============================================================

pageextension 50100 "BCO Dark Mode Role Center" extends "Business Manager Role Center"
{
    layout
    {
        addlast(RoleCenter)
        {
            // Hidden part (Visible=false) — just loads the JS
            part(DarkModePart; "BCO Dark Mode Part")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
