package mymetrics;

using Lambda;
import neko.Lib;
import mymetrics.node.Node;
import utils.Utils;

class ReportGenerator
{
    private var root :Node;

    private var currentAvg :ResultBlock;
    private var highAvg    :ResultBlock;
    private var highTot    :ResultBlock;
    private var lowAvg     :ResultBlock;
    private var lowTot     :ResultBlock;
    private var highCount  :ResultBlock;
    private var lowCount   :ResultBlock;

    private var onStreak   :Streak;               // consective positive days
    private var offStreak  :Streak;               // consecutive zero days
    private var currentStreak :Streak;            // current positive or zero streak
    private var streakCount :Int;
    private var isCurrentStreakOn :Bool;

    public function new()
    {
        root = new Node(null, 0, "root");
        streakCount = 0;
    }

    public function include( occ )
    {
        root.fileIt(Node.pathFromDayStr(occ.date), occ.value);
    }

    public function print()
    {
        highTot   = { day   : null,
                      week  : null,
                      month : null,
                      year  : null};
        lowTot    = { day   : null,
                      week  : null,
                      month : null,
                      year  : null};
        highCount = { day   : null,
                      week  : null,
                      month : null,
                      year  : null};
        lowCount  = { day   : null,
                      week  : null,
                      month : null,
                      year  : null};
        onStreak  = { start : null,
                      end   : null,
                      length :0};
        offStreak = { start : null,
                      end   : null,
                      length :0};
        currentStreak = { start : null,
                          end   : null,
                          length :0};

        var startDay = null;
        var lastDay = null;
        for( node in root )
        {
            switch( node.depth )
            {
            case 0: {}                          // do nothing for root
            case 1:                             // year
                {
                    if( highCount.year==null || node.count>highCount.year.value )
                        highCount.year = node;
                    if( lowCount.year==null || node.count < lowCount.year.value )
                        lowCount.year = node;
                    if( highTot.year==null || node.value > highTot.year.value )
                        highTot.year = node;
                    if( lowTot.year==null || node.value <= lowTot.year.value )
                        lowTot.year = node;
                }
            case 2:                             // month
                {
                    if( highCount.month==null || node.count > highCount.month.value )
                        highCount.month = node;
                    if( lowCount.month==null || node.count < lowCount.month.value )
                        lowCount.month = node;
                    if( highTot.month==null || node.value > highTot.month.value )
                        highTot.month = node;
                    if( lowTot.month==null || node.value <= lowTot.month.value )
                        lowTot.month = node;
                }
            case 3:                             // day
                {
                    var thisDay = new Date(Std.parseInt(node.parent.parent.index),
                                           Std.parseInt(node.parent.index),
                                           Std.parseInt(node.index),
                                           0, 0, 0);
                    if( startDay == null )
                    {
                        startDay = thisDay;
                        lastDay = thisDay;
                        streakCount = 1;
                    }
                    else
                    {
                        var delta = Utils.dayDelta(lastDay, thisDay);
                        if( delta==1 )
                            streakCount++;
                        else                    // gap in on streak
                        {
                            if( streakCount >= onStreak.length )
                            {
                                onStreak.start = Utils.dayShift(lastDay, -streakCount);
                                onStreak.end = lastDay;
                                onStreak.length = streakCount;
                            }
                            streakCount=1;

                            if( delta-1 >= offStreak.length )
                            {
                                offStreak.start = Utils.dayShift(thisDay, -(delta-1));
                                offStreak.end = Utils.dayShift(thisDay, -1);
                                offStreak.length = delta-1;
                            }
                        }
                            
                    }
                    if( highTot.day==null || node.value > highTot.day.value )
                        highTot.day = node;
                    if( lowTot.day==null || node.value <= lowTot.day.value )
                        lowTot.day = node;
                    lastDay = thisDay;
                }
            }
        }

        // current streak
        var thisDay = Utils.day(Date.now());
        isCurrentStreakOn = (thisDay.toString() == lastDay.toString());
        if( isCurrentStreakOn )
        {
            currentStreak.start = Utils.dayShift(thisDay, -(streakCount-1));
            currentStreak.end = thisDay;
            currentStreak.length = streakCount;
            if( streakCount >= currentStreak.length )
                onStreak = currentStreak;
        }
        else
        {
            var delta = Utils.dayDelta(lastDay, thisDay);
            currentStreak.start = Utils.dayShift(thisDay, -(delta-1));
            currentStreak.end = thisDay;
            currentStreak.length = delta;
            if( delta-1 >= offStreak.length )
                offStreak = currentStreak;
        }

        var buf = new StringBuf();
        buf.add("\n");
        buf.add("totals\n");
        buf.add("------\n");
        buf.add("high year: "+ highTot.year.date +" ("+ highTot.year.value +")\n");
        buf.add("high month: "+ highTot.month.date +" ("+ highTot.month.value +")\n");
        buf.add("high day: "+ highTot.day.date +" ("+ highTot.day.value +")\n");
        buf.add("\n");
        buf.add("low year: "+ lowTot.year.date +" ("+ lowTot.year.value +")\n");
        buf.add("low month: "+ lowTot.month.date +" ("+ lowTot.month.value +")\n");
        buf.add("low day: "+ lowTot.day.date +" ("+ lowTot.day.value +")\n");
        buf.add("\n");

        var now = Date.now();
        var today = Utils.dayStr(now);
        var todayPath = Node.pathFromDayStr(today).array();
        var today = root.pullIt(todayPath.list(), false);
        var thisMonth = root.pullIt(todayPath.slice(0,2).list(), false);
        var thisYear = root.pullIt(todayPath.slice(0,1).list(), false);

        var aMonthBack = Utils.dayStr(new Date(now.getFullYear(),
                                               now.getMonth()-1,
                                               now.getDate(),
                                               0, 0, 0));
        var aMonthBackPath = Node.pathFromDayStr(aMonthBack).array();
        var lastMonth = root.pullIt(aMonthBackPath.slice(0,2).list(), false);

        buf.add("this year: "+ thisYear +"\n");
        buf.add("this month: "+ thisMonth +"\n");
        buf.add("last month: "+ lastMonth +"\n");
        buf.add("today: "+ today +"\n");
        buf.add("\n");
        buf.add("first day: "+ Utils.dayStr(startDay) +"\n");
        buf.add("total duration: "+ Utils.dayDelta(startDay, lastDay) +" days\n");
        buf.add("\n");

        buf.add("counts\n");
        buf.add("------\n");
        buf.add("high year: "+ highCount.year.date +" ("+ highCount.year.value +")\n");
        buf.add("high month: "+ highCount.month.date +" ("+ highCount.month.value +")\n");
        buf.add("\n");
        buf.add("low year: "+ lowCount.year.date +" ("+ lowCount.year.value +")\n");
        buf.add("low month: "+ lowCount.month.date +" ("+ lowCount.month.value +")\n");
        buf.add("\n");
        
        buf.add("streaks\n");
        buf.add("-------\n");
        buf.add("longest on streak: "+ Utils.dayToStr(onStreak.start) +" to " + Utils.dayToStr(onStreak.end) +" ("+ onStreak.length +" days)\n");
        buf.add("longest off streak: "+ Utils.dayToStr(offStreak.start) +" to " + Utils.dayToStr(offStreak.end) +" ("+ offStreak.length +" days)\n");
        buf.add("current streak: ("+ (isCurrentStreakOn?"on":"off")+") "+ Utils.dayToStr(currentStreak.start) +" to " + Utils.dayToStr(currentStreak.end) +" ("+ currentStreak.length +" days)\n");

        Lib.println(buf.toString());
    }
}

typedef ResultBlock = {
    var day :Node;
    var week :Node;
    var month :Node;
    var year :Node;
}

typedef Streak = {
    var start :Date;
    var end :Date;
    var length :Int;
}
