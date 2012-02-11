package mymetrics.report;

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

    public function include(thisDay :Date, val :Int)
    {
        if( firstDate == null )
            firstDate = thisDay;
        else if( val == 0 )
            lastDate = thisDay;
    }

    public function toString()
    {
        if( firstDate == null ) 
            return "no occurrences";

        var duration = Utils.dayDelta(firstDate, lastDate)+1;
        if( duration == 1 )
            return "duration: " + (Utils.dayDelta(firstDate, lastDate)+1) + " day: " +
                Utils.dayToStr(firstDate);
        else
            return "duration: " + (Utils.dayDelta(firstDate, lastDate)+1) + " days" +
            " from " + Utils.dayToStr(firstDate) +
            " to " + Utils.dayToStr(lastDate);
    }
}
