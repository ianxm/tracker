package tracker.report;

import tracker.Main;

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
      report.include(Date.fromString("2012-02-01"), Main.NO_DATA);
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
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
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

  public function testZeroVal()
  {
      var report = new CalReport();
      report.include(Date.fromString("2011-11-01"), 0);
      report.include(Date.fromString("2011-11-02"), 1);
      report.include(Date.fromString("2011-11-02"), Main.NO_DATA);
      assertEquals("
          Nov 2011
 Su  Mo  Tu  We  Th  Fr  Sa
          0   1   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   .   .   .   . 
  .   .   .   . 
", report.toString());
  }

  public function testFixedStartWithGap()
  {
      var report = new CalReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 2);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
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
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
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
      report.include(Date.fromString("2012-02-04"), Main.NO_DATA);
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
