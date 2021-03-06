/*
 Copyright (c) 2012, Ian Martins (ianxm@jhu.edu)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/
package tracker.report;

using Lambda;
import altdate.Gregorian;
import tracker.Main;
import utils.Utils;

class RecordReport implements Report
{
    private var bestScore    :Float;
    private var bestDateStr  :String;

    private var binName      :String;
    private var filterName   :String;
    private var bins         :Hash<Float>;
    private var startOfRange :Gregorian;

    private var checkBest    :Float->String->Float->Bool;  // check for the record
    private var dateToBin    :Gregorian->String;           // convert date to bin string
    private var valToBin     :Float -> Gregorian -> Float; // convert value to pack in bin
    private var getDuration  :Gregorian -> Int;            // get num days for computing percent
    private var printVal     :Float -> Float;              // set precision of output
    private var oneBack      :Gregorian->Gregorian;        // get date one (day/week/month/year) ago
    dynamic public function include(thisDay :Gregorian, val :Float) {}

    public function new( gt :GroupType, keep :FilterStrategy, vt :ValType )
    {
        bestScore = 0;
        bestDateStr = null;
        bins = new Hash<Float>();

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

        switch( gt )
        {
        case YEAR:
            {
                binName = "year";
                dateToBin = dateToYearBin;
                oneBack = lastYear;
                bestDateStr = dateToBin(Utils.today());
            }
        case MONTH:
            {
                binName = "month";
                dateToBin = dateToMonthBin;
                oneBack = lastMonth;
                bestDateStr = dateToBin(Utils.today());
            }
        case WEEK:
            {
                binName = "week";
                dateToBin = dateToWeekBin;
                oneBack = lastWeek;
                bestDateStr = dateToBin(Utils.today());
            }
        case DAY:
            {
                binName = "day";
                dateToBin = dateToDayBin;
                oneBack = yesterday;
                bestDateStr = dateToBin(Utils.today());
            }
        default: throw "bad group";

        }

        getDuration = switch( vt )
        {
        case TOTAL, COUNT:  function(date) { return 1; }
        case AVG_DAY:       function(date) { return 1; }
        case AVG_WEEK:      function(date) { return 7; }
        case AVG_MONTH:     function(date) { return DateTools.getMonthDays(new Date(date.year, date.month, 1, 0, 0, 0)); }
        case AVG_YEAR:      function(date) { return 365; } // do I care about leap day?  I do not.
        case PERCENT: switch( gt ) {
            case FULL:       function(date) { return 1; }
            case YEAR:       function(date) { return 365; }
            case MONTH:      function(date) { return DateTools.getMonthDays(new Date(date.year, date.month, 1, 0, 0, 0)); }
            case WEEK:       function(date) { return 7; }
            case DAY:        function(date) { return 1; }
            }
        }

        var divideBy = switch( vt )
        {
        case AVG_MONTH: switch( gt ) {
            case YEAR: 12;
            case MONTH: 1;
            default: 0;
            }
        case AVG_WEEK: switch( gt ) {
            case YEAR: 52;
            case MONTH: 4;
            case WEEK: 1;
            default: 0;
            }
        case AVG_DAY: switch( gt ) {
            case YEAR: 365; // leap day?
            case MONTH: 30; // about
            case WEEK: 7;
            case DAY: 1;
            default: 0;
            }
        default: 1;
        }

        switch( vt )
        {
        case TOTAL:
            {
                valToBin = function(val,date) { return val; }
                printVal = function(val) { return Math.round(val*100)/100; }
            }
        case COUNT:
            {
                valToBin = function(val,date) { return 1; }
                printVal = function(val) { return val; }
            }
        case AVG_DAY, AVG_WEEK, AVG_MONTH, AVG_YEAR:
            {
                valToBin = function(val,date) { return val/divideBy; }
                printVal = function(val) { return Math.round(val*100)/100; }
            }
        case PERCENT:
            {
                valToBin = function(val,date) { return 1/getDuration(date)*100; }
                printVal = Math.round;
            }
        }
        include = myInclude;
    }

    public function myInclude(thisDay :Gregorian, val :Float)
    {
        if( startOfRange == null )                          // dont let lowest look past start of range
            startOfRange = thisDay;

        if( filterName == "lowest" )                        // handle gaps for lowest record
        {
            var oneBack = oneBack(thisDay);
            var oneBackStr = dateToBin(oneBack);
            if( !bins.exists(oneBackStr) && startOfRange.value-oneBack.value<0)
                bins.set(oneBackStr, 0);
        }

        if( Main.IS_NO_DATA(val) )
            return;

        var binStr = dateToBin(thisDay);
        val = valToBin(val, thisDay);
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
        return (( bestDateStr == null ) ? "none" : bestDateStr + " (" + printVal(bestScore) + ")\n");
    }

    inline public function getLabel()
    {
        return filterName + " "+ binName +": ";
    }

    // which to keep (chosen by filter strategy)
    inline private function keepLowest(bestScore :Float, newDateStr :String, newScore :Float) :Bool
    {
        return bestScore >= newScore;
    }

    inline private function keepHighest(bestScore :Float, newDateStr :String, newScore :Float) :Bool
    {
        return bestScore <= newScore;
    }

    inline private function keepCurrent(bestScore :Float, newDateStr :String, newScore :Float)
    {
        return newDateStr != null && newDateStr == dateToBin(Utils.today());
    }

    // how to bin (chosen by bin strategy)
    inline public static function dateToYearBin(date)
    {
        return Std.string(date.year);
    }

    inline public static function dateToMonthBin(date)
    {
        return date.toString().substr(0, 7);
    }

    inline public static function dateToWeekBin(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month, date.day-date.dayOfWeek());
        return ret.toString();
    }

    inline public static function dateToDayBin(date)
    {
        return date.toString();
    }

    // step back one unit of time
    inline private function lastYear(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year-1, date.month, date.day);
        return ret;
    }

    inline private function lastMonth(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month-1, 1);
        return ret;
    }

    inline private function lastWeek(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month, date.day-date.dayOfWeek()-7);
        return ret;
    }

    inline private function yesterday(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month, date.day-1);
        return ret;
    }
}

enum FilterStrategy
{
    KEEP_LOWEST;
    KEEP_HIGHEST;
    KEEP_CURRENT;
}
