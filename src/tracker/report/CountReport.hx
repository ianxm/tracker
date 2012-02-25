package tracker.report;

import tracker.Main;

class CountReport implements Report
{
    private var count :Int;

    public function new()
    {
        count = 0;
    }

    public function include(thisDay :Date, val :Int)
    {
        if( val != Main.NO_DATA )
            count++;
    }

    inline public function getLabel()
    {
        return "";
    }

    public function toString()
    {
        return count + ((count==1) ? " occurrence" : " occurrences");
    }
}
