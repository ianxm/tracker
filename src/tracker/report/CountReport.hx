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

class CountReport implements Report
{
    private var count :Int;

    public function new()
    {
        count = 0;
    }

    public function include(thisDay :Date, val :Float)
    {
        if( val != Main.NO_DATA )
            count++;
    }

    inline public function getLabel()
    {
        return "";
    }

    public function toString()
    {
        return count + ((count==1) ? " occurrence\n" : " occurrences\n");
    }
}
