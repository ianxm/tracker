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

class TestBurstRecordReport extends haxe.unit.TestCase
{
  public function testOnEmpty()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      assertEquals("none\n", report.toString());
  }
  public function testOnOne()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedStart()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2011-12-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedEnd()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-05"), Main.NO_DATA);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedEndWithOcc()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testOnReplaceWithNewer()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 2);
      report.include(Utils.dayFromString("2012-01-03"), 2);
      assertEquals("2 starting on 2012-01-03\n", report.toString());
  }

  public function testOnKeepOlder()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 2);
      report.include(Utils.dayFromString("2012-01-03"), 1);
      assertEquals("2 starting on 2012-01-01\n", report.toString());
  }

  public function testOnTwoConsec()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 1);
      assertEquals("2 starting on 2012-01-01\n", report.toString());
  }

  public function testOnTwoConsec2()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 2);
      assertEquals("3 starting on 2012-01-01\n", report.toString());
  }

  public function testOnTwoConsecWithZero()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 0);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneTwo()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-03"), 1);
      report.include(Utils.dayFromString("2012-01-04"), 1);
      assertEquals("2 starting on 2012-01-03\n", report.toString());
  }

  public function testOnTwoOne()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 2);
      report.include(Utils.dayFromString("2012-01-02"), 1);
      report.include(Utils.dayFromString("2012-01-04"), 1);
      assertEquals("3 starting on 2012-01-01\n", report.toString());
  }

  public function testOnOccOnStartDay()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), Main.NO_DATA);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-04"), 1);
      assertEquals("1 starting on 2012-01-04\n", report.toString());
  }

  public function testOnOccOnEndDay()
  {
      var report = new StreakRecordReport(KEEP_HIGHEST, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-04"), 2);
      report.include(Utils.dayFromString("2012-01-04"), Main.NO_DATA);
      assertEquals("2 starting on 2012-01-04\n", report.toString());
  }


    // current

  public function testCurrentEmpty()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      assertEquals("none\n", report.toString());
  }

  public function testCurrentOneOn()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      assertEquals("1 starting on 2012-01-01\n", report.toString());
  }

  public function testCurrentTwoOn()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), 1);
      assertEquals("2 starting on 2012-01-01\n", report.toString());
  }

  public function testCurrentOneOff()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-02"), Main.NO_DATA);
      assertEquals("none\n", report.toString());
  }

  public function testCurrentTwoOff()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-03"), Main.NO_DATA);
      assertEquals("none\n", report.toString());
  }

  public function testCurrentReplaceWithNewerOn()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-03"), 2);
      assertEquals("2 starting on 2012-01-03\n", report.toString());
  }

  public function testCurrentReplaceWithNewerOff()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 2);
      report.include(Utils.dayFromString("2012-01-03"), 1);
      report.include(Utils.dayFromString("2012-01-04"), Main.NO_DATA);
      assertEquals("none\n", report.toString());
  }

  public function testCurrentEndOnOffDay()
  {
      var report = new StreakRecordReport(KEEP_CURRENT, BURSTS);
      report.include(Utils.dayFromString("2012-01-01"), 1);
      report.include(Utils.dayFromString("2012-01-03"), 1);
      report.include(Utils.dayFromString("2012-01-03"), Main.NO_DATA);
      assertEquals("1 starting on 2012-01-03\n", report.toString());
  }
}
