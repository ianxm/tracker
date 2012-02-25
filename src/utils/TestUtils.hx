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

    public function testDay()
    {
        assertEquals("2010-01-01 00:00:00", Utils.day(new Date(2010, 00, 01, 0, 0, 0)).toString());
        assertEquals("2012-02-29 00:00:00", Utils.day(new Date(2012, 01, 29, 0, 0, 0)).toString());
        assertEquals("2011-03-01 00:00:00", Utils.day(new Date(2011, 01, 29, 0, 0, 0)).toString());
    }

    public function testDayToStr()
    {
        assertEquals("2010-01-01", Utils.dayToStr(new Date(2010, 00, 01, 1, 0, 0)).toString());
        assertEquals("2012-02-29", Utils.dayToStr(new Date(2012, 01, 29, 0, 2, 0)).toString());
        assertEquals("2011-03-01", Utils.dayToStr(new Date(2011, 01, 29, 0, 0, 3)).toString());
    }

    public function testDayShift()
    {
        assertEquals("2010-01-02 00:00:00", Utils.dayShift(new Date(2010, 00, 01, 0, 0, 0), 1).toString());
        assertEquals("2009-12-31 00:00:00", Utils.dayShift(new Date(2010, 00, 01, 0, 0, 0), -1).toString());
        assertEquals("2012-01-01 00:00:00", Utils.dayShift(new Date(2012, 00, 14, 0, 0, 0), -13).toString());
    }
    /*
    public function testDateBug()
    {
        assertEquals("2011-03-13 00:00:00", new Date(2011, 02, 13, 0, 0, 0).toString());
    }
    */
    public function testDayDelta()
    {
        assertEquals(2, Utils.dayDelta(new Date(2010, 00, 01, 0, 0, 0), new Date(2010, 00, 03, 0, 0, 0)));
        assertEquals(-2, Utils.dayDelta(new Date(2010, 00, 03, 0, 0, 0), new Date(2010, 00, 01, 0, 0, 0)));
        assertEquals(-2, Utils.dayDelta(new Date(2010, 00, 01, 0, 0, 0), new Date(2009, 11, 30, 0, 0, 0)));
        assertEquals(3, Utils.dayDelta(new Date(2009, 11, 29, 0, 0, 0), new Date(2010, 00, 01, 0, 0, 0)));
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
