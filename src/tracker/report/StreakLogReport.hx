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
import tracker.Main;
import utils.Utils;

class StreakLogReport implements Report
{
    private var buf :StringBuf;
    private var startOfStreak :Date;
    private var lastDay :Date;
    private var count :Int;

    public function new()
    {
        buf = new StringBuf();
        startOfStreak = null;
        lastDay = null;
        count = 0;
    }

    // val may be zero for first and last call
    public function include(occDay :Date, occVal :Float)
    {
        if( lastDay == null )                               // first
        {
            lastDay = occDay;
            if( occVal != Main.NO_DATA )
            {
                startOfStreak = occDay;
                count = 1;
            }
            return;
        }

        var delta = Utils.dayDelta(lastDay, occDay);
        //trace("delta: " + delta + " " +lastDay + " "  + occDay);

        if( occVal==Main.NO_DATA && lastDay!=null )         // last
        {
            if( count > 0 )
                append("on", count, startOfStreak);
            if( delta > 0 )
            {
                if( count == 0 )                            // no occurrences
                    append("off", delta+1, lastDay);
                else
                    append("off", delta, Utils.dayShift(lastDay, 1));
            }
            return;
        }

        if( delta==1 && count>0 )                           // extend current on streak
            count++;
        else                                                // start new on streak
        {
            if( count > 0 )
                append("on", count, startOfStreak);
            if( delta > 0 )
                if( count == 0 )                            // no occurrences
                    append("off", delta, lastDay);
                else
                    append("off", delta-1, Utils.dayShift(lastDay, 1));
            startOfStreak = occDay;
            count = 1;
        }

        lastDay = occDay;
    }

    private function append(onOrOff :String, days, from)
    {
        var onOrOffStr = onOrOff.lpad(' ', 5);
        var daysStr = Std.string(days).lpad(' ', 3);

        buf.add(onOrOffStr + " " + daysStr + 
                ((days==1)? " day " : " days") + 
                " from " + Utils.dayStr(from) + "\n");
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
