package tracker.report;

class TestCountReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new CountReport();
      assertEquals("0 occurrences", report.toString());
  }

  public function testOne()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("1 occurrence", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("1 occurrence", report.toString());
  }

  public function testTwo()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("2 occurrences", report.toString());
  }


  public function testTwoGap()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("2 occurrences", report.toString());
  }
}
