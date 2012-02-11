package mymetrics;

using Lambda;
import neko.Lib;
import utils.Utils;
import mymetrics.Main;
import mymetrics.report.Report;

class ReportGenerator
{
    private var range :Array<String>;
    private var reports :List<Report>;

    public function new(r)
    {
        range = r;
        reports = new List<Report>();
    }

    public function setReport(mode)
    {
        switch(mode)
        {
        case VIEW, STREAKS:
            {
                reports.add(new mymetrics.report.DurationReport());
                reports.add(new mymetrics.report.StreakOnReport());
                reports.add(new mymetrics.report.StreakOffReport());
                reports.add(new mymetrics.report.StreakCurrentReport());
            }
        case LOG:
            {
                reports.add(new mymetrics.report.DurationReport());
                reports.add(new mymetrics.report.LogReport());
            }
        default:
            throw "unknown report mode";
        }
    }

    public function include( date, val )
    {
        for( report in reports )
            report.include(date, val);
    }

    public function print()
    {
        for( report in reports )
            Lib.println(report.toString());
    }
}
