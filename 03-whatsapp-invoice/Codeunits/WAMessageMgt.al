codeunit 50300 "WA Message Mgt."
{
    procedure SendInvoice(SalesInvHeader: Record "Sales Invoice Header")
    var
        WASetup: Record "WA Setup";
        Customer: Record Customer;
        SalesInvLine: Record "Sales Invoice Line";
        PhoneNo: Text;
        MessageText: Text;
        InvAmount: Text;
        LF: Char;
    begin
        LF := 10;

        // Load and validate setup
        WASetup := WASetup.GetSetup();
        if not WASetup."Enabled" then
            Error('WhatsApp sending is not enabled. Please configure it in WhatsApp Setup.');
        if WASetup."Phone Number ID" = '' then
            Error('Phone Number ID is missing. Please configure WhatsApp Setup.');
        if WASetup."Access Token" = '' then
            Error('Access Token is missing. Please configure WhatsApp Setup.');

        // Get customer phone number (try invoice first, then Customer card)
        PhoneNo := SalesInvHeader."Sell-to Phone No.";
        if PhoneNo = '' then
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then
                PhoneNo := Customer."Phone No.";

        if PhoneNo = '' then
            Error('No phone number found for customer %1.' + Format(LF) +
                  'Please add a phone number on the Customer card.', SalesInvHeader."Sell-to Customer Name");

        // Clean phone number — keep digits only
        PhoneNo := CleanPhoneNo(PhoneNo);
        if StrLen(PhoneNo) < 7 then
            Error('Phone number "%1" appears invalid.' + Format(LF) +
                  'Use international format, e.g. 919876543210 (country code + number).', PhoneNo);

        // Calculate amount from lines (header field may be 0 in some environments)
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.CalcSums("Amount Including VAT");
        InvAmount := Format(SalesInvLine."Amount Including VAT");

        // Build message text using actual newlines (LF char 10)
        MessageText :=
            'Invoice from ' + WASetup."Business Name" + Format(LF) +
            '----------------------------' + Format(LF) +
            'Invoice No : ' + SalesInvHeader."No." + Format(LF) +
            'Customer   : ' + SalesInvHeader."Sell-to Customer Name" + Format(LF) +
            'Amount     : ' + InvAmount + Format(LF) +
            'Due Date   : ' + Format(SalesInvHeader."Due Date", 0, '<Day,2> <Month Text> <Year4>') + Format(LF) +
            '----------------------------' + Format(LF) +
            'Thank you for your business!';

        // Send via Meta WhatsApp Cloud API
        SendWhatsAppMessage(WASetup, PhoneNo, MessageText);

        Message('Invoice %1 sent to %2 via WhatsApp.', SalesInvHeader."No.", SalesInvHeader."Sell-to Customer Name");
    end;

    procedure TestConnection(WASetup: Record "WA Setup")
    begin
        if WASetup."Phone Number ID" = '' then
            Error('Phone Number ID is missing.');
        if WASetup."Access Token" = '' then
            Error('Access Token is missing.');

        Message('Setup looks valid.' +
                'Phone Number ID: %1' +
                'API Version: %2' +
                'To fully test, open a Posted Sales Invoice and click Send via WhatsApp.',
                WASetup."Phone Number ID", WASetup."API Version");
    end;

    local procedure SendWhatsAppMessage(WASetup: Record "WA Setup"; ToPhone: Text; MsgText: Text)
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
        ApiUrl := 'https://graph.facebook.com/' + WASetup."API Version" +
                  '/' + WASetup."Phone Number ID" + '/messages';

        // Build JSON body — escape the message text first
        RequestBody :=
            '{' +
            '"messaging_product": "whatsapp",' +
            '"to": "' + ToPhone + '",' +
            '"type": "text",' +
            '"text": {' +
            '"preview_url": false,' +
            '"body": "' + EscapeJson(MsgText) + '"' +
            '}' +
            '}';

        // Set content headers
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        // Set request headers
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(ApiUrl);
        HttpRequest.GetHeaders(ReqHeaders);
        ReqHeaders.Add('Authorization', 'Bearer ' + WASetup."Access Token");
        HttpRequest.Content := HttpContent;

        // Send HTTP request
        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('Could not connect to WhatsApp API. Please check your internet connection.');

        HttpResponse.Content.ReadAs(ResponseText);

        if not HttpResponse.IsSuccessStatusCode() then
            Error('WhatsApp API error %1: %2', HttpResponse.HttpStatusCode(), ResponseText);
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
        // Escape backslash and double quotes for JSON
        Escaped := Escaped.Replace('\', '\\');
        Escaped := Escaped.Replace('"', '\"');
        // Convert actual newlines to JSON \n sequence
        Escaped := Escaped.Replace(Format(CR) + Format(LF), '\n');
        Escaped := Escaped.Replace(Format(LF), '\n');
        Escaped := Escaped.Replace(Format(CR), '\n');
        exit(Escaped);
    end;
}
