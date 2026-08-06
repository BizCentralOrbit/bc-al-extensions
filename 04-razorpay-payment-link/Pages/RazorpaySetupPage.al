page 50400 "Razorpay Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Razorpay Setup";
    Caption = 'Razorpay Setup';

    layout
    {
        area(Content)
        {
            group(RazorpayAPI)
            {
                Caption = 'Razorpay API';

                field("Key ID"; Rec."Key ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'API Key ID from Razorpay Dashboard → Settings → API Keys. Starts with rzp_test_ for test mode.';
                }
                field("Key Secret"; Rec."Key Secret")
                {
                    ApplicationArea = All;
                    ToolTip = 'API Key Secret from Razorpay Dashboard. Shown only once when generated.';
                }
                field("Currency"; Rec."Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'INR for Indian Rupees. Razorpay converts to paise automatically.';
                }
                field("Business Name"; Rec."Business Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shown in the payment link description and WhatsApp message header.';
                }
            }
            group(WhatsAppAPI)
            {
                Caption = 'Meta WhatsApp Cloud API';

                field("WA Phone Number ID"; Rec."WA Phone Number ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Found in Meta for Developers → Your App → WhatsApp → API Setup → Phone Number ID.';
                }
                field("WA Access Token"; Rec."WA Access Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Temporary access token from Meta API Setup. Expires ~24 hrs. Use System User Token for production.';
                }
                field("WA API Version"; Rec."WA API Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Meta Graph API version, e.g. v25.0';
                }
            }
            group(General)
            {
                Caption = 'General';

                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable to allow sending payment links from Posted Sales Invoices.';
                }
            }
            group(HowTo)
            {
                Caption = 'Where to get credentials';
                InstructionalText = 'Razorpay: Dashboard → Settings → API Keys → Generate Test Key. WhatsApp: developers.facebook.com → Your App → WhatsApp → API Setup.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                ToolTip = 'Validates that the Razorpay credentials are entered correctly.';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RazorpayMgt: Codeunit "Razorpay Mgt.";
                begin
                    RazorpayMgt.TestConnection(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec."Currency" := 'INR';
            Rec."WA API Version" := 'v25.0';
            Rec.Insert(true);
        end;
    end;
}
