page 50300 "WA Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WA Setup";
    Caption = 'WhatsApp Setup';

    layout
    {
        area(Content)
        {
            group(APIConfiguration)
            {
                Caption = 'Meta WhatsApp Cloud API';

                field("Phone Number ID"; Rec."Phone Number ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Found in Meta Business Suite → WhatsApp → API Setup → Phone Number ID.';
                }
                field("Access Token"; Rec."Access Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Temporary or permanent access token from your Meta App.';
                }
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Meta Graph API version, e.g. v25.0';
                }
                field("Business Name"; Rec."Business Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your business name shown in WhatsApp messages.';
                }
                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable WhatsApp invoice sending.';
                }
            }
            group(Help)
            {
                Caption = 'How to Get API Credentials';
                InstructionalText = 'Step 1: Go to developers.facebook.com and create an App. Step 2: Add the WhatsApp product. Step 3: Copy the Phone Number ID and Temporary Access Token. Step 4: Paste them above and click Save.';
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
                ToolTip = 'Sends a test message to verify your API credentials.';
                Image = ValidateEmailLoggingSetup;

                trigger OnAction()
                var
                    WAMessageMgt: Codeunit "WA Message Mgt.";
                begin
                    WAMessageMgt.TestConnection(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec."API Version" := 'v25.0';
            Rec.Insert(true);
        end;
    end;
}
