package tracker.report;

using StringTools;
import utils.Utils;
import tracker.Occurrence;

class StreakReport implements Report
{
    private var val :Int;
    private var startDate :Date;
    private var reportPrefix :String;

    public function new(prefix)
    {
        val = 0;
        startDate = null;
        reportPrefix = prefix;
    }

    public function include(thisDay :Date, val :Int)
    {
        throw "StreakReport must be subclassed";
    }

    public function toString()
    {
        return if( startDate == null )
            reportPrefix + "none";
        else if( val == 1 )
            reportPrefix + "  1 day  starting on " + Utils.dayToStr(startDate);
        else
            reportPrefix + Std.string(val).lpad(' ',3) + " days starting on " + Utils.dayToStr(startDate);
    }

    private function checkBest(checkDate, checkVal)
    {
        if( isBest(checkVal, val) )
        {
            startDate = checkDate;
            val = checkVal;
        }
    }

    private function isBest(val1, val2)
    {
        return val1 >= val2;
    }
}
