pageextension 50400 "Posted Sales Invoice Razorpay" extends "Posted Sales Invoice"
{
    actions
    {
        addlast(processing)
        {
            action(SendRazorpayPaymentLink)
            {
                ApplicationArea = All;
                Caption = 'Send Payment Link via WhatsApp';
                ToolTip = 'Generates a Razorpay payment link for this invoice and sends it to the customer on WhatsApp.';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RazorpayMgt: Codeunit "Razorpay Mgt.";
                begin
                    RazorpayMgt.SendPaymentLink(Rec);
                end;
            }
        }
        addlast(navigation)
        {
            action(RazorpaySetupShortcut)
            {
                ApplicationArea = All;
                Caption = 'Razorpay Setup';
                ToolTip = 'Configure Razorpay and WhatsApp API credentials.';
                Image = Setup;
                RunObject = Page "Razorpay Setup";
            }
        }
    }
}
