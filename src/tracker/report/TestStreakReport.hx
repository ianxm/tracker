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

class TestStreakReport extends haxe.unit.TestCase
{
  public function testOnEmpty()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      assertEquals("none\n", report.toString());
  }

  public function testOnOne()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedStart()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-12-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedEnd()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneWithFixedEndWithOcc()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-01\n", report.toString());
  }

  public function testOnReplaceWithNewer()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-03\n", report.toString());
  }

  public function testOnTwoConsec()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("  2 days starting on 2012-01-01\n", report.toString());
  }

  public function testOnTwoConsecWithZero()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("  2 days starting on 2012-01-01\n", report.toString());
  }

  public function testOnOneTwo()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-03\n", report.toString());
  }

  public function testOnTwoOne()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-01\n", report.toString());
  }

  public function testOnOccOnStartDay()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  1 day  starting on 2012-01-04\n", report.toString());
  }

  public function testOnOccOnEndDay()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-04\n", report.toString());
  }

    // streak off

  public function testOffEmpty()
  {
      var report = new StreakReport(KEEP_LOWEST);
      assertEquals("none\n", report.toString());
  }

  public function testOffOne()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-02\n", report.toString());
  }

  public function testOffOneWithFixedStart()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-02\n", report.toString());
  }

  public function testOffOneWithFixedEnd()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-02\n", report.toString());
  }

  public function testOffOneWithFixedEndWithOcc()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("none\n", report.toString());
  }

  public function testOffReplaceWithNewer()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-05"), 1);
      assertEquals("  1 day  starting on 2012-01-04\n", report.toString());
  }

  public function testOffTwoConsec()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-02\n", report.toString());
  }

  public function testOffOneTwo()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("  2 days starting on 2012-01-04\n", report.toString());
  }

  public function testOffTwoOne()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("  2 days starting on 2012-01-02\n", report.toString());
  }

  public function testOffOccOnStartDay()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-02\n", report.toString());
  }

  public function testOffOccOnEndDay()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), Main.NO_DATA);
      assertEquals("  2 days starting on 2012-01-02\n", report.toString());
  }


    // streak current

  public function testCurrentEmpty()
  {
      var report = new StreakReport(KEEP_CURRENT);
      assertEquals("none\n", report.toString());
  }

  public function testCurrentOneOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01 (on)\n", report.toString());
  }

  public function testCurrentTwoOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("  2 days starting on 2012-01-01 (on)\n", report.toString());
  }

  public function testCurrentOneOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-02 (off)\n", report.toString());
  }

  public function testCurrentTwoOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
      assertEquals("  2 days starting on 2012-01-02 (off)\n", report.toString());
  }

  public function testCurrentReplaceWithNewerOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-03 (on)\n", report.toString());
  }

  public function testCurrentReplaceWithNewerOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-04 (off)\n", report.toString());
  }

  public function testCurrentEndOnOffDay()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-03"), Main.NO_DATA);
      assertEquals("  1 day  starting on 2012-01-03 (on)\n", report.toString());
  }
}
