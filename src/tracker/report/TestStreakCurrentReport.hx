package tracker.report;

class TestStreakCurrentReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new StreakCurrentReport();
      assertEquals("current streak: none", report.toString());
  }

  public function testOneOn()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("current streak: on    1 day  starting on 2012-01-01", report.toString());
  }

  public function testTwoOn()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("current streak: on    2 days starting on 2012-01-01", report.toString());
  }

  public function testOneOff()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("current streak: off   1 day  starting on 2012-01-02", report.toString());
  }

  public function testTwoOff()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("current streak: off   2 days starting on 2012-01-02", report.toString());
  }

  public function testReplaceWithNewerOn()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("current streak: on    1 day  starting on 2012-01-03", report.toString());
  }

  public function testReplaceWithNewerOff()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("current streak: off   1 day  starting on 2012-01-04", report.toString());
  }

  public function testEndOnOffDay()
  {
      var report = new StreakCurrentReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("current streak: on    1 day  starting on 2012-01-03", report.toString());
  }
}
