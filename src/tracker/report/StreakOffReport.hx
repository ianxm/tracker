package tracker.report;

import utils.Utils;

class StreakOffReport extends StreakReport
{
    private var startOfStreak :Date;
    private var lastDay :Date;
    private var count :Int;

    public function new()
    {
        super("longest off streak: ");
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
        checkBest(Utils.dayShift(lastDay, 1), delta-1);
        lastDay = occDay;
    }
}
