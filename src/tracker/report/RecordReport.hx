package tracker.report;

class RecordReport implements Report
{
    private var bestScore :Int;
    private var bestDateStr :String;

    private var bins :Hash<Int>;
    private var binName :String;
    private var filterName :String;

    private var checkBest :Int->String->Int->Bool;
    private var dateToBin :Date->String;

    public function new( bin :BinStrategy, keep :FilterStrategy )
    {
        bestScore = 0;
        bestDateStr = null;
        bins = new Hash<Int>();

        switch( keep )
        {
        case KEEP_LOWEST:
            {
                filterName = "lowest";
                checkBest = keepLowest;
                bestScore = 9999;
            }
        case KEEP_HIGHEST:
            {
                filterName = "highest";
                checkBest = keepHighest;
            }
        case KEEP_CURRENT:
            {
                filterName = "current";
                checkBest = keepCurrent;
            }
        }

        switch( bin )
        {
        case BIN_YEAR:
            {
                binName = "year";
                dateToBin = dateToYearBin;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_MONTH:
            {
                binName = "month";
                dateToBin = dateToMonthBin;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_WEEK:
            {
                binName = "week";
                dateToBin = dateToWeekBin;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_DAY:
            {
                binName = "day";
                dateToBin = dateToDayBin;
                bestDateStr = dateToBin(Date.now());
            }
        }
    }

    public function include(thisDay :Date, val :Int)
    {
        if( val == 0 )
            return;

        var binStr = dateToBin(thisDay);
        if( bins.exists(binStr) )
            bins.set(binStr, bins.get(binStr)+val);
        else
            bins.set(binStr, val);
    }

    public function toString()
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
        return (( bestDateStr == null ) ? "none" : bestDateStr + " (" + bestScore + ")");
    }

    public function getLabel()
    {
        return filterName + " "+ binName +": ";
    }

    // which to keep (chosen by filter strategy)
    private function keepLowest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore > newScore;
    }

    private function keepHighest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore < newScore;
    }

    private function keepCurrent(bestScore :Int, newDateStr :String, newScore :Int)
    {
        return newDateStr != null && newDateStr == dateToBin(Date.now());
    }

    // how to bin (chosen by bin strategy)
    public function dateToYearBin(date)
    {
        return Std.string(date.getFullYear());
    }

    public function dateToMonthBin(date)
    {
        return date.toString().substr(0, 7);
    }

    public function dateToWeekBin(date)
    {
        var startOfWeek = new Date(date.getFullYear(), date.getMonth(), date.getDate()-date.getDay(), 0, 0, 0);
        return startOfWeek.toString().substr(0, 10);
    }

    public function dateToDayBin(date)
    {
        return date.toString().substr(0, 10);
    }
}

enum BinStrategy
{
    BIN_YEAR;
    BIN_MONTH;
    BIN_WEEK;
    BIN_DAY;
}

enum FilterStrategy
{
    KEEP_LOWEST;
    KEEP_HIGHEST;
    KEEP_CURRENT;
}
