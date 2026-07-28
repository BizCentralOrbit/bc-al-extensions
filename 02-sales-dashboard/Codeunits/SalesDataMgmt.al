// ================================================================
//  SalesDataMgmt.al  (Object ID 50200)
//  Reads live BC sales data and serializes it to JSON for Chart.js
//  BizCentralOrbit — Live Charts in Business Central (Topic 2)
//
//  JSON structure returned:
//  {
//    "monthlySales": { "labels": [...], "data": [...] },
//    "topCustomers": { "labels": [...], "data": [...] },
//    "kpis":         { "totalSalesK": 0.0, "orderCount": 0, "onTimePct": 0 }
//  }
//  All monetary values are in ₹K (thousands) for readable chart axes.
// ================================================================

codeunit 50200 "SalesDataMgmt"
{
    Access = Internal;

    procedure GetSalesJSON(): Text
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        JsonRoot: JsonObject;
        MonthlySalesObj: JsonObject;
        TopCustObj: JsonObject;
        KPIObj: JsonObject;
        MonthLabels: JsonArray;
        MonthData: JsonArray;
        CustLabels: JsonArray;
        CustData: JsonArray;
        MonthStart: Date;
        MonthEnd: Date;
        i: Integer;
        j: Integer;
        TotalSalesK: Decimal;
        MonthSalesK: Decimal;
        OrderCount: Integer;

        // Top-5 customer tracking (simple in-memory max-heap)
        TopNames: array[5] of Text[100];
        TopValues: array[5] of Decimal;
        MinVal: Decimal;
        MinIdx: Integer;
        SwapDec: Decimal;
        SwapTxt: Text[100];
    begin
        // ── MONTHLY SALES — last 12 months ──────────────────────────
        // Loop from 11 months ago (index 11) → current month (index 0)
        // so the resulting array runs oldest → newest (correct chart order).
        TotalSalesK := 0;
        for i := 11 downto 0 do begin
            // First day of the target month
            MonthStart := DMY2Date(
                1,
                Date2DMY(CalcDate('<-' + Format(i) + 'M>', Today), 2),
                Date2DMY(CalcDate('<-' + Format(i) + 'M>', Today), 3)
            );
            // Last day of the target month
            MonthEnd := CalcDate('<CM>', MonthStart);

            CustLedgEntry.Reset();
            CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
            CustLedgEntry.SetRange("Posting Date", MonthStart, MonthEnd);
            CustLedgEntry.CalcSums("Sales (LCY)");
            MonthSalesK := Round(CustLedgEntry."Sales (LCY)" / 1000, 0.1);

            // Label e.g. "Jan 2025"  (AL only supports <Year4>, not <Year2> or <Month Text,3>)
            MonthLabels.Add(CopyStr(Format(MonthStart, 0, '<Month Text>'), 1, 3) + ' ' + Format(MonthStart, 0, '<Year4>'));
            MonthData.Add(MonthSalesK);
            TotalSalesK += MonthSalesK;
        end;
        MonthlySalesObj.Add('labels', MonthLabels);
        MonthlySalesObj.Add('data', MonthData);

        // ── TOP 5 CUSTOMERS — by Sales (LCY) ────────────────────────
        // Strategy: single pass over Customer table, maintain a running
        // top-5 array (O(n) with constant-5 overhead).
        // TopValues[1..5] initialised to 0 by AL.
        Customer.Reset();
        Customer.SetLoadFields("No.", Name);
        if Customer.FindSet() then
            repeat
                Customer.CalcFields("Sales (LCY)");
                if Customer."Sales (LCY)" > 0 then begin
                    // Find the slot with the smallest value in our top-5
                    MinVal := TopValues[1];
                    MinIdx := 1;
                    for j := 2 to 5 do
                        if TopValues[j] < MinVal then begin
                            MinVal := TopValues[j];
                            MinIdx := j;
                        end;
                    // Replace it if this customer is larger
                    if Customer."Sales (LCY)" > MinVal then begin
                        TopNames[MinIdx] := CopyStr(Customer.Name, 1, 100);
                        TopValues[MinIdx] := Customer."Sales (LCY)";
                    end;
                end;
            until Customer.Next() = 0;

        // Bubble-sort descending so the chart shows largest bar first
        for i := 1 to 4 do
            for j := 1 to 4 do
                if TopValues[j] < TopValues[j + 1] then begin
                    SwapDec := TopValues[j];
                    TopValues[j] := TopValues[j + 1];
                    TopValues[j + 1] := SwapDec;
                    SwapTxt := TopNames[j];
                    TopNames[j] := TopNames[j + 1];
                    TopNames[j + 1] := SwapTxt;
                end;

        for i := 1 to 5 do
            if TopValues[i] > 0 then begin
                CustLabels.Add(TopNames[i]);
                CustData.Add(Round(TopValues[i] / 1000, 0.1));
            end;

        TopCustObj.Add('labels', CustLabels);
        TopCustObj.Add('data', CustData);

        // ── KPIs ─────────────────────────────────────────────────────
        CustLedgEntry.Reset();
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Posting Date", CalcDate('<-12M>', Today), Today);
        OrderCount := CustLedgEntry.Count();

        KPIObj.Add('totalSalesK', Round(TotalSalesK, 0.1));
        KPIObj.Add('orderCount', OrderCount);

        // ── Assemble root JSON ────────────────────────────────────────
        JsonRoot.Add('monthlySales', MonthlySalesObj);
        JsonRoot.Add('topCustomers', TopCustObj);
        JsonRoot.Add('kpis', KPIObj);

        exit(Format(JsonRoot));
    end;
}
