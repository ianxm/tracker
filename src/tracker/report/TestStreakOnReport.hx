package tracker.report;

class TestStreakOnReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new StreakOnReport();
      assertEquals("longest on streak: none", report.toString());
  }

  public function testOne()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("longest on streak: 1 day starting on 2012-01-01", report.toString());
  }

  public function testOneWithFixedStart()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2011-12-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("longest on streak: 1 day starting on 2012-01-01", report.toString());
  }

  public function testOneWithFixedEnd()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("longest on streak: 1 day starting on 2012-01-01", report.toString());
  }

  public function testOneWithFixedEndWithOcc()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("longest on streak: 1 day starting on 2012-01-01", report.toString());
  }

  public function testReplaceWithNewer()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("longest on streak: 1 day starting on 2012-01-03", report.toString());
  }

  public function testTwoConsec()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("longest on streak: 2 days starting on 2012-01-01", report.toString());
  }

  public function testOneTwo()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("longest on streak: 2 days starting on 2012-01-03", report.toString());
  }

  public function testTwoOne()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("longest on streak: 2 days starting on 2012-01-01", report.toString());
  }

  public function testOccOnStartDay()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("longest on streak: 1 day starting on 2012-01-04", report.toString());
  }

  public function testOccOnEndDay()
  {
      var report = new StreakOnReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("longest on streak: 1 day starting on 2012-01-04", report.toString());
  }
}
