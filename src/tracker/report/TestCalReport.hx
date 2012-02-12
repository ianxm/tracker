package tracker.report;

class TestCalReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new CalReport();
      assertEquals("no occurrences", report.toString());
  }

  public function testOne()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-02-01"), 1);
      report.include(Date.fromString("2012-02-01"), 0);
      assertEquals("
          Feb 2012
 Su  Mo  Tu  We  Th  Fr  Sa
              1   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   . 
", report.toString());
  }

  public function testOneFixedStart()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("
          Jan 2012
 Su  Mo  Tu  We  Th  Fr  Sa
  1   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   . 
", report.toString());
  }

  public function testFixedStartWithGap()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 2);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("
          Jan 2012
 Su  Mo  Tu  We  Th  Fr  Sa
  1   .   2   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   . 
", report.toString());
  }

  public function testTwoGap()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("
          Jan 2012
 Su  Mo  Tu  We  Th  Fr  Sa
  1   2   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   . 
", report.toString());
  }

  public function testTwoMonths()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-02-02"), 2);
      report.include(Date.fromString("2012-02-04"), 0);
      assertEquals("
          Jan 2012
 Su  Mo  Tu  We  Th  Fr  Sa
  .   .   .   1   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   . 

          Feb 2012
 Su  Mo  Tu  We  Th  Fr  Sa
              .   2   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   . 
", report.toString());
  }
}
