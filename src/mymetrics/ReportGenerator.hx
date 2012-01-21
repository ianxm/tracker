package mymetrics;

using Lambda;
import neko.Lib;
import mymetrics.node.Node;
import utils.Utils;

class ReportGenerator
{
    private var root :Node;

    private var highTot    :ResultBlock;
    private var lowTot     :ResultBlock;
    private var currentTot :ResultBlock;
    private var highCount  :ResultBlock;
    private var lowCount   :ResultBlock;
    private var currentCount :ResultBlock;

    private var onStreak      :Streak; // consective positive days
    private var offStreak     :Streak; // consecutive zero days
    private var currentStreak :Streak; // current positive or zero streak
    private var streakCount   :Int;
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
        highTot       = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        lowTot        = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        currentTot    = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        highCount     = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        lowCount      = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        currentCount  = { day    : null,
                          week   : null,
                          month  : null,
                          year   : null};
        onStreak      = { start  : null,
                          end    : null,
                          length :0};
        offStreak     = { start  : null,
                          end    : null,
                          length :0};
        currentStreak = { start  : null,
                          end    : null,
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
                        startDay    = thisDay;
                        lastDay     = thisDay;
                        streakCount = 1;
                    }
                    else
                    {
                        var delta = Utils.dayDelta(lastDay, thisDay);
                        if( delta==1 )
                            streakCount++;
                        else                    // gap in on streak
                        {
                            // new longest on streak
                            if( streakCount >= onStreak.length )
                            {
                                onStreak.start  = Utils.dayShift(lastDay, -streakCount);
                                onStreak.end    = lastDay;
                                onStreak.length = streakCount;
                            }
                            streakCount=1;

                            // new longest off streak (gap)
                            if( delta-1 >= offStreak.length )
                            {
                                offStreak.start  = Utils.dayShift(thisDay, -(delta-1));
                                offStreak.end    = Utils.dayShift(thisDay, -1);
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

        // check most recent on streak to end
        if( streakCount >= onStreak.length )
        {
            onStreak.start  = Utils.dayShift(lastDay, -streakCount);
            onStreak.end    = lastDay;
            onStreak.length = streakCount;
        }

        // current streak
        var thisDay = Utils.day(Date.now());
        isCurrentStreakOn = (thisDay.toString() == lastDay.toString());
        if( isCurrentStreakOn )
        {
            currentStreak.start  = Utils.dayShift(thisDay, -(streakCount-1));
            currentStreak.end    = thisDay;
            currentStreak.length = streakCount;
            if( streakCount >= currentStreak.length )
                onStreak = currentStreak;
        }
        else
        {
            var delta = Utils.dayDelta(lastDay, thisDay);
            currentStreak.start  = Utils.dayShift(thisDay, -(delta-1));
            currentStreak.end    = thisDay;
            currentStreak.length = delta;
            if( delta-1 >= offStreak.length )
                offStreak = currentStreak;
        }

        // gather recent data
        var now = Date.now();
        var today = Utils.dayStr(now);
        var todayPath = Node.pathFromDayStr(today).array();
        currentTot.day     = root.pullNode(todayPath.list());
        currentTot.month   = root.pullNode(todayPath.slice(0,2).list());
        currentTot.year    = root.pullNode(todayPath.slice(0,1).list());

        currentCount.day   = root.pullNode(todayPath.list());
        currentCount.month = root.pullNode(todayPath.slice(0,2).list());
        currentCount.year  = root.pullNode(todayPath.slice(0,1).list());

        var aMonthBack = Utils.dayStr(new Date(now.getFullYear(),
                                               now.getMonth()-1,
                                               now.getDate(),
                                               0, 0, 0));
        var aMonthBackPath = Node.pathFromDayStr(aMonthBack).array();
        var lastMonth = root.pullNode(aMonthBackPath.slice(0,2).list());

        // produce the report
        var buf = new StringBuf();
        buf.add("\n");

        buf.add("info:\n");
        buf.add("  first day: "+ Utils.dayStr(startDay) +"\n");
        buf.add("  total duration: "+ Utils.dayDelta(startDay, lastDay) +" days\n");
        buf.add("\n");

        buf.add("totals:\n");
        buf.add("  high year: "  + printNodeWithDate(highTot.year, "value") + "\n");
        buf.add("  high month: " + printNodeWithDate(highTot.month, "value") +"\n");
        buf.add("  high day: "   + printNodeWithDate(highTot.day, "value") +"\n");
        buf.add("\n");
        buf.add("  low year: "   + printNodeWithDate(lowTot.year, "value") +"\n");
        buf.add("  low month: "  + printNodeWithDate(lowTot.month, "value") +"\n");
        buf.add("  low day: "    + printNodeWithDate(lowTot.day, "value") +"\n");
        buf.add("\n");
        buf.add("  this year: "  + printNode(currentCount.year, "value") +"\n");
        buf.add("  this month: " + printNode(currentCount.month, "value") +"\n");
        buf.add("  last month: " + printNode(lastMonth, "value") +"\n");
        buf.add("  today: "      + printNode(currentCount.day, "value") +"\n");
        buf.add("\n");

        buf.add("counts:\n");
        buf.add("  high year: "  + printNodeWithDate(highCount.year, "count") +"\n");
        buf.add("  high month: " + printNodeWithDate(highCount.month, "count") +"\n");
        buf.add("\n");
        buf.add("  low year: "   + printNodeWithDate(lowCount.year, "count") +"\n");
        buf.add("  low month: "  + printNodeWithDate(lowCount.month, "count") +"\n");
        buf.add("\n");
        buf.add("  this year: "  + printNode(currentCount.year, "count") +"\n");
        buf.add("  this month: " + printNode(currentCount.month, "count") +"\n");
        buf.add("  last month: " + printNode(lastMonth, "count") +"\n");
        buf.add("  today: "      + printNode(currentCount.day, "count") +"\n");
        buf.add("\n");
        
        buf.add("streaks:\n");
        buf.add("  longest on streak: "+ printStreak(onStreak) +"\n");
        buf.add("  longest off streak: "+ printStreak(offStreak) +"\n");
        buf.add("  current streak: ("+ (isCurrentStreakOn?"on":"off")+") "+ printStreak(currentStreak) +"\n");

        Lib.println(buf.toString());
    }

    inline private function printNodeWithDate(node :Node, field)
    {
        return (node==null) ? "[none]" : node.date + " ("+ Reflect.field(node,field) +")";
    }

    inline private function printNode(node :Node, field)
    {
        return (node==null) ? "0" : Std.string(Reflect.field(node,field));
    }

    inline private function printStreak(streak :Streak)
    {
        return (streak==null) ? "[none]" : Utils.dayToStr(streak.start) +" to " + Utils.dayToStr(streak.end) +" ("+ streak.length +" days)";
    }
}

typedef ResultBlock = {
    var day   :Node;
    var week  :Node;
    var month :Node;
    var year  :Node;
}

typedef Streak = {
    var start  :Date;
    var end    :Date;
    var length :Int;
}
