package mymetrics;

import neko.Lib;
import neko.Sys;
import utils.Utils;

class Main
{
    public static var DB_FILE = Sys.environment().get("HOME") + "/.mymetrics.db";
    private static var VERSION = "v0.1";

    private var metric :String;
    private var day    :String;
    private var val    :Int;
    private var mode   :Mode;

    public function new()
    {
        mode = VIEW;
    }

    public function run()
    {
        parseArgs();
        switch (mode)
        {
        case SET:
            {
                var tracker = new Tracker(metric);
                tracker.set(day, val);
                tracker.close();
            }
        case GET:
            {
                var viewer = new Viewer(metric);
                viewer.get(day);
                viewer.close();
            }
        case INCR: 
            {
                var tracker = new Tracker(metric);
                tracker.incr(day);
                tracker.close();
            }
        case VIEW:
            {
                var viewer = new Viewer(metric);
                viewer.view();
                viewer.close();
            }
        case LOG:
            {
                var viewer = new Viewer(metric);
                viewer.log();
                viewer.close();
            }
        case LIST:
            {
                var viewer = new Viewer(metric);
                viewer.list();
                viewer.close();
            }
        }
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
                case "-i": mode = INCR;
                case "-s": { val = Std.parseInt(args.shift()); mode = SET; }
                case "-g": mode = GET;
                case "-l": mode = LOG;
                case "-d": day = Utils.dayStr(args.shift());
                case "-v": printVersion();
                case "-h": printHelp();
                default:
                    {
                        if( args.length>0 )
                        {
                            Lib.println("unrecognized option: " + arg);
                            printHelp();
                        }
                        // metric
                        metric = arg;
                    }
                }
            }
            if( day == null )
                day = Utils.dayStr(Date.now());
            if( metric == null )
                mode = LIST;

        } catch ( e:Dynamic ) {
            Lib.println("ERROR: problem processing args: " + e);
            Sys.exit(1);
        }
    }

    private static function printVersion()
    {
        Lib.println("Mymetrics "+ VERSION);
        Sys.exit(0);
    }

    private static function printHelp()
    {
        Lib.println("MyMetrics "+ VERSION);
        Lib.println("usage: neko mymetrics [options] [metric]");
        Lib.println("  if metric is omitted, MyMetrics will list all metrics");
        Lib.println("  if all options are omitted, MyMetrics will display metric report");
        Lib.println("options:");
        Lib.println("  -i           increment value for day");
        Lib.println("  -s [val]     set value for day");
        Lib.println("  -g           get value for day");
        Lib.println("  -l           show a log");
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

enum Mode
{
    SET;  // set the value for a day
    GET;  // get a value for a day
    INCR; // increment a day
    VIEW; // view report
    LIST; // list metrics
    LOG;  // show log of entries
}
