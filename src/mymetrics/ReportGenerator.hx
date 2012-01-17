package mymetrics;

import neko.Lib;
import mymetrics.node.Node;

class ReportGenerator
{
    private var currentAvg :ResultBlock;
    private var currentTot :ResultBlock;

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

    private var count :Int;

    private var root :Node;

    public function new()
    {
        root = new Node(null, 0, "root");
        currentStreak = 0;
        currentStreakOn = false;
        count = 0;
    }

    public function include( occ )
    {
        //var today = Date.fromString(Utils.dayStr(Date.now()));
        //var occDate = Date.fromString(occ.date);
        root.fileIt(Node.pathFromDayStr(occ.date), occ.value);
    }

    public function print()
    {
        trace(root.toString());
        // var buf = new StringBuf();
        // buf.add("total for today: "+ currentTot.dayVal +"\n");
        // buf.add("total for this week: "+ currentTot.weekVal +"\n");
        // buf.add("total for this month: " + currentTot.monthVal +"\n");
        // buf.add("total for this year: " + currentTot.yearVal +"\n");
        // buf.add("\n");
        // Lib.println(buf.toString());
    }

    private function tenths(val)
    {
        return Math.round(val*10)/10;
    }
}

typedef ResultBlock = {
    var dayVal :Int;
    var weekVal :Int;
    var monthVal :Int;
    var yearVal :Int;

    var dayDate :String;
    var weekDate :String;
    var monthDate :String;
    var yearDate :String;
}
