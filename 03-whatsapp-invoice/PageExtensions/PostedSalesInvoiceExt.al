pageextension 50300 "Posted Sales Invoice WA Ext" extends "Posted Sales Invoice"
{
    actions
    {
        addlast(processing)
        {
            action(SendWhatsApp)
            {
                ApplicationArea = All;
                Caption = 'Send via WhatsApp';
                ToolTip = 'Send this invoice to the customer via WhatsApp using the Meta Cloud API.';
                Image = InteractionLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WAMessageMgt: Codeunit "WA Message Mgt.";
                begin
                    WAMessageMgt.SendInvoice(Rec);
                end;
            }
        }
        addlast(navigation)
        {
            action(WhatsAppSetup)
            {
                ApplicationArea = All;
                Caption = 'WhatsApp Setup';
                ToolTip = 'Configure the WhatsApp API credentials.';
                Image = Setup;
                RunObject = Page "WA Setup";
            }
        }
    }
}
