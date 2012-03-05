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
package utils;

using Lambda;

class TestUtils extends haxe.unit.TestCase
{
    public function testDayStr()
    {
        assertEquals("2010-01-01", Utils.dayStr(new Date(2010, 00, 01, 0, 0, 0)));
        assertEquals("2012-01-31", Utils.dayStr(new Date(2012, 00, 31, 0, 0, 0)));
        assertEquals("2011-03-01", Utils.dayStr(new Date(2011, 01, 29, 0, 0, 0))); // not leap year
        assertEquals("2012-02-29", Utils.dayStr(new Date(2012, 01, 29, 0, 0, 0)));
    }

    public function testDayFromString()
    {
        assertEquals("2010-01-01", Utils.dayFromString("2010-01-01").toString());
        assertEquals("2012-02-29", Utils.dayFromString("2012-02-29").toString());
        assertEquals("2011-03-01", Utils.dayFromString("2011-03-01").toString());
        assertEquals("2011-03-13", Utils.dayFromString("2011-03-13").toString());
    }

    public function testDayFromDate()
    {
        assertEquals("2010-01-01", Utils.dayFromDate(new Date(2010, 00, 01, 0, 0, 0)).toString());
        assertEquals("2012-02-29", Utils.dayFromDate(new Date(2012, 01, 29, 0, 0, 0)).toString());
        assertEquals("2011-03-01", Utils.dayFromDate(new Date(2011, 01, 29, 0, 0, 0)).toString());
    }

    public function testDayFromJulian()
    {
        assertEquals("2010-01-01", Utils.dayFromJulian(2455197.5).toString());
        assertEquals("2012-02-29", Utils.dayFromJulian(2455986.5).toString());
        assertEquals("2011-03-01", Utils.dayFromJulian(2455621.5).toString());
        assertEquals("2011-03-13", Utils.dayFromJulian(2455633.5).toString());
    }

    public function testDayShift()
    {
        assertEquals("2010-01-02", Utils.dayShift(Utils.dayFromString("2010-01-01"), 1).toString());
        assertEquals("2009-12-31", Utils.dayShift(Utils.dayFromString("2010-01-01"), -1).toString());
        assertEquals("2012-01-01", Utils.dayShift(Utils.dayFromString("2012-01-14"), -13).toString());
    }

    public function testDayDelta()
    {
        assertEquals(2, Utils.dayDelta(Utils.dayFromString("2010-01-01"), Utils.dayFromString("2010-01-03")));
        assertEquals(-2, Utils.dayDelta(Utils.dayFromString("2010-01-03"), Utils.dayFromString("2010-01-01")));
        assertEquals(-2, Utils.dayDelta(Utils.dayFromString("2010-01-01"), Utils.dayFromString("2009-12-30")));
        assertEquals(3, Utils.dayDelta(Utils.dayFromString("2009-12-29"), Utils.dayFromString("2010-01-01")));
    }

    public function testTenths()
    {
        assertEquals(1.1, Utils.tenths(1.1));
        assertEquals(1.1, Utils.tenths(1.1213));
        assertEquals(1.9, Utils.tenths(1.923));
        assertEquals(1.5, Utils.tenths(1.534));
        assertEquals(1.5, Utils.tenths(1.4934));
    }
}
