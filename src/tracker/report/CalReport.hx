package tracker.report;

using Lambda;
import utils.Utils;
import utils.DeepHash;

class CalReport implements Report
{
    private static var MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    private var tree :DeepHash<Int,Int>;
    private var firstDay :Date;
    private var lastDay :Date;

    public function new()
    {
        tree = new DeepHash<Int,Int>();
    }

    public function include(thisDay :Date, val :Int)
    {
        if( firstDay == null )
            firstDay = thisDay;
        lastDay = thisDay;
        if( val > 0 )
            tree.set(pathFromDay(thisDay), val);
    }

    public function toString()
    {
        if( firstDay == null )
            return "no occurrences";

        var buf = new StringBuf();

        var month = new Date(firstDay.getFullYear(), firstDay.getMonth(), 1, 0, 0, 0);
        var lastMonth = new Date(lastDay.getFullYear(), lastDay.getMonth(), 1, 0, 0, 0);
        do
        {
            printMonth(buf, month);
            month = new Date(month.getFullYear(), month.getMonth()+1, 1, 0, 0, 0);
        } while( Utils.dayDelta(month, lastMonth) >= 0 );

        return buf.toString();
    }

    private function printMonth(buf, month :Date)
    {
        var monthNum = month.getMonth();

        buf.add("\n          " + MONTH_NAMES[monthNum] + " " + month.getFullYear() + "\n" +
                " Su  Mo  Tu  We  Th  Fr  Sa\n");

        // print given month
        var day = month;
        for( ii in 0...month.getDay() )
            buf.add("    ");

        do
        {
            var val = tree.get(pathFromDay(day));
            var str = if( val != null )
                Utils.spaceFill(Std.string(val),2);        
            else if( Utils.dayDelta(day, firstDay) > 0 || 
                     Utils.dayDelta(day, lastDay) < 0 )
                " _";
            else
                " .";
            buf.add(" "+ str +" ");
            if( day.getDay() == 6 )
                buf.add("\n");
            day = Utils.dayShift(day, 1);
        } while( day.getMonth() == monthNum );
        buf.add("\n");
    }

    inline private function pathFromDay(day)
    {
        return [day.getFullYear(), day.getMonth(), day.getDate()].list();
    }
}
