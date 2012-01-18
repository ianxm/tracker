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

    public function testZeroFill()
    {
        assertEquals("01", Utils.zeroFill(1, 2));
        assertEquals("010", Utils.zeroFill(10, 3));
        assertEquals("13", Utils.zeroFill(13, 2));
        assertEquals("015", Utils.zeroFill(15, 3));
        assertEquals("00015", Utils.zeroFill(15, 5));
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
