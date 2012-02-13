package tracker.report;

import utils.Utils;

class StreakCurrentReport extends StreakReport
{
    private var startOfStreak :Date;
    private var lastDay :Date;
    private var count :Int;

    public function new()
    {
        super("current streak: ");
        startOfStreak = null;
        lastDay = null;
        count = 0;
    }

    // val may be zero for first and last call
    override public function include(occDay :Date, occVal :Int)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Utils.dayDelta(lastDay, occDay);

        if( delta == 1 && occVal > 0 )      // extend current on streak
            count++;
        else
        {
            if( occVal > 0 )                // start new on streak
            {
                startOfStreak = occDay;
                count = 1;
                reportPrefix = "current streak: on  ";
            }
            else if( delta != 0 )           // end on an off streak
            {
                startOfStreak = Utils.dayShift(lastDay, 1);
                count = delta;
                reportPrefix = "current streak: off ";
            }
        }
        checkBest(startOfStreak, count);    // check for new best
        lastDay = occDay;
    }

    override function isBest(val1, val2)
    {
        return true;
    }
}
