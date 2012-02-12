package tracker.report;

import utils.Utils;

class RecordYearReport extends RecordReport
{
    public function new(s)
    {
        super(s);
        reportName = "year";
    }

    override public function include(thisDay :Date, val :Int)
    {
        if( val == 0 )
            return;

        if( bins.exists(thisDay.getFullYear()) )
            bins.set(thisDay.getFullYear(), bins.get(thisDay.getFullYear())+val);
        else
            bins.set(thisDay.getFullYear(), val);
    }

    override public function toString()
    {
        for( key in bins.keys() )
        {
            var val = bins.get(key);
            if( checkBest(bestScore, Std.string(key), val) )
            {
                bestScore = val;
                bestDateStr = Std.string(key);
            }
        }
        if( bestScore == 0 )
            return "no occurrences";

        return super.toString();
    }

    override private function keepCurrent(bestScore :Int, newDateStr :String, newScore :Int)
    {
        return newDateStr != null && 
            newDateStr == Std.string(Date.now().getFullYear());
    }
}
