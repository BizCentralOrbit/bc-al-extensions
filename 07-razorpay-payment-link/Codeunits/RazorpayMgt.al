codeunit 50400 "Razorpay Mgt."
{
    // ════════════════════════════════════════════════════════════════════════
    // PUBLIC — called from Posted Sales Invoice page extension
    // ════════════════════════════════════════════════════════════════════════

    procedure SendPaymentLink(SalesInvHeader: Record "Sales Invoice Header")
    var
        Setup: Record "Razorpay Setup";
        Customer: Record Customer;
        PhoneNo: Text;
        InvAmount: Decimal;
        PaymentUrl: Text;
        WhatsAppMsg: Text;
        LF: Char;
    begin
        LF := 10;

        // ── Validate setup ────────────────────────────────────────────────
        Setup := Setup.GetSetup();
        if not Setup."Enabled" then
            Error('Razorpay payment link sending is not enabled.\nPlease configure Razorpay Setup first.');
        if Setup."Key ID" = '' then
            Error('Razorpay Key ID is missing. Please configure Razorpay Setup.');
        if Setup."Key Secret" = '' then
            Error('Razorpay Key Secret is missing. Please configure Razorpay Setup.');
        if Setup."WA Phone Number ID" = '' then
            Error('WhatsApp Phone Number ID is missing. Please configure Razorpay Setup.');
        if Setup."WA Access Token" = '' then
            Error('WhatsApp Access Token is missing. Please configure Razorpay Setup.');

        // ── Get customer phone number ─────────────────────────────────────
        PhoneNo := SalesInvHeader."Sell-to Phone No.";
        if PhoneNo = '' then
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then
                PhoneNo := Customer."Phone No.";

        if PhoneNo = '' then
            Error('No phone number found for customer %1.\nPlease add a phone number on the Customer card.',
                  SalesInvHeader."Sell-to Customer Name");

        PhoneNo := CleanPhoneNo(PhoneNo);
        if StrLen(PhoneNo) < 7 then
            Error('Phone number "%1" looks invalid.\nUse international format without + sign, e.g. 919876543210.',
                  PhoneNo);

        // ── Get invoice amount ────────────────────────────────────────────
        InvAmount := GetInvoiceAmount(SalesInvHeader);
        if InvAmount <= 0 then
            Error('Invoice amount is zero or negative. Cannot create a payment link.');

        // ── Step 1: Create Razorpay payment link ──────────────────────────
        PaymentUrl := CreateRazorpayLink(Setup, SalesInvHeader, PhoneNo, InvAmount);

        // ── Step 2: Build WhatsApp message ────────────────────────────────
        WhatsAppMsg :=
            'Payment Request from ' + Setup."Business Name" + Format(LF) +
            '----------------------------' + Format(LF) +
            'Invoice No : ' + SalesInvHeader."No." + Format(LF) +
            'Customer   : ' + SalesInvHeader."Sell-to Customer Name" + Format(LF) +
            'Amount     : ' + Setup."Currency" + ' ' + Format(InvAmount) + Format(LF) +
            '----------------------------' + Format(LF) +
            'Click to pay securely:' + Format(LF) +
            PaymentUrl + Format(LF) +
            '----------------------------' + Format(LF) +
            'Powered by Razorpay';

        // ── Step 3: Send via WhatsApp ─────────────────────────────────────
        SendWhatsAppMessage(Setup, PhoneNo, WhatsAppMsg);

        // ── Step 4: Show success with the link ────────────────────────────
        Message('Payment link sent successfully via WhatsApp!' + Format(LF) + Format(LF) +
                'Customer : %1' + Format(LF) +
                'Amount   : %2 %3' + Format(LF) +
                'Link     : %4',
                SalesInvHeader."Sell-to Customer Name",
                Setup."Currency",
                Format(InvAmount),
                PaymentUrl);
    end;

    procedure TestConnection(Setup: Record "Razorpay Setup")
    begin
        if Setup."Key ID" = '' then
            Error('Key ID is missing.');
        if Setup."Key Secret" = '' then
            Error('Key Secret is missing.');
        if (StrLen(Setup."Key ID") < 20) then
            Error('Key ID looks too short. It should start with rzp_test_ or rzp_live_.');

        Message('Razorpay credentials look valid.' + Format(10) +
                'Key ID    : %1...' + Format(10) +
                'Currency  : %2' + Format(10) + Format(10) +
                'To fully test, open a Posted Sales Invoice and click Send Payment Link via WhatsApp.',
                CopyStr(Setup."Key ID", 1, 12),
                Setup."Currency");
    end;

    // ════════════════════════════════════════════════════════════════════════
    // PRIVATE — Razorpay API
    // ════════════════════════════════════════════════════════════════════════

    local procedure CreateRazorpayLink(
        Setup: Record "Razorpay Setup";
        SalesInvHeader: Record "Sales Invoice Header";
        PhoneNo: Text;
        InvAmount: Decimal): Text
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ReqHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        JObject: JsonObject;
        JToken: JsonToken;
        ApiUrl: Text;
        AuthStr: Text;
        RequestBody: Text;
        ResponseText: Text;
        AmountInPaise: Text;
        PaymentUrl: Text;
    begin
        ApiUrl := 'https://api.razorpay.com/v1/payment_links';

        // Basic Auth: Base64(key_id:key_secret)
        AuthStr := Base64Convert.ToBase64(Setup."Key ID" + ':' + Setup."Key Secret");

        // Amount in paise (1 INR = 100 paise) — must be integer, no decimals
        AmountInPaise := Format(Round(InvAmount * 100, 1), 0, '<Integer>');

        // Build JSON body
        RequestBody :=
            '{' +
            '"amount": ' + AmountInPaise + ',' +
            '"currency": "' + Setup."Currency" + '",' +
            '"description": "Invoice ' + EscapeJson(SalesInvHeader."No.") + ' - ' + EscapeJson(SalesInvHeader."Sell-to Customer Name") + '",' +
            '"customer": {' +
            '"name": "' + EscapeJson(SalesInvHeader."Sell-to Customer Name") + '",' +
            '"contact": "' + PhoneNo + '"' +
            '},' +
            '"notify": {"sms": false, "email": false},' +
            '"reminder_enable": false,' +
            '"notes": {' +
            '"invoice_no": "' + EscapeJson(SalesInvHeader."No.") + '",' +
            '"source": "BizCentralOrbit BC Extension"' +
            '}' +
            '}';

        // Set content
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        // Set request
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(ApiUrl);
        HttpRequest.GetHeaders(ReqHeaders);
        ReqHeaders.Add('Authorization', 'Basic ' + AuthStr);
        HttpRequest.Content := HttpContent;

        // Send
        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('Could not connect to Razorpay API. Please check your internet connection.');

        HttpResponse.Content.ReadAs(ResponseText);

        if not HttpResponse.IsSuccessStatusCode() then
            Error('Razorpay API error %1:\n%2\n\nCheck your Key ID and Key Secret in Razorpay Setup.',
                  HttpResponse.HttpStatusCode(), ResponseText);

        // Parse response — extract short_url
        if not JObject.ReadFrom(ResponseText) then
            Error('Could not parse Razorpay response: %1', ResponseText);

        if not JObject.Get('short_url', JToken) then
            Error('Razorpay did not return a payment URL. Response: %1', ResponseText);

        PaymentUrl := JToken.AsValue().AsText();

        if PaymentUrl = '' then
            Error('Razorpay returned an empty payment URL. Response: %1', ResponseText);

        exit(PaymentUrl);
    end;

    // ════════════════════════════════════════════════════════════════════════
    // PRIVATE — WhatsApp (Meta Cloud API)
    // ════════════════════════════════════════════════════════════════════════

    local procedure SendWhatsAppMessage(Setup: Record "Razorpay Setup"; ToPhone: Text; MsgText: Text)
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ReqHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        ApiUrl: Text;
        RequestBody: Text;
        ResponseText: Text;
    begin
        ApiUrl := 'https://graph.facebook.com/' + Setup."WA API Version" +
                  '/' + Setup."WA Phone Number ID" + '/messages';

        RequestBody :=
            '{' +
            '"messaging_product": "whatsapp",' +
            '"to": "' + ToPhone + '",' +
            '"type": "text",' +
            '"text": {' +
            '"preview_url": true,' +
            '"body": "' + EscapeJson(MsgText) + '"' +
            '}' +
            '}';

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(ApiUrl);
        HttpRequest.GetHeaders(ReqHeaders);
        ReqHeaders.Add('Authorization', 'Bearer ' + Setup."WA Access Token");
        HttpRequest.Content := HttpContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('Could not connect to WhatsApp API. Please check your internet connection.');

        HttpResponse.Content.ReadAs(ResponseText);

        if not HttpResponse.IsSuccessStatusCode() then
            Error('WhatsApp API error %1: %2', HttpResponse.HttpStatusCode(), ResponseText);
    end;

    // ════════════════════════════════════════════════════════════════════════
    // PRIVATE — Helpers
    // ════════════════════════════════════════════════════════════════════════

    local procedure GetInvoiceAmount(SalesInvHeader: Record "Sales Invoice Header"): Decimal
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.CalcSums("Amount Including VAT");
        exit(SalesInvLine."Amount Including VAT");
    end;

    local procedure CleanPhoneNo(RawPhone: Text): Text
    var
        Cleaned: Text;
        i: Integer;
        C: Char;
    begin
        Cleaned := '';
        for i := 1 to StrLen(RawPhone) do begin
            C := RawPhone[i];
            if (C >= '0') and (C <= '9') then
                Cleaned += Format(C);
        end;
        exit(Cleaned);
    end;

    local procedure EscapeJson(InputText: Text): Text
    var
        Escaped: Text;
        LF: Char;
        CR: Char;
    begin
        LF := 10;
        CR := 13;
        Escaped := InputText;
        Escaped := Escaped.Replace('\', '\\');
        Escaped := Escaped.Replace('"', '\"');
        Escaped := Escaped.Replace(Format(CR) + Format(LF), '\n');
        Escaped := Escaped.Replace(Format(LF), '\n');
        Escaped := Escaped.Replace(Format(CR), '\n');
        exit(Escaped);
    end;
}
