package mymetrics;

using Lambda;
import neko.Lib;
import neko.Sys;
import utils.Utils;

class Main
{
    public static var DB_FILE = Sys.environment().get("HOME") + "/.mymetrics.db";
    private static var VERSION = "v0.1";

    private var metric :String;
    private var range  :Array<String>;
    private var val    :Int;
    private var cmd    :Command;

    public function new()
    {
        cmd = null;
        range = [null, null];
    }

    public function run()
    {
        parseArgs();
        var tracker = new Tracker(metric);
        switch (cmd)
        {
        case LIST:    tracker.list();
        case INCR:    tracker.incr(range);
        case SET:     tracker.set(range, val);
        case CLEAR:   tracker.clear(range);
        case STREAKS: tracker.view(range, STREAKS);
        case RECORDS: tracker.view(range, RECORDS);
        case LOG:     tracker.view(range, LOG);
        default:      tracker.view(range, STREAKS);
        }
        tracker.close();
    }

    private function parseArgs()
    {
        var args = Sys.args();

        try
        {
            while( args.length>0 )
            {
                var arg = args.shift();
                switch( arg )
                {
                case "list":        cmd = LIST;
                case "incr":        cmd = INCR;
                case "set":         cmd = SET;
                case "--val":       val = Std.parseInt(args.shift());
                case "clear":       cmd = CLEAR;
                case "cal":         cmd = CAL;
                case "log":         cmd = LOG;
                case "records":     cmd = RECORDS;
                case "streaks":     cmd = STREAKS;
                case "graph":       cmd = GRAPH;
                case "-v":          printVersion();
                case "-h", "help":  printHelp();
                default:
                    {
                        if( cmd == null )
                            throw "unknown command: " + arg;

                        // range
                        if( args.length > 0 )
                        {
                            var dateFix = function(ii) {
                                return switch(ii){
                                case "today":     Utils.dayStr(Date.now());
                                case "yesterday": Utils.dayStr(Utils.dayShift(Date.now(),-1));
                                default:          Utils.dayStr(ii);
                                }
                            }
                            if( arg.indexOf("..")!=-1 )
                                range = arg.split("..").map(dateFix).array();
                            else
                            {
                                var date = dateFix(arg);
                                range = [date, date];
                            }
                        }

                        // metric
                        metric = arg;
                    }
                }
            }
            if( metric == null )
                cmd = LIST;
            if( range[0] == null && ( cmd==INCR || cmd==SET ) )
                throw "INCR and SET not allowed with open date range";
            if( range[1] == null )
                range[1] = Utils.dayStr(Date.now());
        } catch ( e:Dynamic ) {
            Lib.println("ERROR: problem processing args: " + e);
            Sys.exit(1);
        }
    }

    private static function printVersion()
    {
        Lib.println("MyMetrics "+ VERSION);
        Sys.exit(0);
    }

    private static function printHelp()
    {
        Lib.println("MyMetrics "+ VERSION);
        Lib.println("usage: neko mymetrics [options] [range] [metric]");
        Lib.println("  if metric is omitted, MyMetrics will list all metrics");
        Lib.println("  if all options are omitted, MyMetrics will display metric report");
        Lib.println("  range is in the form [startdate]..[enddate].");
        Lib.println("    if either date is omitted the range will extend to the start of");
        Lib.println("    the data or current day, respectively.");
        Lib.println("options:");
        Lib.println("  -i           increment value(s)");
        Lib.println("  -s [val]     set value(s)");
        Lib.println("  -d [date]    specify day to modify as YYYY-MM-DD");
        Lib.println("  -v           show version and exit");
        Lib.println("  -h           show usage and exit");
        Sys.exit(0);
    }

    public static function main()
    {
        var tracker = new Main().run();
    }
}

enum Command
{
    LIST;                                                   // list metrics
    INCR;                                                   // increment a day
    SET;                                                    // set the value for a day
    CLEAR;                                                  // clear a value for a day
    CAL;                                                    // show calendar
    LOG;                                                    // show log of entries
    RECORDS;                                                // view report
    STREAKS;                                                // show streaks
    GRAPH;                                                  // show graph
}
