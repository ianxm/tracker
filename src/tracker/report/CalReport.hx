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
using StringTools;
import DeepHash;
import utils.Utils;
import tracker.Main;

class CalReport implements Report
{
    private static var MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    private var tree :DeepHash<Int,Float>;
    private var firstDay :Date;
    private var lastDay :Date;
    private var valToBin :Float -> Float;

    public function new(vt)
    {
        tree = new DeepHash<Int,Float>();
        switch( vt )
        {
        case TOTAL: valToBin = function(ii) { return ii; }
        case COUNT: valToBin = function(ii) { return 1; }
        default: throw "calendar reports only support 'total' or 'count' values";
        }
    }

    public function include(thisDay :Date, val :Float)
    {
        if( firstDay == null )
            firstDay = thisDay;
        lastDay = thisDay;
        if( !Main.IS_NO_DATA(val) )
            tree.set(pathFromDay(thisDay), valToBin(val));
    }

    inline public function getLabel()
    {
        return "";
    }

    public function toString()
    {
        if( firstDay == null )
            return "no occurrences\n";

        var buf = new StringBuf();

        var month = new Date(firstDay.getFullYear(), firstDay.getMonth(), 1, 0, 0, 0);
        var lastMonth = new Date(lastDay.getFullYear(), lastDay.getMonth(), 1, 0, 0, 0);
        do {
            printMonth(buf, month);
            month = new Date(month.getFullYear(), month.getMonth()+1, 1, 0, 0, 0);
        } while( Utils.dayDelta(month, lastMonth) >= 0 );

        return buf.toString();
    }

    private function printMonth(buf, month :Date)
    {
        var monthNum = month.getMonth();

        buf.add("\n             " + MONTH_NAMES[monthNum] + " " + month.getFullYear() + "\n" +
                "  Su   Mo   Tu   We   Th   Fr   Sa\n");

        // print given month
        var day = month;
        for( ii in 0...month.getDay() )
            buf.add("     ");

        var today = Date.now();
        do {
            var val = tree.get(pathFromDay(day));
            var str = if( val != null )
                Std.string(val).lpad(' ',4);
            else if( Utils.dayDelta(day, today) <= 0 )
                "   _";
            else
                "   .";
            buf.add(str +" ");
            if( day.getDay() == 6 )
                buf.add("\n");
            day = Utils.dayShift(day, 1);
        } while( day.getMonth() == monthNum );
        buf.add("\n");
    }

    inline private function pathFromDay(day)
    {
        return [day.getFullYear(), day.getMonth(), day.getDate()].list();
    }
}
