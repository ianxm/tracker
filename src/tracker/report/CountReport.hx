package tracker.report;

class CountReport implements Report
{
    private var count :Int;

    public function new()
    {
        count = 0;
    }

    public function include(thisDay :Date, val :Int)
    {
        if( val > 0 )
            count++;
    }

    public function toString()
    {
        return count + ((count==1) ? " occurrence" : " occurrences");
    }
}
