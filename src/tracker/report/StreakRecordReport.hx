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

using StringTools;
import altdate.Gregorian;
import tracker.Main;
import utils.Utils;
import tracker.report.RecordReport;

class StreakRecordReport implements Report
{
    private var startOfStreak :Gregorian;
    private var lastDay :Gregorian;
    private var count :Int;

    private var bestStreakLength :Int;
    private var bestStartDate :Gregorian;

    private var filterName :String;
    private var isStreakOn :Bool;
    private var isBest :Int -> Int -> Bool;
    dynamic public function include(thisDay :Gregorian, val :Float) {}

    public function new(keep :FilterStrategy)
    {
        bestStreakLength = 0;
        bestStartDate = null;

        startOfStreak = null;
        lastDay = null;
        count = 0;

        switch( keep )
        {
        case KEEP_LOWEST:
            {
                filterName = "longest off streak: ";
                isBest = function(a,b) return a>=b;
                include = includeOff;
            }
        case KEEP_HIGHEST:
            {
                filterName = "longest on streak: ";
                isBest = function(a,b) return a>=b;
                include = includeOn;
            }
        case KEEP_CURRENT:
            {
                filterName = "current streak: ";
                isBest = function(a,b) return true;
                include = includeCurrent;
            }
        }
    }

    public function toString()
    {
        var onOrOff = if( isStreakOn == null )
            "\n";
        else if( isStreakOn == true )
            " (on)\n";
        else
            " (off)\n";
        return if( bestStartDate == null )
            "none\n";
        else if( bestStreakLength == 1 )
            "  1 day  starting on " + bestStartDate + onOrOff;
        else
            Std.string(bestStreakLength).lpad(' ',3) + " days starting on " + bestStartDate + onOrOff;
    }

    inline public function getLabel()
    {
        return filterName;
    }

    private function checkBest(checkDate, checkLength)
    {
        if( isBest(checkLength, bestStreakLength) )
        {
            bestStartDate = checkDate;
            bestStreakLength = checkLength;
       }
    }

    // val may be zero for first and last call
    public function includeOff(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);
        checkBest(Utils.dayShift(lastDay, 1), delta-1);
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeOn(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);

        if( delta == 1 )                                    // extend current on streak
            count++;
        else if( !Main.IS_NO_DATA(occVal) )                 // start new streak
        {
            startOfStreak = occDay;
            count = 1;
        }
        checkBest(startOfStreak, count);                    // check for new best
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeCurrent(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);

        if( delta == 1 && !Main.IS_NO_DATA(occVal) )        // extend current on streak
            count++;
        else
        {
            if( !Main.IS_NO_DATA(occVal) )                  // start new on streak
            {
                startOfStreak = occDay;
                count = 1;
                isStreakOn = true;
            }
            else if( delta != 0 )                           // end on an off streak
            {
                startOfStreak = Utils.dayShift(lastDay, 1);
                count = delta;
                isStreakOn = false;
            }
        }
        checkBest(startOfStreak, count);                    // check for new best
        lastDay = occDay;
    }
}
