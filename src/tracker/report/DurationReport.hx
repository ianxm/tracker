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

import tracker.Main;
import utils.Utils;

class DurationReport implements Report
{
    private var firstDate :Date;
    private var lastDate :Date;

    public function new()
    {
        firstDate = null;
        lastDate = null;
    }

    public function include(thisDay :Date, val :Float)
    {
        if( firstDate == null )
            firstDate = thisDay;
        else if( val == Main.NO_DATA )
            lastDate = thisDay;
    }

    public function toString()
    {
        if( firstDate==null || lastDate==null ) 
            return "empty range\n";

        var duration = Utils.dayDelta(firstDate, lastDate)+1;
        if( duration == 1 )
            return (Utils.dayDelta(firstDate, lastDate)+1) + " day: " +
                Utils.dayToStr(firstDate) + "\n";
        else
            return (Utils.dayDelta(firstDate, lastDate)+1) + " days" +
                " from " + Utils.dayToStr(firstDate) +
                " to " + Utils.dayToStr(lastDate) + "\n";
    }


    inline public function getLabel()
    {
        return "duration: ";
    }
}
