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

class TestBurstLogReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new StreakLogReport(BURSTS);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOn()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      assertEquals("2012-01-01: 1\n", report.toString());
  }

  public function testOnOff()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2012-01-01: 1\n", report.toString());
  }

  public function testTwoOnTwoOff()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 1);
      report.include(Utils.dayFromString("2012-01-04"), Main.NO_DATA);
      assertEquals("2012-01-01: 2\n", report.toString());
  }

  public function testTwoOnTwoOff2()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 2);
      report.include(Utils.dayFromString("2012-01-04"), Main.NO_DATA);
      assertEquals("2012-01-01: 3\n", report.toString());
  }

  public function testTwoOnTwoOffZeros()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 0);
      report.include(Utils.dayFromString("2012-01-02"), 0);
      report.include(Utils.dayFromString("2012-01-04"), Main.NO_DATA);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOffOneDay()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOffOneDaySurrounded()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-03"), 1);
      report.include(Utils.dayFromString("2012-01-03"), Main.NO_DATA);
      assertEquals("2012-01-01: 1\n2012-01-03: 1\n", report.toString());
  }

  public function testOffFixed()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-03"), Main.NO_DATA);
      assertEquals("no occurrences\n", report.toString());
  }

  public function testOffOn()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-02"), 1);
      report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2012-01-02: 1\n", report.toString());
  }

  public function testOffOnOff()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-02"), 3);
      report.include(Utils.dayFromString("2012-01-03"), Main.NO_DATA);
      assertEquals("2012-01-02: 3\n", report.toString());
  }

  public function testBigGap1()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2011-04-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2011-04-26"), 1);
      report.include(Utils.dayFromString("2011-05-01"), Main.NO_DATA);
      assertEquals("2011-04-26: 1\n", report.toString());
  }

  public function testBigGap2()
  {
      var report = new StreakLogReport(BURSTS);
      report.include(Utils.dayFromString("2011-04-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2011-04-26"), 1);
      report.include(Utils.dayFromString("2011-05-01"), 2);
      report.include(Utils.dayFromString("2011-05-01"), Main.NO_DATA);
      assertEquals("2011-04-26: 1\n2011-05-01: 2\n", report.toString());
  }
}
