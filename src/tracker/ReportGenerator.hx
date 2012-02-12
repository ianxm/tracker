package tracker;

using Lambda;
import neko.Lib;
import utils.Utils;
import tracker.Main;
import tracker.report.Report;

class ReportGenerator
{
    private var range :Array<String>;
    private var reports :List<Report>;

    public function new(r)
    {
        range = r;
        reports = new List<Report>();
    }

    public function setReport(cmd)
    {
        switch(cmd)
        {
        case RECORDS:
            {
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.StreakOnReport());
                reports.add(new tracker.report.StreakOffReport());
                reports.add(new tracker.report.StreakCurrentReport());
            }
        case LOG:
            {
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.LogReport());
            }
        case COUNT:
            {
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.CountReport());
            }
        case STREAKS:
            {
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.StreakLogReport());
            }
        default:
            throw "unknown report command";
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
