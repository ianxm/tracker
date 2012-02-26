package tracker.report;

import tracker.Main;
import utils.Utils;

class DurationReport implements Report
{
    private var firstDate :Date;
    private var lastDate :Date;

    public function new()
    {
        firstDate = null;
        lastDate = null;
    }

    public function include(thisDay :Date, val :Float)
    {
        if( firstDate == null )
            firstDate = thisDay;
        else if( val == Main.NO_DATA )
            lastDate = thisDay;
    }

    public function toString()
    {
        if( firstDate==null || lastDate==null ) 
            return "empty range\n";

        var duration = Utils.dayDelta(firstDate, lastDate)+1;
        if( duration == 1 )
            return (Utils.dayDelta(firstDate, lastDate)+1) + " day: " +
                Utils.dayToStr(firstDate) + "\n";
        else
            return (Utils.dayDelta(firstDate, lastDate)+1) + " days" +
                " from " + Utils.dayToStr(firstDate) +
                " to " + Utils.dayToStr(lastDate) + "\n";
    }


    inline public function getLabel()
    {
        return "duration: ";
    }
}
