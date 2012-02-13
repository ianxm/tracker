package tracker.report;

import utils.Utils;

class RecordMonthReport extends RecordReport
{
    public function new(s)
    {
        super(s);
        reportName = "month";
    }

    override public function include(thisDay :Date, val :Int)
    {
        if( val == 0 )
            return;

        var thisMonthStr = Std.string(thisDay.getFullYear()) + "-" + 
            Utils.zeroFill(thisDay.getMonth()+1,2);
        if( bins.exists(thisMonthStr) )
            bins.set(thisMonthStr, bins.get(thisMonthStr)+val);
        else
            bins.set(thisMonthStr, val);
    }

    override public function toString()
    {
        for( key in bins.keys() )
        {
            var val = bins.get(key);
            if( checkBest(bestScore, key, val) )
            {
                bestScore = val;
                bestDateStr = key;
            }
        }
        if( bestScore == 0 )
            return "no occurrences";

        return super.toString();
    }

    override private function keepCurrent(bestScore :Int, newDateStr :String, newScore :Int)
    {
        return newDateStr != null && 
            newDateStr == Std.string(Date.now().getFullYear()) + "-" + 
            Utils.zeroFill(Date.now().getMonth()+1,2);
    }
}
