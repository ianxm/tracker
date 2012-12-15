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

class StreakLogReport implements Report
{
    private var buf           :StringBuf;
    private var startOfStreak :Gregorian;
    private var lastDay       :Gregorian;
    private var cmd           :Command;
    private var append        :Float -> Gregorian -> String -> Void;
    private var val           :Float;                       // number of days for streaks, 
                                                            // or sum of values over count days for bursts

    public function new(c :Command)
    {
        buf = new StringBuf();
        startOfStreak = null;
        lastDay = null;
        val = 0;
        cmd = c;
        append = (cmd==STREAKS) ? appendStreak : appendBurst;
    }

    // val may be zero for first and last call
    dynamic public function include(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )                               // first
        {
            lastDay = occDay;
            if( !Main.IS_NO_DATA(occVal) )
            {
                startOfStreak = occDay;
                val = (cmd==STREAKS) ? 1 : occVal;
            }
            return;
        }

        var delta = Std.int(occDay.value-lastDay.value);
        //trace("delta: " + delta + " " +lastDay + " "  + occDay);

        if( Main.IS_NO_DATA(occVal) )                       // last
        {
            if( val > 0 )
                append(val, startOfStreak, "on");
            if( delta > 0 )
            {
                if( cmd == STREAKS )
                    if( val == 0 )                          // no occurrences
                        append(delta+1, lastDay, "off");
                    else
                        append(delta, Utils.dayShift(lastDay, 1), "off");
            }
            return;
        }

        if( delta==1 && val>0 )                             // extend current on streak
            val += (cmd==STREAKS) ? 1 : occVal;
        else                                                // start new on streak
        {
            if( val > 0 )
                append(val, startOfStreak, "on");
            if( delta > 0 )
                if( cmd == STREAKS )
                    if( val == 0 )                          // no occurrences
                        append(delta, lastDay, "off");
                    else
                        append(delta-1, Utils.dayShift(lastDay, 1), "off");
            startOfStreak = occDay;
            val = (cmd==STREAKS) ? 1 : occVal;
        }

        lastDay = occDay;
    }

    private function appendStreak(val :Float, from :Gregorian, onOrOff :String)
    {
        var onOrOffStr = onOrOff.lpad(' ', 5);
        var daysStr = Std.string(val).lpad(' ', 3);

        buf.add(onOrOffStr + " " + daysStr + 
                ((val==1)? " day " : " days") + 
                " from " + from + "\n");
    }

    private function appendBurst(val :Float, from :Gregorian, onOrOff :String)
    {
        buf.add(from + ": " + val + "\n");
    }

    public function toString()
    {
        return if( buf.toString().length>0 )
            buf.toString();
        else
            "no occurrences\n";
    }

    inline public function getLabel()
    {
        return "";
    }
}
