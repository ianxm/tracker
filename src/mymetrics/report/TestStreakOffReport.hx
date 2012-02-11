package mymetrics.report;

class TestStreakOffReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new StreakOffReport();
      assertEquals("longest off streak: none", report.toString());
  }

  public function testOne()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("longest off streak: 1 day starting on 2012-01-02", report.toString());
  }

  public function testOneWithFixedStart()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("longest off streak: 1 day starting on 2012-01-02", report.toString());
  }

  public function testOneWithFixedEnd()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("longest off streak: 1 day starting on 2012-01-02", report.toString());
  }

  public function testReplaceWithNewer()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-05"), 1);
      assertEquals("longest off streak: 1 day starting on 2012-01-04", report.toString());
  }

  public function testTwoConsec()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("longest off streak: 2 days starting on 2012-01-02", report.toString());
  }

  public function testOneTwo()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("longest off streak: 2 days starting on 2012-01-04", report.toString());
  }

  public function testTwoOne()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("longest off streak: 2 days starting on 2012-01-02", report.toString());
  }

  public function testOccOnStartDay()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("longest off streak: 2 days starting on 2012-01-02", report.toString());
  }

  public function testOccOnEndDay()
  {
      var report = new StreakOffReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("longest off streak: 2 days starting on 2012-01-02", report.toString());
  }
}
