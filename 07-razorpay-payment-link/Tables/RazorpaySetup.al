table 50400 "Razorpay Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Razorpay Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        // ── Razorpay credentials ──────────────────────────────────────────
        field(2; "Key ID"; Text[100])
        {
            Caption = 'Key ID';
            ToolTip = 'Razorpay API Key ID — starts with rzp_test_ (test) or rzp_live_ (production).';
        }
        field(3; "Key Secret"; Text[200])
        {
            Caption = 'Key Secret';
            ExtendedDatatype = Masked;
            ToolTip = 'Razorpay API Key Secret. Keep this confidential.';
        }
        field(4; "Currency"; Code[3])
        {
            Caption = 'Currency';
            InitValue = 'INR';
            ToolTip = 'Currency for payment links, e.g. INR. Razorpay uses smallest unit (paise for INR).';
        }
        field(5; "Business Name"; Text[100])
        {
            Caption = 'Business Name';
            ToolTip = 'Your business name shown in the payment link description and WhatsApp message.';
        }
        // ── WhatsApp (Meta Cloud API) credentials ─────────────────────────
        field(6; "WA Phone Number ID"; Text[50])
        {
            Caption = 'WhatsApp Phone Number ID';
            ToolTip = 'Meta WhatsApp Phone Number ID from your Meta App API Setup page.';
        }
        field(7; "WA Access Token"; Text[500])
        {
            Caption = 'WhatsApp Access Token';
            ExtendedDatatype = Masked;
            ToolTip = 'Temporary or permanent WhatsApp access token from your Meta App.';
        }
        field(8; "WA API Version"; Text[10])
        {
            Caption = 'WhatsApp API Version';
            InitValue = 'v25.0';
            ToolTip = 'Meta Graph API version, e.g. v25.0';
        }
        field(9; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            ToolTip = 'Enable or disable payment link sending.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Record "Razorpay Setup"
    var
        Setup: Record "Razorpay Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."Currency" := 'INR';
            Setup."WA API Version" := 'v25.0';
            Setup.Insert(true);
        end;
        exit(Setup);
    end;
}
