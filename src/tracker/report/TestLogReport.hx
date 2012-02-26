package tracker.report;

import tracker.Main;

class TestLogReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new LogReport(DLOG);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOne()
  {
      var report = new LogReport(DLOG);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("  2012-01-01: 1\n", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new LogReport(DLOG);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("  2012-01-01: 1\n", report.toString());
  }

  public function testTwo()
  {
      var report = new LogReport(DLOG);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
  }

  public function testTwoWithZero()
  {
      var report = new LogReport(DLOG);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("  2012-01-01: 1\n  2012-01-02: 0\n", report.toString());
  }

  public function testTwoMonths()
  {
      var report = new LogReport(MLOG);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-02-02"), 2);
      report.include(Date.fromString("2012-02-02"), Main.NO_DATA);
      assertEquals("  2012-01: 1\n  2012-02: 2\n", report.toString());
  }

  public function testTwoGap()
  {
      var report = new LogReport(DLOG);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("  2012-01-01: 1\n  2012-01-02: 2\n", report.toString());
  }
}
