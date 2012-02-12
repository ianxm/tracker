package mymetrics.report;

class TestStreakLogReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new StreakLogReport();
      assertEquals("no occurrences", report.toString());
  }

  public function testOn()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("   on   1 day  from 2012-01-01\n", report.toString());
  }

  public function testOnOff()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("   on   1 day  from 2012-01-01\n  off   1 day  from 2012-01-02\n", report.toString());
  }

  public function testTwoOnTwoOff()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("   on   2 days from 2012-01-01\n  off   2 days from 2012-01-03\n", report.toString());
  }

  public function testOffOneDay()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("no occurrences", report.toString());
  }

  public function testOffFixed()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("  off   3 days from 2012-01-01\n", report.toString());
  }

  public function testOffOn()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("  off   1 day  from 2012-01-01\n   on   1 day  from 2012-01-02\n", report.toString());
  }

  public function testOffOnOff()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("  off   1 day  from 2012-01-01\n   on   1 day  from 2012-01-02\n  off   1 day  from 2012-01-03\n", report.toString());
  }

  public function testBigGap1()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2011-04-01"), 0);
      report.include(Date.fromString("2011-04-26"), 1);
      report.include(Date.fromString("2011-05-01"), 0);
      assertEquals("  off  25 days from 2011-04-01\n   on   1 day  from 2011-04-26\n  off   5 days from 2011-04-27\n", report.toString());
  }

  public function testBigGap2()
  {
      var report = new StreakLogReport();
      report.include(Date.fromString("2011-04-01"), 0);
      report.include(Date.fromString("2011-04-26"), 1);
      report.include(Date.fromString("2011-05-01"), 2);
      report.include(Date.fromString("2011-05-01"), 0);
      assertEquals("  off  25 days from 2011-04-01\n   on   1 day  from 2011-04-26\n  off   5 days from 2011-04-27\n   on   1 day  from 2011-05-01\n", report.toString());
  }
}
