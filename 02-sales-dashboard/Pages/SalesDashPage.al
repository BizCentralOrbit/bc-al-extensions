// ================================================================
//  SalesDashPage.al  (Object ID 50201)
//  DIAGNOSTIC VERSION — shows status at each step
// ================================================================

page 50201 "Sales Dashboard"
{
    PageType = Card;
    Caption = 'Sales Dashboard';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            // Visible status field — tells us what AL side is doing
            field(StatusFld; StatusText)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Style = Favorable;
                StyleExpr = true;
                Editable = false;
            }

            group(ChartArea)
            {
                ShowCaption = false;

                usercontrol(ChartCtrl; SalesChartAddin)
                {
                    ApplicationArea = All;

                    trigger ControlAddInReady()
                    begin
                        StatusText := '✅ ControlAddInReady fired at ' + Format(CurrentDateTime, 0, '<Hours24>:<Minutes,2>:<Seconds,2>');
                        CurrPage.Update(false);
                        RefreshChart();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh Charts';
                ToolTip = 'Reload all charts with the latest sales data from Business Central.';
                Image = Refresh;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    StatusText := 'Refresh clicked at ' + Format(CurrentDateTime, 0, '<Hours24>:<Minutes,2>:<Seconds,2>');
                    CurrPage.Update(false);
                    RefreshChart();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh) { }
        }
    }

    trigger OnOpenPage()
    begin
        StatusText := '⏳ Page opened — waiting for ControlAddInReady from JS…';
    end;

    local procedure RefreshChart()
    var
        SalesMgmt: Codeunit "SalesDataMgmt";
        JsonData: Text;
    begin
        JsonData := SalesMgmt.GetSalesJSON();
        StatusText := '📤 Calling LoadData — JSON length: ' + Format(StrLen(JsonData)) + ' chars';
        CurrPage.Update(false);
        CurrPage.ChartCtrl.LoadData(JsonData);
        StatusText := '✅ LoadData sent to JS';
        CurrPage.Update(false);
    end;

    var
        StatusText: Text;
}
