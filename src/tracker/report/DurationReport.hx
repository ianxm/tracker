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
import tracker.Main;
import utils.Utils;

class DurationReport implements Report
{
    private var firstDate :Gregorian;
    private var lastDate :Gregorian;

    public function new()
    {
        firstDate = null;
        lastDate = null;
    }

    dynamic public function include(thisDay :Gregorian, val :Float)
    {
        if( firstDate == null )
            firstDate = thisDay;
        else if( Main.IS_NO_DATA(val) )
            lastDate = thisDay;
    }

    public function toString()
    {
        if( firstDate==null || lastDate==null ) 
            return "empty range\n";

        var duration = lastDate.value - firstDate.value + 1;
        if( duration == 1 )
            return "1 day: " + firstDate + "\n";
        else
            return duration + " days" + " from " + firstDate + " to " + lastDate + "\n";
    }


    inline public function getLabel()
    {
        return "duration: ";
    }
}
