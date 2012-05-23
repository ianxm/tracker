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
package tracker;

using Lambda;
using StringTools;
import neko.Lib;
import utils.Utils;
import tracker.Main;
import tracker.report.Report;

class ReportGenerator
{
    private var reports :List<Report>;
    private var indent  :Bool;
    private var tail    :Int;

    public function new(t)
    {
        tail = t;
        reports = new List<Report>();
        indent = false;
    }

    public function setReport(cmd, groupType, valType)
    {
        switch(cmd)
        {
        case RECORDS:
            {
                indent = true;
                if( tail == null )
                    reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.Spacer());

                if( valType==TOTAL || valType==PERCENT || 
                    valType==AVG_DAY || valType==AVG_WEEK || valType==AVG_MONTH  || valType==AVG_YEAR )
                {
                    reports.add(new tracker.report.RecordReport(YEAR,  KEEP_HIGHEST, valType));
                    reports.add(new tracker.report.RecordReport(YEAR,  KEEP_LOWEST,  valType));
                    reports.add(new tracker.report.RecordReport(YEAR,  KEEP_CURRENT, valType));
                    reports.add(new tracker.report.Spacer());
                }

                if( valType==TOTAL || valType==PERCENT || 
                    valType==AVG_DAY || valType==AVG_WEEK || valType==AVG_MONTH )
                {
                    reports.add(new tracker.report.RecordReport(MONTH, KEEP_HIGHEST, valType));
                    reports.add(new tracker.report.RecordReport(MONTH, KEEP_LOWEST,  valType));
                    reports.add(new tracker.report.RecordReport(MONTH, KEEP_CURRENT, valType));
                    reports.add(new tracker.report.Spacer());
                }

                if( valType==TOTAL || valType==PERCENT || valType==AVG_DAY || valType==AVG_WEEK )
                {
                    reports.add(new tracker.report.RecordReport(WEEK,  KEEP_HIGHEST, valType));
                    reports.add(new tracker.report.RecordReport(WEEK,  KEEP_LOWEST,  valType));
                    reports.add(new tracker.report.RecordReport(WEEK,  KEEP_CURRENT, valType));
                    reports.add(new tracker.report.Spacer());
                }

                if( valType==TOTAL || valType==PERCENT || valType==AVG_DAY )
                {
                    reports.add(new tracker.report.RecordReport(DAY,   KEEP_HIGHEST, valType));
                    reports.add(new tracker.report.RecordReport(DAY,   KEEP_LOWEST,  valType));
                    reports.add(new tracker.report.RecordReport(DAY,   KEEP_CURRENT, valType));
                    reports.add(new tracker.report.Spacer());
                }

                reports.add(new tracker.report.StreakReport(KEEP_HIGHEST));
                reports.add(new tracker.report.StreakReport(KEEP_LOWEST));
                reports.add(new tracker.report.StreakReport(KEEP_CURRENT));
                tail = null;
            }
        case LOG:
            {
                if( tail == null )
                    reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.LogReport(groupType, valType));
            }
        case STREAKS:
            {
                if( tail == null )
                    reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.StreakLogReport());
            }
        case CAL:
            {
                if( tail == null )
                    reports.add(new tracker.report.DurationReport());
                reports.add(new tracker.report.CalReport(valType));
                tail = null;
            }
        default:
            throw "unknown report command";
        }
    }

    public function include( date, val )
    {
        for( report in reports )
            report.include(date, val);
    }

    public function print()
    {
        var labelWidth:Int = if( indent )
            reports.fold(function(rr,width:Int) return Std.int(Math.max(rr.getLabel().length,width)), 0);
        else
            0;

        var fifo = new List<String>();
        for( report in reports )
        {
            var line = report.getLabel().lpad(' ', labelWidth) + report.toString();
            if( tail == null )
                Lib.print(line);                          // just write to stdout
            else
            {
                for( ii in line.split("\n") )               // add each line to the fifo
                {
                    if( ii != "" )
                        fifo.add(ii);
                    if( fifo.length > tail )
                        fifo.pop();
                }
            }
            while( !fifo.isEmpty() )                            // dump the fifo to stdout
                Lib.print(fifo.pop() + "\n");
        }
    }
}
