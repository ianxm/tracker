package tracker.report;

using StringTools;
import tracker.Main;
import utils.Utils;
import tracker.report.RecordReport;

class StreakReport implements Report
{
    private var startOfStreak :Date;
    private var lastDay :Date;
    private var count :Int;

    private var bestStreakLength :Int;
    private var bestStartDate :Date;

    private var filterName :String;
    private var isStreakOn :Bool;
    public var include :Date -> Int -> Void;
    private var isBest :Int -> Int -> Bool;

    public function new(keep :FilterStrategy)
    {
        bestStreakLength = 0;
        bestStartDate = null;

        startOfStreak = null;
        lastDay = null;
        count = 0;

        switch( keep )
        {
        case KEEP_LOWEST:
            {
                filterName = "longest off streak: ";
                isBest = function(a,b) return a>=b;
                include = includeOff;
            }
        case KEEP_HIGHEST:
            {
                filterName = "longest on streak: ";
                isBest = function(a,b) return a>=b;
                include = includeOn;
            }
        case KEEP_CURRENT:
            {
                filterName = "current streak: ";
                isBest = function(a,b) return true;
                include = includeCurrent;
            }
        }
    }

    public function toString()
    {
        var onOrOff = if( isStreakOn == null )
            "";
        else if( isStreakOn == true )
            " (on)";
        else
            " (off)";
        return if( bestStartDate == null )
            "none";
        else if( bestStreakLength == 1 )
            "  1 day  starting on " + Utils.dayToStr(bestStartDate) + onOrOff;
        else
            Std.string(bestStreakLength).lpad(' ',3) + " days starting on " + Utils.dayToStr(bestStartDate) + onOrOff;
    }

    inline public function getLabel()
    {
        return filterName;
    }

    private function checkBest(checkDate, checkLength)
    {
        if( isBest(checkLength, bestStreakLength) )
        {
            bestStartDate = checkDate;
            bestStreakLength = checkLength;
        }
    }

    // val may be zero for first and last call
    public function includeOff(occDay :Date, occVal :Int)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Utils.dayDelta(lastDay, occDay);
        checkBest(Utils.dayShift(lastDay, 1), delta-1);
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeOn(occDay :Date, occVal :Int)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Utils.dayDelta(lastDay, occDay);

        if( delta == 1 )                                    // extend current on streak
            count++;
        else if( occVal != Main.NO_DATA )                   // start new streak
        {
            startOfStreak = occDay;
            count = 1;
        }
        checkBest(startOfStreak, count);                    // check for new best
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeCurrent(occDay :Date, occVal :Int)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Utils.dayDelta(lastDay, occDay);

        if( delta == 1 && occVal != Main.NO_DATA )          // extend current on streak
            count++;
        else
        {
            if( occVal != Main.NO_DATA )                    // start new on streak
            {
                startOfStreak = occDay;
                count = 1;
                isStreakOn = true;
            }
            else if( delta != 0 )                           // end on an off streak
            {
                startOfStreak = Utils.dayShift(lastDay, 1);
                count = delta;
                isStreakOn = false;
            }
        }
        checkBest(startOfStreak, count);                    // check for new best
        lastDay = occDay;
    }
}
