package tracker;

using Lambda;
using StringTools;
import neko.Lib;
import utils.Utils;
import tracker.Main;
import tracker.report.Report;

class ReportGenerator
{
    private var range :Array<String>;
    private var reports :List<Report>;
    private var indent : Bool;

    public function new(r)
    {
        range = r;
        reports = new List<Report>();
        indent = false;
    }

    public function setReport(cmd)
    {
        switch(cmd)
        {
        case RECORDS:
            {
                indent = true;
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.Spacer());

                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_YEAR,  KEEP_CURRENT));
                reports.add(new tracker.report.Spacer());

                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_MONTH, KEEP_CURRENT));
                reports.add(new tracker.report.Spacer());

                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_WEEK,  KEEP_CURRENT));
                reports.add(new tracker.report.Spacer());

                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_HIGHEST));
                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_LOWEST));
                reports.add(new tracker.report.RecordReport(BIN_DAY,   KEEP_CURRENT));
                reports.add(new tracker.report.Spacer());

                reports.add(new tracker.report.StreakReport(KEEP_HIGHEST));
                reports.add(new tracker.report.StreakReport(KEEP_LOWEST));
                reports.add(new tracker.report.StreakReport(KEEP_CURRENT));
            }
        case DLOG,WLOG,MLOG,YLOG:
            {
                reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.LogReport(cmd));
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
                reports.add(new tracker.report.DurationReport());
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
        var labelWidth = if( indent )
            reports.fold(function(rr,width) return Math.max(rr.getLabel().length,width), 0);
        else
            0;

        for( report in reports )
            Lib.println(report.getLabel().lpad(' ', Std.int(labelWidth)) + report.toString());
    }
}
