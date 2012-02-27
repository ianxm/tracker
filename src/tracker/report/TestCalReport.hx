/*
 Copyright (c) 2012, Ian Martins (ianxm@jhu.edu)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/
package tracker.report;

import tracker.Main;

class TestCalReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new CalReport(TOTAL);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOne()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2012-02-01"), 1);
      report.include(Date.fromString("2012-02-01"), Main.NO_DATA);
      assertEquals("
             Feb 2012
  Su   Mo   Tu   We   Th   Fr   Sa
                  1    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    . 
", report.toString());
  }

  public function testOneFixedStart()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("
             Jan 2012
  Su   Mo   Tu   We   Th   Fr   Sa
   1    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    . 
", report.toString());
  }

  public function testZeroVal()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2011-11-01"), 0);
      report.include(Date.fromString("2011-11-02"), 1);
      report.include(Date.fromString("2011-11-02"), Main.NO_DATA);
      assertEquals("
             Nov 2011
  Su   Mo   Tu   We   Th   Fr   Sa
             0    1    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    . 
", report.toString());
  }

  public function testFixedStartWithGap()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 2);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
      assertEquals("
             Jan 2012
  Su   Mo   Tu   We   Th   Fr   Sa
   1    .    2    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    . 
", report.toString());
  }

  public function testTwoGap()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("
             Jan 2012
  Su   Mo   Tu   We   Th   Fr   Sa
   1    2    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    . 
", report.toString());
  }

  public function testTwoMonths()
  {
      var report = new CalReport(TOTAL);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-02-02"), 2);
      report.include(Date.fromString("2012-02-04"), Main.NO_DATA);
      assertEquals("
             Jan 2012
  Su   Mo   Tu   We   Th   Fr   Sa
   .    .    .    1    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    . 

             Feb 2012
  Su   Mo   Tu   We   Th   Fr   Sa
                  .    2    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    . 
", report.toString());
  }

  public function testCount()
  {
      var report = new CalReport(COUNT);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("
             Jan 2012
  Su   Mo   Tu   We   Th   Fr   Sa
   1    1    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    .    .    .    .    . 
   .    .    . 
", report.toString());
  }

}
