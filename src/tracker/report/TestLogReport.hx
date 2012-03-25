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

import utils.Utils;
import tracker.Main;

class TestLogReport extends haxe.unit.TestCase
{
    public function testEmpty()
    {
        var report = new LogReport(DAY, TOTAL);
        assertEquals("no occurrences\n", report.toString());
    }

    public function testOne()
    {
        var report = new LogReport(DAY, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n", report.toString());
    }

    public function testOneFixedStartStop()
    {
        var report = new LogReport(DAY, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n", report.toString());
    }

    public function testTwo()
    {
        var report = new LogReport(DAY, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
    }

    public function testTwoWithZero()
    {
        var report = new LogReport(DAY, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 0);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n  2012-01-02: 0\n", report.toString());
    }

    public function testTwoMonths()
    {
        var report = new LogReport(MONTH, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-02-02"), 2);
        report.include(Utils.dayFromString("2012-02-02"), Main.NO_DATA);
        assertEquals("  2012-01: 1\n  2012-02: 2\n", report.toString());
    }

    public function testTwoGap()
    {
        var report = new LogReport(DAY, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-05"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
    }

    public function testWeek()
    {
        var report = new LogReport(WEEK, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 3\n", report.toString());
    }

    public function testWeekCount()
    {
        var report = new LogReport(WEEK, COUNT);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 2\n", report.toString());
    }

    public function testWeekAvg()
    {
        var report = new LogReport(WEEK, AVG);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 0.4\n", report.toString());
    }

    public function testWeekPercent()
    {
        var report = new LogReport(WEEK, PCT);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-02"), 2);
        report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
        assertEquals("  2012-01-01: 29\n", report.toString());
    }

    public function testWeekGap()
    {
        var report = new LogReport(WEEK, TOTAL);
        report.include(Utils.dayFromString("2012-01-01"), 1);
        report.include(Utils.dayFromString("2012-01-18"), 2);
        report.include(Utils.dayFromString("2012-01-18"), Main.NO_DATA);
        assertEquals("  2012-01-01: 1\n  2012-01-08: 0\n  2012-01-15: 2\n", report.toString());
    }

    public function testWeekGap2()
    {
        var report = new LogReport(WEEK, TOTAL);
        report.include(Utils.dayFromString("2012-03-04"), 1);
        report.include(Utils.dayFromString("2012-03-19"), 1);
        report.include(Utils.dayFromString("2012-03-20"), 1);
        report.include(Utils.dayFromString("2012-03-20"), Main.NO_DATA);
        assertEquals("  2012-03-04: 1\n  2012-03-11: 0\n  2012-03-18: 2\n", report.toString());
    }
}
