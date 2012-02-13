package tracker.report;

class TestRecordYearReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      assertEquals("no occurrences", report.toString());
  }

  public function testOne()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("highest year: 2012 (1)", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("highest year: 2012 (1)", report.toString());
  }

  public function testTwo()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("highest year: 2012 (3)", report.toString());
  }

  public function testTwoYears()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-11-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("highest year: 2012 (2)", report.toString());
  }

  public function testTwoYearsIncrement()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 1);
      report.include(Date.fromString("2012-01-08"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("highest year: 2012 (3)", report.toString());
  }

  public function testFirstYearBigger()
  {
      var report = new RecordYearReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("highest year: 2011 (2)", report.toString());
  }

  public function testLowestYear()
  {
      var report = new RecordYearReport(KEEP_LOWEST);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals(" lowest year: 2012 (1)", report.toString());
  }

  public function testLowestFirst()
  {
      var report = new RecordYearReport(KEEP_LOWEST);
      report.include(Date.fromString("2011-11-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals(" lowest year: 2011 (1)", report.toString());
  }

    /*
      this test uses Date.now()
  public function testCurrent()
  {
      var report = new RecordYearReport(KEEP_CURRENT);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("current year: 2012 (1)", report.toString());
  }
    */
}
