package tracker.report;

import utils.Utils;
import tracker.Occurrence;

class LogReport implements Report
{
    private var buf :StringBuf;

    public function new()
    {
        buf = new StringBuf();
    }

    public function include(thisDay :Date, val :Int)
    {
        if( val > 0 )
            buf.add("  " + Utils.dayStr(thisDay) + ": " + val + "\n");
    }

    public function toString()
    {
        return if( buf.toString().length>0 )
            buf.toString();
        else
            "no occurrences";
    }

    public function getLabel()
    {
        return "";
    }
}
