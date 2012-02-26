package tracker.report;

import tracker.Main;

class TestDurationReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new DurationReport();
      assertEquals("empty range\n", report.toString());
  }

  public function testOne()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 day: 2012-01-01\n", report.toString());
  }

  public function testNoneWithFixedBounds()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2 days from 2012-01-01 to 2012-01-02\n", report.toString());
  }

  public function testSomeWithFixedBounds()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), Main.NO_DATA);
      assertEquals("4 days from 2012-01-01 to 2012-01-04\n", report.toString());
  }

  public function testOccOnEndDay()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
      assertEquals("3 days from 2012-01-01 to 2012-01-03\n", report.toString());
  }
}
