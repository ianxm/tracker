package tracker.report;

class TestLogReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new LogReport();
      assertEquals("no occurrences", report.toString());
  }

  public function testOne()
  {
      var report = new LogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("  2012-01-01: 1\n", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new LogReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("  2012-01-01: 1\n", report.toString());
  }

  public function testTwo()
  {
      var report = new LogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
  }


  public function testTwoGap()
  {
      var report = new LogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
  }
}
