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
package tracker;

import utils.TestUtils;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new tracker.report.TestDurationReport());
        r.add(new tracker.report.TestLogReport());
        r.add(new tracker.report.TestCountReport());
        r.add(new tracker.report.TestStreakReport());
        r.add(new tracker.report.TestStreakLogReport());
        // r.add(new tracker.report.TestCalReport());
        r.add(new tracker.report.TestRecordReport());
        r.add(new utils.TestUtils());
        r.run();
    }
}
