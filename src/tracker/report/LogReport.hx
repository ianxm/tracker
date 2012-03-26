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

import altdate.Gregorian;
import utils.Utils;
import tracker.Main;

class LogReport implements Report
{
    private var buf         :StringBuf;                     // output buffer
    private var cmd         :Command;                       // which log command
    private var dateToBin   :Gregorian->String;             // convert date to bin key
    private var startOfBin  :Gregorian->Gregorian;          // go to the first day of the bin
    private var valToBin    :Float -> Gregorian -> Float;   // convert value to pack in bin
    private var getDuration :Gregorian -> Int;              // get num days for averaging
    private var printVal    :Float -> Float;                // set precision of output
    private var lastBin     :String;                        // key of last bin
    private var lastVal     :Float;                         // value in last bin
    private var firstDay    :Gregorian;                     // needed for full grouping
    private var lastDay     :Gregorian;                     // needed for full grouping
    private var gapCheck    :Bool;                          // if true, check for gaps

    public function new(gt, vt)
    {
        buf = new StringBuf();

        switch( gt )
        {
        case DAY:
            {
                dateToBin = RecordReport.dateToDayBin;
                startOfBin = function(date) { return null; } // shouldn't need this
                getDuration = function(date) { return 1; }
                gapCheck = false;
            }
        case WEEK:
            {
                dateToBin = RecordReport.dateToWeekBin;
                startOfBin = startOfWeekBin;
                getDuration = function(date) { return 7; }
                gapCheck = true;
            }
        case MONTH:
            {
                dateToBin = RecordReport.dateToMonthBin;
                startOfBin = startOfMonthBin;
                getDuration = function(date) { return DateTools.getMonthDays(new Date(date.year, date.month, 1, 0, 0, 0)); }
                gapCheck = true;
            }
        case YEAR:
            {
                dateToBin = RecordReport.dateToYearBin;
                startOfBin = startOfYearBin;
                getDuration = function(date) { return 365; } // do I care about leap day?  I do not.
                gapCheck = true;
            }
        case FULL: 
            {
                dateToBin = function(date) { return "all-time"; }
                startOfBin = function(date) { return null; } // shouldnt need this
                getDuration = function(date) { return 1; }  // must track full duration
                gapCheck = false;
            }
        }

        switch( vt )
        {
        case TOTAL:
            {
                valToBin = function(val,date) { return val; }
                printVal = Math.round;
            }
        case COUNT:
            {
                valToBin = function(val,date) { return 1; }
                printVal = Math.round;
            }
        case AVG:
            {
                valToBin = function(val,date) { return val/getDuration(date); }
                printVal = function(val) {    // for full duration we have to put off evaluating the
                    if( gt == FULL )          // duration until all data has been processed
                        val = val/(lastDay.value-firstDay.value) + 1;
                    return Math.round(val*10)/10;
                }
            }
        case PCT:
            {
                valToBin = function(val,date) { return 1/getDuration(date)*100; }
                printVal = function(val) {                  // ditto whats said for AVG
                    if( gt == FULL )
                        val = val/(lastDay.value-firstDay.value) + 1;
                    return Math.round(val);
                }
            }
        }
    }

    public function include(thisDay :Gregorian, val :Float)
    {
        //trace("top: " + thisDay + " " + val);
        if( firstDay == null )
            firstDay = thisDay;

        if( Main.IS_NO_DATA(val) )
        {
            writeLastBin(thisDay);
            var thisBin = dateToBin(thisDay);
            if( lastDay!=null && thisBin!=lastBin && gapCheck )
                buf.add("  " + thisBin + ": 0\n");
            lastBin = thisBin;
            lastVal = 0;
            lastDay = thisDay;
            return;
        }

        var thisBin = dateToBin(thisDay);                   // get bin key
        val = valToBin(val, thisDay);

        if( lastBin == null )                               // first value
        {
            lastBin = thisBin;
            lastVal = val;
        }
        else
        {
            if( thisBin == lastBin )                        // same bin as last and not end range
                lastVal += val;
            else
            {
                writeLastBin(thisDay);
                lastBin = thisBin;
                lastVal = val;
            }
        }
        lastDay = thisDay;
    }

    public function toString()
    {
        return if( buf.toString().length>0 )
            buf.toString();
        else
            "no occurrences\n";
    }

    // write the last bin to the log
    // then write gaps from lastDay till thisDay to the log
    private function writeLastBin(thisDay :Gregorian)
    {
        if( lastBin != null )
            buf.add("  " + lastBin + ": " + printVal(lastVal) + "\n");

        if( gapCheck && lastDay!=null )
        {
            var gapCheckDay = startOfBin(lastDay);          // copy date obj
            while( true )
            {
                gapCheckDay.day += getDuration(gapCheckDay); // move to start of next bin
                if( gapCheckDay.value+getDuration(gapCheckDay) > thisDay.value )
                    break;
                buf.add("  " + dateToBin(gapCheckDay) + ": 0\n");
            }
        }
    }

    inline public function getLabel()
    {
        return "";
    }

    // go to start of bin
    inline private static function startOfYearBin(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, 0, 1);
        return ret;
    }

    inline private static function startOfMonthBin(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month, 1);
        return ret;
    }

    inline private static function startOfWeekBin(date)
    {
        var ret = new Gregorian();
        ret.set(false, null, date.year, date.month, date.day-date.dayOfWeek());
        return ret;
    }
}
