table 50300 "WA Setup"
{
    DataClassification = CustomerContent;
    Caption = 'WhatsApp Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Phone Number ID"; Text[50])
        {
            Caption = 'Phone Number ID';
            ToolTip = 'The Phone Number ID from your Meta WhatsApp Business App dashboard.';
        }
        field(3; "Access Token"; Text[500])
        {
            Caption = 'Access Token';
            ExtendedDatatype = Masked;
            ToolTip = 'The permanent or temporary access token from your Meta App.';
        }
        field(4; "API Version"; Text[10])
        {
            Caption = 'API Version';
            InitValue = 'v25.0';
            ToolTip = 'Meta Graph API version, e.g. v25.0';
        }
        field(5; "Business Name"; Text[100])
        {
            Caption = 'Business Name (Sender)';
            ToolTip = 'Your business name shown at the top of the WhatsApp message.';
        }
        field(6; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            ToolTip = 'Enable or disable WhatsApp sending.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Record "WA Setup"
    var
        WASetup: Record "WA Setup";
    begin
        if not WASetup.Get('') then begin
            WASetup.Init();
            WASetup."Primary Key" := '';
            WASetup."API Version" := 'v25.0';
            WASetup.Insert(true);
        end;
        exit(WASetup);
    end;
}
