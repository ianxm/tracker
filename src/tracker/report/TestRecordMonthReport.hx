package tracker.report;

class TestRecordMonthReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      assertEquals("no occurrences", report.toString());
  }

  public function testOne()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("highest month: 2012-01 (1)", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("highest month: 2012-01 (1)", report.toString());
  }

  public function testTwo()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("highest month: 2012-01 (3)", report.toString());
  }

  public function testTwoMonths()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-02-02"), 2);
      report.include(Date.fromString("2012-02-05"), 0);
      assertEquals("highest month: 2012-02 (2)", report.toString());
  }

  public function testTwoYears()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-12-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("highest month: 2012-01 (2)", report.toString());
  }

  public function testTwoMonthsIncrement()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 2);
      report.include(Date.fromString("2012-02-02"), 1);
      report.include(Date.fromString("2012-02-05"), 1);
      report.include(Date.fromString("2012-02-08"), 1);
      report.include(Date.fromString("2012-02-05"), 0);
      assertEquals("highest month: 2012-02 (3)", report.toString());
  }

  public function testFirstMonthBigger()
  {
      var report = new RecordMonthReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-12-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("highest month: 2011-12 (2)", report.toString());
  }

  public function testLowestMonth()
  {
      var report = new RecordMonthReport(KEEP_LOWEST);
      report.include(Date.fromString("2011-12-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals(" lowest month: 2012-01 (1)", report.toString());
  }

  public function testLowestFirst()
  {
      var report = new RecordMonthReport(KEEP_LOWEST);
      report.include(Date.fromString("2011-12-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals(" lowest month: 2011-12 (1)", report.toString());
  }

    /*
      this test uses Date.now()
  public function testCurrent()
  {
      var report = new RecordMonthReport(KEEP_CURRENT);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("current month: 2012 (1)", report.toString());
  }
    */
}
