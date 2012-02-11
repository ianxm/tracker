package mymetrics.report;

import utils.Utils;

class StreakOnReport extends StreakReport
{
    private var startOfStreak :Date;
    private var lastDay :Date;
    private var count :Int;

    public function new()
    {
        super("longest on streak: ");
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

        if( delta == 1 )                    // extend current on streak
            count++;
        else if( occVal > 0 )               // start new streak
        {
            startOfStreak = occDay;
            count = 1;
        }
        checkBest(startOfStreak, count);    // check for new best
        lastDay = occDay;
    }
}
