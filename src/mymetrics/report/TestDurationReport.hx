package mymetrics.report;

class TestDurationReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new DurationReport();
      var ret =   "no occurrences";
      assertEquals(ret, report.toString());
  }

  public function testOne()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("duration: 1 day: 2012-01-01", report.toString());
  }

  public function testNoneWithFixedBounds()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("duration: 2 days from 2012-01-01 to 2012-01-02", report.toString());
  }

  public function testSomeWithFixedBounds()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 0);
      report.include(Date.fromString("2012-01-03"), 0);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("duration: 4 days from 2012-01-01 to 2012-01-04", report.toString());
  }

  public function testOccOnEndDay()
  {
      var report = new DurationReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 0);
      report.include(Date.fromString("2012-01-03"), 0);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("duration: 3 days from 2012-01-01 to 2012-01-03", report.toString());
  }
}
