package tracker.report;

import utils.Utils;
import tracker.Occurrence;
import tracker.Main;

class LogReport implements Report
{
    private var buf :StringBuf;
    private var cmd :Command;
    private var dateToBin :Date->String;
    private var lastBin :String;
    private var lastVal :Int;

    public function new(cmd)
    {
        buf = new StringBuf();

        switch( cmd )
        {
        case YLOG: dateToBin = RecordReport.dateToYearBin;
        case MLOG: dateToBin = RecordReport.dateToMonthBin;
        case WLOG: dateToBin = RecordReport.dateToWeekBin;
        case DLOG: dateToBin = RecordReport.dateToDayBin;
        default: throw "non-log cmd in log constructor";
        }
    }

    public function include(thisDay :Date, val :Int)
    {
        if( val == Main.NO_DATA )
            return;

        var binStr = dateToBin(thisDay);
        if( lastBin == null )
        {
            lastBin = binStr;
            lastVal = val;
        }
        else
        {
            if( binStr == lastBin )
                lastVal += val;
            else
            {
                if( lastBin != null )
                    buf.add("  " + lastBin + ": " + lastVal + "\n");
                lastBin = binStr;
                lastVal = val;
            }
        }
    }

    public function toString()
    {
        if( lastBin != null )
            buf.add("  " + lastBin + ": " + lastVal + "\n");

        return if( buf.toString().length>0 )
            buf.toString();
        else
            "no occurrences\n";
    }

    inline public function getLabel()
    {
        return "";
    }
}
