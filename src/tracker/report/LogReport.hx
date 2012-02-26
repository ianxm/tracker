package tracker.report;

import utils.Utils;
import tracker.Main;

class LogReport implements Report
{
    private var buf         :StringBuf;                     // output buffer
    private var cmd         :Command;                       // which log command
    private var dateToBin   :Date->String;                  // convert date to bin key
    private var valToBin    :Float -> Date -> Float;        // convert value to pack in bin
    private var getDuration :Date -> Int;                   // get num days for averaging
    private var printVal    :Float -> Float;                // set precision of output
    private var lastBin     :String;                        // key of last bin
    private var lastVal     :Float;                         // value in last bin
    private var firstDay    :Date;                          // needed for full grouping
    private var lastDay     :Date;                          // needed for full grouping

    public function new(gt, vt)
    {
        buf = new StringBuf();

        switch( gt )
        {
        case DAY:
            {
                dateToBin = RecordReport.dateToDayBin;
                getDuration = function(date) { return 1; }
            }
        case WEEK:
            {
                dateToBin = RecordReport.dateToWeekBin;
                getDuration = function(date) { return 7; }
            }
        case MONTH:
            {
                dateToBin = RecordReport.dateToMonthBin;
                getDuration = DateTools.getMonthDays;
            }
        case YEAR: 
            {
                dateToBin = RecordReport.dateToYearBin;
                getDuration = function(date) { return 365; } // do I care about leap day?  I do not.
            }
        case FULL: 
            {
                dateToBin = function(date) { return "all-time"; }
                getDuration = function(date) { return 1; }  // must track full duration
            }
        }

        switch( vt )
        {
        case TOTAL:
            {
                valToBin = function(val,date) { return val; }
                printVal = Math.round;
            }
        case COUNT:
            {
                valToBin = function(val,date) { return 1; }
                printVal = Math.round;
            }
        case AVG:
            {
                valToBin = function(val,date) { return val/getDuration(date); }
                printVal = function(val) {                  // for full duration we have to put off evaluating the
                    if( gt==FULL )                          // duration until all data has been processed
                        val = val/Utils.dayDelta(firstDay,lastDay)+1;
                    return Math.round(val*10)/10;
                }
            }
        case PERCENT:
            {
                valToBin = function(val,date) { return 1/getDuration(date)*100; }
                printVal = function(val) {                  // ditto whats said for AVG
                    if( gt==FULL )
                        val = val/Utils.dayDelta(firstDay,lastDay)+1;
                    return Math.round(val);
                }
            }
        }
    }

    public function include(thisDay :Date, val :Float)
    {
        if( val == Main.NO_DATA )
            return;

        if( firstDay == null )
            firstDay = thisDay;
        lastDay = thisDay;

        var binStr = dateToBin(thisDay);
        val = valToBin(val, thisDay);
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
                    buf.add("  " + lastBin + ": " + printVal(lastVal) + "\n");
                lastBin = binStr;
                lastVal = val;
            }
        }
    }

    public function toString()
    {
        if( lastBin != null )
            buf.add("  " + lastBin + ": " + printVal(lastVal) + "\n");

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
