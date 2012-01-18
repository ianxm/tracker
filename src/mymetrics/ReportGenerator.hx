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

    private var longestOnStreak       :Int;             // consective positive days
    private var longestOnStreakEnded  :String;
    private var longestOffStreak      :Int;             // consecutive zero days
    private var longestOffStreakEnded :String;
    private var currentStreak         :Int;             // days
    private var currentStreakOn       :Bool;            // if true, current streak is 'on'

    public function new()
    {
        root = new Node(null, 0, "root");
        currentStreak = 0;
        currentStreakOn = false;
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
                    }
                    if( highTot.day==null || node.value > highTot.day.value )
                        highTot.day = node;
                    if( lowTot.day==null || node.value <= lowTot.day.value )
                        lowTot.day = node;
                    lastDay = thisDay;
                }
            }
        }

        var buf = new StringBuf();
        buf.add("\n");
        buf.add("totals\n");
        buf.add("------\n");
        buf.add("high year: "+ highTot.year.value +" ("+ highTot.year.date +")\n");
        buf.add("high month: "+ highTot.month.value +" ("+ highTot.month.date +")\n");
        buf.add("high day: "+ highTot.day.value +" ("+ highTot.day.date +")\n");
        buf.add("\n");
        buf.add("low year: "+ lowTot.year.value +" ("+ lowTot.year.date +")\n");
        buf.add("low month: "+ lowTot.month.value +" ("+ lowTot.month.date +")\n");
        buf.add("low day: "+ lowTot.day.value +" ("+ lowTot.day.date +")\n");
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
        buf.add("last day: "+ Utils.dayStr(lastDay) +"\n");
        buf.add("total duration: "+ delta(startDay, lastDay) +" days\n");
        buf.add("\n");

        buf.add("counts\n");
        buf.add("------\n");
        buf.add("high year: "+ highCount.year.value +" ("+ highCount.year.date +")\n");
        buf.add("high month: "+ highCount.month.value +" ("+ highCount.month.date +")\n");
        buf.add("\n");
        buf.add("low year: "+ lowCount.year.value +" ("+ lowCount.year.date +")\n");
        buf.add("low month: "+ lowCount.month.value +" ("+ lowCount.month.date +")\n");
        Lib.println(buf.toString());
    }

    inline private function delta(date1 :Date, date2 :Date)
    {
        return (date2.getTime()-date1.getTime())/(1000*60*60*24);
    }
}

typedef ResultBlock = {
    var day :Node;
    var week :Node;
    var month :Node;
    var year :Node;
}
