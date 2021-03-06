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

import utils.Utils;
import tracker.Main;

class TestCountReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new CountReport();
      assertEquals("0 occurrences\n", report.toString());
  }

  public function testOne()
  {
      var report = new CountReport();
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 occurrence\n", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new CountReport();
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 occurrence\n", report.toString());
  }

  public function testTwo()
  {
      var report = new CountReport();
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 2);
      report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2 occurrences\n", report.toString());
  }


  public function testTwoGap()
  {
      var report = new CountReport();
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 2);
      report.include(Utils.dayFromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2 occurrences\n", report.toString());
  }
}
