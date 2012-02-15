package tracker.report;

using Lambda;
import utils.Utils;

class RecordReport implements Report
{
    private var bestScore :Int;
    private var bestDateStr :String;

    private var binName :String;
    private var filterName :String;
    private var bins :Hash<Int>;
    private var startOfRange :Date;

    private var checkBest :Int->String->Int->Bool;
    private var dateToBin :Date->String;
    private var oneBack :Date->Date;

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
                oneBack = lastYear;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_MONTH:
            {
                binName = "month";
                dateToBin = dateToMonthBin;
                oneBack = lastMonth;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_WEEK:
            {
                binName = "week";
                dateToBin = dateToWeekBin;
                oneBack = lastWeek;
                bestDateStr = dateToBin(Date.now());
            }
        case BIN_DAY:
            {
                binName = "day";
                dateToBin = dateToDayBin;
                oneBack = yesterday;
                bestDateStr = dateToBin(Date.now());
            }
        }
    }

    public function include(thisDay :Date, val :Int)
    {
        if( startOfRange == null )                          // dont let lowest look past start of range
            startOfRange = thisDay;

        if( filterName == "lowest" )                        // handle gaps for lowest record
        {
            var oneBack = oneBack(thisDay);
            var oneBackStr = dateToBin(oneBack);
            if( !bins.exists(oneBackStr) && Utils.dayDelta(oneBack,startOfRange)<0)
                bins.set(oneBackStr, 0);
        }

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
        var keys = [];                                      // sort keys
        for( key in bins.keys() )
            keys.push(key);
        keys.sort(function(a,b) return (a<b)?-1:(a>b)?1:0);

        for( key in keys )
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

    inline public function getLabel()
    {
        return filterName + " "+ binName +": ";
    }

    // which to keep (chosen by filter strategy)
    inline private function keepLowest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore >= newScore;
    }

    inline private function keepHighest(bestScore :Int, newDateStr :String, newScore :Int) :Bool
    {
        return bestScore <= newScore;
    }

    inline private function keepCurrent(bestScore :Int, newDateStr :String, newScore :Int)
    {
        return newDateStr != null && newDateStr == dateToBin(Date.now());
    }

    // how to bin (chosen by bin strategy)
    inline public function dateToYearBin(date)
    {
        return Std.string(date.getFullYear());
    }

    inline public function dateToMonthBin(date)
    {
        return date.toString().substr(0, 7);
    }

    inline public function dateToWeekBin(date)
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate()-date.getDay(), 0, 0, 0).toString().substr(0, 10);
    }

    inline public function dateToDayBin(date)
    {
        return date.toString().substr(0, 10);
    }

    // how to bin (chosen by bin strategy)
    inline public function lastYear(date)
    {
        return new Date(date.getFullYear()-1, date.getMonth(), date.getDate(), 0, 0, 0);
    }

    inline public function lastMonth(date)
    {
        return new Date(date.getFullYear(), date.getMonth()-1, 1, 0, 0, 0);
    }

    inline public function lastWeek(date)
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate()-date.getDay()-7, 0, 0, 0);
    }

    inline public function yesterday(date)
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate()-1, 0, 0, 0);
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
