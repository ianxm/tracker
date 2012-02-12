package tracker.report;

class RecordReport implements Report
{
    private var bestScore :Int;
    private var bestDateStr :String;
    private var reportName :String;

    private var bins :IntHash<Int>;
    private var strategyName :String;
    private var checkBest :Int->String->Int->Bool;

    public function new( s :Strategy )
    {
        bestScore = 0;
        bestDateStr = null;
        bins = new IntHash<Int>();
        switch( s )
        {
        case KEEP_LOWEST:
            {
                strategyName = "lowest";
                checkBest = keepLowest;
                bestScore = 9999;
            }
        case KEEP_HIGHEST:
            {
                strategyName = "highest";
                checkBest = keepHighest;
            }
        case KEEP_CURRENT:
            {
                strategyName = "current";
                checkBest = keepCurrent;
            }
        }
    }

    public function include(thisDay :Date, val :Int)
    {
        throw "must override";
    }

    public function toString()
    {
        return strategyName + " "+ reportName +": " + bestScore + " (" + bestDateStr + ")";
    }

    private function keepLowest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore > newScore;
    }

    private function keepHighest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore < newScore;
    }

    private function keepCurrent(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        throw "must override";
        return false;
    }
}

enum Strategy
{
    KEEP_LOWEST;
    KEEP_HIGHEST;
    KEEP_CURRENT;
}
