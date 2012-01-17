package mymetrics;

using Lambda;
import neko.Lib;
import mymetrics.node.Node;
import mymetrics.utils.Utils;

class ReportGenerator
{
    private var currentAvg :ResultBlock;

    private var highAvg :ResultBlock;
    private var highTot :ResultBlock;

    private var lowAvg :ResultBlock;
    private var lowTot :ResultBlock;

    private var longestOnStreak :Int;           // consective positive days
    private var longestOnStreakEnded :String;
    private var longestOffStreak :Int;          // consecutive zero days
    private var longestOffStreakEnded :String;

    private var currentStreak :Int;             // days
    private var currentStreakOn :Bool;          // if true, current streak is 'on'

    private var root :Node;

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
        trace(root.prettyPrint());
        highTot = { dayVal: 0.0,
                    weekVal: 0.0,
                    monthVal: 0.0,
                    yearVal: 0.0,
                    dayDate: "",
                    weekDate: "",
                    monthDate: "",
                    yearDate: ""};
        lowTot  = { dayVal: 9999.0,
                    weekVal: 9999.0,
                    monthVal: 9999.0,
                    yearVal: 9999.0,
                    dayDate: "",
                    weekDate: "",
                    monthDate: "",
                    yearDate: ""};

        for( node in root )
        {
            switch( node.depth )
            {
            case 0: break;                      // do nothing for root
            case 1:                             // year
                {
                    if( node.value > highTot.yearVal )
                    {
                        highTot.yearVal = node.value;
                        highTot.yearDate = node.index;
                    }
                    if( node.value <= lowTot.yearVal )
                    {
                        lowTot.yearVal = node.value;
                        lowTot.yearDate = node.index;
                    }
                }
            case 2:                             // month
                {
                    if( node.value > highTot.monthVal )
                    {
                        highTot.monthVal = node.value;
                        highTot.monthDate = node.parent.index +"-"+ node.index;
                    }
                    if( node.value <= lowTot.monthVal )
                    {
                        lowTot.monthVal = node.value;
                        lowTot.monthDate = node.parent.index +"-"+ node.index;
                    }
                }
            case 3:                             // day
                {
                    if( node.value > highTot.dayVal )
                    {
                        highTot.dayVal = node.value;
                        highTot.dayDate = node.parent.parent.index +"-"+ node.parent.index +"-"+ node.index;
                    }
                    if( node.value <= lowTot.dayVal )
                    {
                        lowTot.dayVal = node.value;
                        lowTot.dayDate = node.parent.parent.index +"-"+ node.parent.index +"-"+ node.index;
                    }
                }
            }
        }

        var buf = new StringBuf();
        buf.add("high year: "+ highTot.yearVal +" ("+ highTot.yearDate +")\n");
        buf.add("high month: "+ highTot.monthVal +" ("+ highTot.monthDate +")\n");
        buf.add("high day: "+ highTot.dayVal +" ("+ highTot.dayDate +")\n");
        buf.add("\n");
        buf.add("low year: "+ lowTot.yearVal +" ("+ lowTot.yearDate +")\n");
        buf.add("low month: "+ lowTot.monthVal +" ("+ lowTot.monthDate +")\n");
        buf.add("low day: "+ lowTot.dayVal +" ("+ lowTot.dayDate +")\n");
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

        Lib.println(buf.toString());
    }

    private function tenths(val)
    {
        return Math.round(val*10)/10;
    }
}

typedef ResultBlock = {
    var dayVal :Float;
    var weekVal :Float;
    var monthVal :Float;
    var yearVal :Float;

    var dayDate :String;
    var weekDate :String;
    var monthDate :String;
    var yearDate :String;
}
