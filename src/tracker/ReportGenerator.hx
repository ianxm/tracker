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

                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_HIGHEST));

                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_LOWEST));

                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_CURRENT));
                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_CURRENT));
                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_CURRENT));
                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_CURRENT));

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
        case CAL:
            {
                reports.add(new tracker.report.CalReport());
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
